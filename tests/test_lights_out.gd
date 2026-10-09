extends SceneTree
## Run: godot --headless --path . --script res://tests/test_lights_out.gd

const LO := preload("res://scripts/puzzles/lights_out.gd")


func _init() -> void:
	var ok := true
	var initial: Array[bool] = LO.initial_state()
	var needed: int = LO.min_presses(initial)
	print("Initial state ", initial, " -> minimal presses: ", needed)
	if needed < 3:
		print("FAIL: initial state needs fewer than 3 presses")
		ok = false
	if LO.is_solved(initial):
		print("FAIL: initial state is already solved")
		ok = false
	# No reachable state can be a dead end: check all 16.
	for code in 1 << LO.SIZE:
		var s: Array[bool] = []
		for i in LO.SIZE:
			s.append(bool(code & (1 << i)))
		if LO.min_presses(s) < 0:
			print("FAIL: unsolvable state ", s)
			ok = false
	print("RESULT: ", "PASS" if ok else "FAIL")
	quit(0 if ok else 1)
