extends Node
## Debug: `godot --headless --path . -- --autotest` plays the whole game through the real
## interactables (including a wrong ritual step and a wrong code) and prints PASS/FAIL.

var game: Game
var _ok: bool = true


func _ready() -> void:
	Engine.time_scale = 4.0
	await _wait(1.0)
	var room := game.room

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

	# Puzzle 2: a wrong step first, then the right sequence.
	room.dryer.interact()
	await _wait(2.6)
	_check(GameState.ritual_step == 1, "ritual step 1 after dryer")
	room.cold_tap.interact()  # wrong: expected chain
	_check(GameState.ritual_step == 0, "ritual reset after mistake")
	room.cold_tap.interact()  # close it again
	room.dryer.interact()
	await _wait(2.6)
	room.chain.interact()
	await _wait(2.4)
	room.cold_tap.interact()
	room.dryer.interact()
	await _wait(1.0)
	_check(GameState.ritual_done, "ritual solved")
	room.cold_tap.interact()

	# Puzzle 3: hot tap fogs the mirror.
	room.hot_tap.interact()
	await _wait(5.0)
	_check(GameState.mirror_done, "mirror revealed")
	room.hot_tap.interact()

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
	print("Temperatura final: %.1f, pistas: %d" % [GameState.final_temp, GameState.hints_used])

	# Hints never fail, for every puzzle state.
	for _i in 4:
		var h := GameState.request_hint()
		_check(not str(h["text"]).is_empty(), "hint text")

	print("AUTOTEST RESULT: ", "PASS" if _ok else "FAIL")
	Engine.time_scale = 1.0
	get_tree().quit(0 if _ok else 1)


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _check(cond: bool, what: String) -> void:
	print(("  ok   " if cond else "  FAIL ") + what)
	if not cond:
		_ok = false
