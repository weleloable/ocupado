extends SceneTree
## Run: godot --headless --path . --script res://tests/test_seating.gd

const SP := preload("res://scripts/puzzles/seating.gd")


func _init() -> void:
	var ok := true
	var n: int = SP.count_solutions()
	print("Arrangements that satisfy every statement: ", n)
	if n != 1:
		print("FAIL: the riddle must have exactly one solution")
		ok = false
	if not SP.is_solution(SP.SOLUTION):
		print("FAIL: the declared solution does not satisfy the statements")
		ok = false
	if SP.is_solution(["Paco", "Lucía", "Javi", "Marta"]):
		print("FAIL: a wrong arrangement was accepted")
		ok = false
	print("The culprit sits in seat ", SP.CULPRIT_SEAT, ": ", SP.culprit(), "")
	print("RESULT: ", "PASS" if ok else "FAIL")
	quit(0 if ok else 1)
