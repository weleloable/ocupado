class_name PipeGrid
extends RefCounted
## Pure logic of the boiler pipes puzzle: a grid of pipe pieces that can be rotated. Steam enters
## through the west edge of the first column (row SOURCE_ROW) and must reach the east edge of the
## last column (row OUTLET_ROW) travelling only through matching openings.

const COLS := 5
const ROWS := 4
const SOURCE_ROW := 1
const OUTLET_ROW := 2

# Openings as bit flags.
const N := 1
const E := 2
const S := 4
const W := 8

enum Kind { EMPTY, STRAIGHT, CORNER, TEE }

## Openings of each piece at rotation 0.
const BASE := {
	Kind.EMPTY: 0,
	Kind.STRAIGHT: N | S,
	Kind.CORNER: N | E,
	Kind.TEE: N | E | W,
}

## Pieces row by row (ROWS x COLS).
const KINDS := [
	Kind.CORNER, Kind.STRAIGHT, Kind.TEE, Kind.CORNER, Kind.STRAIGHT,
	Kind.STRAIGHT, Kind.CORNER, Kind.STRAIGHT, Kind.TEE, Kind.CORNER,
	Kind.CORNER, Kind.CORNER, Kind.STRAIGHT, Kind.TEE, Kind.STRAIGHT,
	Kind.TEE, Kind.STRAIGHT, Kind.CORNER, Kind.EMPTY, Kind.CORNER,
]

## Rotations (clockwise quarter turns) the player starts with: scrambled, not solved.
const START_ROTATIONS := [
	2, 1, 3, 0, 1,
	0, 0, 1, 2, 3,
	1, 0, 0, 1, 0,
	3, 0, 2, 0, 1,
]

## One valid route: cell index -> rotation that makes it part of the path.
const SOLUTION_PATH := {
	5: 1,    # (col 0, row 1) straight, east-west
	6: 2,    # (col 1, row 1) corner, west-south
	11: 0,   # (col 1, row 2) corner, north-east
	12: 1,   # (col 2, row 2) straight, east-west
	13: 0,   # (col 3, row 2) tee, west-east-north
	14: 1,   # (col 4, row 2) straight, east-west
}


static func index_of(col: int, row: int) -> int:
	return row * COLS + col


static func rotate_mask(mask: int, quarter_turns: int) -> int:
	var m := mask
	for _i in posmod(quarter_turns, 4):
		m = ((m << 1) | (m >> 3)) & 15
	return m


static func openings(index: int, rotations: Array) -> int:
	return rotate_mask(BASE[KINDS[index]], rotations[index])


static func opposite(dir: int) -> int:
	match dir:
		N: return S
		E: return W
		S: return N
		_: return E


## Cells reached by the steam: {index: true}.
static func wet_cells(rotations: Array) -> Dictionary:
	var wet := {}
	var start := index_of(0, SOURCE_ROW)
	if not (openings(start, rotations) & W):
		return wet
	var queue: Array[int] = [start]
	wet[start] = true
	while not queue.is_empty():
		var cur: int = queue.pop_front()
		var col := cur % COLS
		var row := cur / COLS
		var mask := openings(cur, rotations)
		for dir in [N, E, S, W]:
			if not (mask & dir):
				continue
			var nc := col + (1 if dir == E else (-1 if dir == W else 0))
			var nr := row + (1 if dir == S else (-1 if dir == N else 0))
			if nc < 0 or nc >= COLS or nr < 0 or nr >= ROWS:
				continue
			var ni := index_of(nc, nr)
			if wet.has(ni):
				continue
			if openings(ni, rotations) & opposite(dir):
				wet[ni] = true
				queue.append(ni)
	return wet


static func is_solved(rotations: Array) -> bool:
	var goal := index_of(COLS - 1, OUTLET_ROW)
	return wet_cells(rotations).has(goal) and (openings(goal, rotations) & E) != 0


static func start_state() -> Array:
	return START_ROTATIONS.duplicate()


static func solved_state() -> Array:
	var r := START_ROTATIONS.duplicate()
	for idx: int in SOLUTION_PATH:
		r[idx] = SOLUTION_PATH[idx]
	return r
