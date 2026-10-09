extends Node
## Debug: `godot --headless --path . -- --autotest-flood` checks the secret flood ending.

var game: Game
var _ok: bool = true


func _ready() -> void:
	Engine.time_scale = 4.0
	await _wait(1.0)
	var room := game.room

	# Taps alone (no plug) must never flood.
	room.hot_tap.interact()
	room.cold_tap.interact()
	await _wait(3.0)
	_check(room.flood.progress < 0.01, "no flood without the plug")

	# Plug in: it floods; the door bursts and the game is won with the "flood" ending.
	room.plug.interact()
	_check(GameState.plug_in, "plug in")
	await _wait(5.0)
	_check(room.flood.level > 0.05, "water is rising")
	_check(not GameState.won, "not won yet")

	# Stopping drains the water (nothing is lost).
	room.cold_tap.interact()
	await _wait(2.0)
	var drained: float = room.flood.progress
	_check(drained < Flood.TIME_TO_FLOOD * 0.5, "progress drains when a tap is closed")
	room.cold_tap.interact()

	await _wait(Flood.TIME_TO_FLOOD + 5.0)
	_check(GameState.won, "game won through the flood")
	_check(GameState.ending == "flood", "ending is flood")
	_check(room.door.get_parent().rotation.y < -1.0, "door burst open")
	var has_victory := false
	for c in game.get_children():
		if c is VictoryScreen:
			has_victory = true
	_check(has_victory, "victory screen shown")

	print("AUTOTEST FLOOD RESULT: ", "PASS" if _ok else "FAIL")
	Engine.time_scale = 1.0
	get_tree().quit(0 if _ok else 1)


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _check(cond: bool, what: String) -> void:
	print(("  ok   " if cond else "  FAIL ") + what)
	if not cond:
		_ok = false
