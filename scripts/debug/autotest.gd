extends Node
## Debug: `godot --headless --path . -- --autotest` plays the whole game through the real
## interactables (including a wrong ritual step and a wrong code) and prints PASS/FAIL.

var game: Game
var _ok: bool = true


func _ready() -> void:
	Engine.time_scale = 4.0
	await _wait(1.0)
	var room := game.room

	# Aiming: the plug and the valve must be reachable with the crosshair from normal positions.
	await _aim_check(Vector3(-1.0, 0.05, -0.34), 90.0, -48.0, room.plug, "plug (near)")
	await _aim_check(Vector3(-0.6, 0.05, -0.34), 90.0, -34.0, room.plug, "plug (far)")
	await _aim_check(Vector3(1.0, 0.05, 0.63), -90.0, -31.0, room.valve, "valve (near)")
	await _aim_check(Vector3(0.5, 0.05, 0.63), -90.0, -20.0, room.valve, "valve (far)")
	game.player.global_position = Vector3(0, 0.05, 0.7)
	game.player.rotation.y = 0.0
	game.player.camera.rotation.x = 0.0

	_check(not GameState.lights_on, "lights start off")
	room.door.interact()
	_check(not GameState.won, "door locked at start")

	# Ritual elements before the lights do not count.
	room.chain.interact()
	await _wait(2.5)
	_check(GameState.ritual_step == 0, "ritual ignored in the dark")

	# Puzzle 1: switches 2, 3, 4.
	for i in [1, 2, 3]:
		room.breaker.press(i)
	_check(GameState.lights_on, "breaker solved with 3 presses")

	# Puzzle 2: dryer, mop, chain, cold tap, dryer. A wrong step resets it.
	room.dryer.interact()
	await _wait(2.6)
	_check(GameState.ritual_step == 1, "ritual step 1 after dryer")
	room.chain.interact()  # wrong: the mop was expected
	_check(GameState.ritual_step == 0, "ritual reset after mistake")
	await _wait(2.4)
	room.hot_tap.interact()  # the hot tap is not part of the ritual
	room.hot_tap.interact()
	_check(GameState.ritual_step == 0, "hot tap is neutral for the ritual")
	room.dryer.interact()
	await _wait(2.6)
	room.mop.interact()
	_check(GameState.ritual_step == 2, "ritual step 2 after mop")
	room.chain.interact()
	await _wait(2.4)
	room.cold_tap.interact()
	_check(GameState.ritual_step == 4, "ritual step 4 after cold tap")
	room.dryer.interact()
	await _wait(0.5)
	_check(GameState.ritual_done, "ritual solved")

	# Puzzle 3: valve open + hot tap + cold tap closed + warm-up.
	room.hot_tap.interact()  # valve still closed: runs cold
	await _wait(5.0)
	_check(not GameState.mirror_done and room.mirror.fog < 0.01, "no fog with the valve closed")
	room.valve.interact()
	await _wait(5.0)  # the cold tap is still open from the ritual: lukewarm
	_check(not GameState.mirror_done, "lukewarm water does not fog")
	room.cold_tap.interact()
	await _wait(8.0)
	_check(GameState.mirror_done, "mirror revealed")
	room.hot_tap.interact()

	# Phone hint costs exactly 1 °C.
	var before := GameState.get_temperature()
	game._unhandled_input(_action_event("hint"))
	_check(game.state == Game.UiState.PHONE and game.phone.visible, "phone opened with H")
	game.phone.request_hint()
	_check(GameState.hints_used == 1, "hint counted")
	_check(GameState.get_temperature() - before > 0.99, "hint adds 1 C")
	game._unhandled_input(_action_event("pause"))
	_check(game.state == Game.UiState.PLAYING and not game.phone.visible, "phone closed with Esc")

	# Pause and resume.
	game._unhandled_input(_action_event("pause"))
	_check(get_tree().paused and game.pause_menu.visible, "paused")
	game._unhandled_input(_action_event("pause"))
	_check(not get_tree().paused, "resumed")

	# Puzzle 4: keypad, wrong code then right one.
	room.keypad.interact()
	_check(game.state == Game.UiState.KEYPAD, "keypad UI opened")
	game.keypad_ui.type_code("1111")
	await _wait(1.2)
	_check(not GameState.keypad_done, "wrong code rejected")
	game.keypad_ui.type_code("3312")
	await _wait(2.0)
	_check(GameState.keypad_done, "right code accepted")
	_check(game.state == Game.UiState.PLAYING, "keypad UI closed")

	# Final: pull the door.
	await _wait(3.0)
	room.door.interact()
	await _wait(2.5)
	_check(GameState.won, "game won")
	var has_victory := false
	for c in game.get_children():
		if c is VictoryScreen:
			has_victory = true
	_check(has_victory, "victory screen shown")
	print("Temperatura final: %.1f, pistas: %d" % [GameState.final_temp, GameState.hints_used])

	# Hints never fail, for every puzzle state.
	for _i in 4:
		var h := GameState.request_hint()
		_check(not str(h["text"]).is_empty(), "hint text")

	print("AUTOTEST RESULT: ", "PASS" if _ok else "FAIL")
	Engine.time_scale = 1.0
	get_tree().quit(0 if _ok else 1)


func _action_event(action: String) -> InputEventAction:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = true
	return ev


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _check(cond: bool, what: String) -> void:
	print(("  ok   " if cond else "  FAIL ") + what)
	if not cond:
		_ok = false


func _aim_check(pos: Vector3, yaw: float, pitch: float, target: Interactable, label: String) -> void:
	game.player.global_position = pos
	game.player.rotation.y = deg_to_rad(yaw)
	game.player.camera.rotation.x = deg_to_rad(pitch)
	await _wait(0.4)
	_check(game.player.focused == target, "can aim at the " + label)
