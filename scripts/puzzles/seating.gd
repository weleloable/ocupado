class_name SeatingPuzzle
extends RefCounted
## Pure logic of the coaster riddle: four friends sit in seats 1..4 (left to right) at the bar.
## The four coaster statements have exactly one solution.

const NAMES := ["Paco", "Lucía", "Javi", "Marta"]
const SOLUTION := ["Javi", "Marta", "Lucía", "Paco"]
## Seat (1-based) of the friend who drank the beer, written in the final digit of the code.
const CULPRIT_SEAT := 2

const STATEMENTS := [
	"PACO se sienta en un extremo de la barra.",
	"MARTA está justo a la izquierda de LUCÍA.",
	"JAVI no está al lado de PACO.",
	"LUCÍA está más a la derecha que JAVI.",
]


## Which of the four statements hold for `seats` (names in seats 1..4; "" = empty).
static func satisfied(seats: Array) -> Array[bool]:
	var out: Array[bool] = [false, false, false, false]
	var paco := seats.find("Paco")
	var marta := seats.find("Marta")
	var lucia := seats.find("Lucía")
	var javi := seats.find("Javi")
	if paco < 0 or marta < 0 or lucia < 0 or javi < 0:
		return out
	out[0] = paco == 0 or paco == 3
	out[1] = marta + 1 == lucia
	out[2] = absi(javi - paco) != 1
	out[3] = lucia > javi
	return out


static func is_solution(seats: Array) -> bool:
	if seats.size() != 4:
		return false
	for name: String in NAMES:
		if seats.count(name) != 1:
			return false
	for ok in satisfied(seats):
		if not ok:
			return false
	return true


static func culprit() -> String:
	return SOLUTION[CULPRIT_SEAT - 1]


## Brute force over all 24 arrangements: how many satisfy every statement.
static func count_solutions() -> int:
	var count := 0
	for a in NAMES:
		for b in NAMES:
			for c in NAMES:
				for d in NAMES:
					if is_solution([a, b, c, d]):
						count += 1
	return count
