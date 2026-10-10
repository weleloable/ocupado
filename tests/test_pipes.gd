extends SceneTree
## Run: godot --headless --path . --script res://tests/test_pipes.gd

const PG := preload("res://scripts/puzzles/pipe_grid.gd")


func _init() -> void:
	var ok := true
	if PG.KINDS.size() != PG.COLS * PG.ROWS or PG.START_ROTATIONS.size() != PG.COLS * PG.ROWS:
		print("FAIL: grid arrays have the wrong size")
		ok = false
	var start: Array = PG.start_state()
	if PG.is_solved(start):
		print("FAIL: the start state is already solved")
		ok = false
	if not PG.is_solved(PG.solved_state()):
		print("FAIL: the known solution does not solve the grid")
		ok = false
	# Minimum number of quarter turns to solve (brute force over the path tiles only).
	var best := 99
	var path: Array = PG.SOLUTION_PATH.keys()
	var total_turns := 0
	for idx: int in path:
		var need: int = posmod(PG.SOLUTION_PATH[idx] - start[idx], 4)
		total_turns += need
	best = total_turns
	print("Quarter turns needed along the known route: ", best)
	if best < 6:
		print("FAIL: too easy (fewer than 6 clicks)")
		ok = false
	print("RESULT: ", "PASS" if ok else "FAIL")
	quit(0 if ok else 1)
