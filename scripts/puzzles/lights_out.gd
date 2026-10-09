class_name LightsOut
extends RefCounted
## Pure logic for the breaker panel: 4 switches in a row, each flips itself and its neighbours.
## The 4x4 toggle matrix is invertible over GF(2), so every state is solvable.

const SIZE := 4


## Off, on, off, on. Minimal solution: switches 2, 3 and 4 (indices 1, 2, 3).
static func initial_state() -> Array[bool]:
	var s: Array[bool] = [false, true, false, true]
	return s


static func press(state: Array[bool], i: int) -> Array[bool]:
	var out: Array[bool] = []
	for v in state:
		out.append(v)
	for j in [i - 1, i, i + 1]:
		if j >= 0 and j < out.size():
			out[j] = not out[j]
	return out


static func is_solved(state: Array[bool]) -> bool:
	for v in state:
		if not v:
			return false
	return true


## Brute force over all press subsets. Returns the minimal number of presses, or -1 if unsolvable.
static func min_presses(state: Array[bool]) -> int:
	var best := -1
	for mask in 1 << SIZE:
		var s := state
		var count := 0
		for i in SIZE:
			if mask & (1 << i):
				s = press(s, i)
				count += 1
		if is_solved(s) and (best == -1 or count < best):
			best = count
	return best
