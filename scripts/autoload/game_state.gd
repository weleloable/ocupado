extends Node
## Global game progress: puzzles, time, beer temperature and signals.

signal narration_requested(text: String)
signal lights_turned_on
signal ritual_progressed(step: int)
signal ritual_solved
signal mirror_revealed
signal keypad_ui_requested
signal keypad_solved
signal game_won
## The hot tap was opened with the valve closed: tells the valve to flash.
signal valve_hint
## The steam valve was turned (true = open).
signal valve_changed(open: bool)
signal pipes_ui_requested
signal pipes_solved
signal table_ui_requested
signal coasters_solved
## A trial revealed one digit of the keypad code (`position` is 0..3).
signal digit_revealed(trial: String, position: int)

enum RitualResult { IGNORED, PROGRESS, FAIL, SOLVED }

const START_TEMP := 4.0
const SECONDS_PER_DEGREE := 40.0
const RITUAL_SEQUENCE := ["dryer", "mop", "chain", "cold_tap", "dryer"]
const CODE := "3312"
## Which digit of CODE each trial reveals (one digit per trial, 4 trials).
const DIGIT_TRIALS := {"mirror": 0, "pipes": 1, "ritual": 2, "coasters": 3}
const MIN_TEMP := 2.0
const ENDINGS_PATH := "user://endings.cfg"
const ENDING_IDS := ["door", "flood"]

## When true, main.gd skips the menu (used by "Reiniciar" / "Volver a jugar").
var skip_menu: bool = false
## True while an overlay (phone, keypad, pause, victory) owns the input.
var controls_locked: bool = false

var running: bool = false
var elapsed: float = 0.0
var hints_used: int = 0
var lights_on: bool = false
var ritual_done: bool = false
var ritual_step: int = 0
var mirror_done: bool = false
var keypad_done: bool = false
var pipes_done: bool = false
var coasters_done: bool = false
## digits_found[i] is true once the trial of position i revealed CODE[i].
var digits_found: Array[bool] = [false, false, false, false]
## Coasters read so far (indexes 0..3), shown on the table board.
var coasters_read: Array[bool] = [false, false, false, false]
## Riddles answered by the brother-in-law in the phone: right ones cool the beer, wrong ones heat it.
var riddles_solved: int = 0
var temp_adjust: float = 0.0
var won: bool = false
var final_time: float = 0.0
var final_temp: float = 0.0
var hint_levels: Dictionary = {}
## Hot-water valve (red wheel on the toilet pipe) and sink plug: part of the mirror / flood mechanics.
var valve_open: bool = false
var plug_in: bool = false
## Which ending was reached ("door" or "flood").
var ending: String = "door"
## Debug runs (autotest, screenshots) set this to false so they never touch the real save.
var persist_endings: bool = true


func _ready() -> void:
	InputSetup.register()


func reset() -> void:
	running = false
	controls_locked = false
	elapsed = 0.0
	hints_used = 0
	lights_on = false
	ritual_done = false
	ritual_step = 0
	mirror_done = false
	keypad_done = false
	pipes_done = false
	coasters_done = false
	digits_found = [false, false, false, false]
	coasters_read = [false, false, false, false]
	riddles_solved = 0
	temp_adjust = 0.0
	won = false
	final_time = 0.0
	final_temp = 0.0
	hint_levels = {}
	valve_open = false
	plug_in = false
	ending = "door"


func start() -> void:
	reset()
	running = true


func _process(delta: float) -> void:
	if running and not won:
		elapsed += delta


func get_temperature() -> float:
	return maxf(MIN_TEMP, START_TEMP + elapsed / SECONDS_PER_DEGREE + float(hints_used) + temp_adjust)


func say(event: String) -> void:
	var text := Lines.pick(event)
	if not text.is_empty():
		narration_requested.emit(text)


func say_text(text: String) -> void:
	narration_requested.emit(text)


# --- Puzzle 1: breaker panel ---

func solve_lights() -> void:
	if lights_on:
		return
	lights_on = true
	lights_turned_on.emit()
	say("breaker_solved")


# --- Puzzle 2: ritual ---

## Feeds one ritual element. Only counts while the black light is on.
func ritual_input(id: String) -> RitualResult:
	if not lights_on or ritual_done:
		return RitualResult.IGNORED
	if id == RITUAL_SEQUENCE[ritual_step]:
		ritual_step += 1
		if ritual_step >= RITUAL_SEQUENCE.size():
			solve_ritual()
			return RitualResult.SOLVED
		ritual_progressed.emit(ritual_step)
		return RitualResult.PROGRESS
	var had_progress := ritual_step > 0
	ritual_step = 1 if id == RITUAL_SEQUENCE[0] else 0
	if had_progress:
		return RitualResult.FAIL
	return RitualResult.IGNORED


## Convenience for ritual devices: feeds the ritual and narrates the outcome.
func ritual_action(id: String, idle_event: String) -> void:
	match ritual_input(id):
		RitualResult.PROGRESS:
			Sfx.play("tick")
			say("ritual_clue_%d" % ritual_step)
		RitualResult.FAIL:
			Sfx.play("error", -6.0)
			say("ritual_fail")
		RitualResult.IGNORED:
			if not idle_event.is_empty():
				say(idle_event)
		RitualResult.SOLVED:
			pass


func solve_ritual() -> void:
	if ritual_done:
		return
	ritual_done = true
	ritual_step = RITUAL_SEQUENCE.size()
	ritual_solved.emit()
	say("ritual_solved")
	reveal_digit("ritual")


# --- Puzzle 3: mirror ---

func solve_mirror() -> void:
	if mirror_done:
		return
	mirror_done = true
	mirror_revealed.emit()
	say("mirror_reveal")
	reveal_digit("mirror")


# --- Puzzle: boiler pipes ---

func solve_pipes() -> void:
	if pipes_done:
		return
	pipes_done = true
	pipes_solved.emit()
	say("pipes_solved")
	reveal_digit("pipes")


# --- Riddle: coasters (who drank your beer) ---

## The player read coaster `index` (0..3).
func read_coaster(index: int) -> void:
	coasters_read[index] = true


func solve_coasters() -> void:
	if coasters_done:
		return
	coasters_done = true
	coasters_solved.emit()
	say("coasters_solved")
	reveal_digit("coasters")


# --- Digits of the keypad code ---

func reveal_digit(trial: String) -> void:
	var pos: int = DIGIT_TRIALS[trial]
	if digits_found[pos]:
		return
	digits_found[pos] = true
	digit_revealed.emit(trial, pos)


## "3  _  _  2": the digits found so far, in place.
func code_so_far() -> String:
	var parts: Array[String] = []
	for i in CODE.length():
		parts.append(CODE[i] if digits_found[i] else "_")
	return "  ".join(parts)


## "_  _  1  _": only the digit at `position`, as written on the object that reveals it.
static func digit_pattern(position: int) -> String:
	var parts: Array[String] = []
	for i in CODE.length():
		parts.append(CODE[i] if i == position else "_")
	return "  ".join(parts)


## Brother-in-law riddles: right answer cools the beer, wrong one heats it (1 °C each).
func answer_riddle(correct: bool) -> void:
	if correct:
		riddles_solved += 1
		temp_adjust -= 1.0
	else:
		temp_adjust += 1.0


# --- Puzzle 4: keypad ---

func solve_keypad() -> void:
	if keypad_done:
		return
	keypad_done = true
	keypad_solved.emit()
	say("keypad_correct")


func win(ending_id: String = "door") -> void:
	if won:
		return
	won = true
	ending = ending_id
	final_time = elapsed
	final_temp = get_temperature()
	if persist_endings:
		_save_ending(ending_id)
	game_won.emit()


# --- Endings discovered (saved between sessions) ---

static func discovered_endings() -> Array[String]:
	var found: Array[String] = []
	var cfg := ConfigFile.new()
	if cfg.load(ENDINGS_PATH) == OK:
		for id: String in ENDING_IDS:
			if cfg.get_value("endings", id, false):
				found.append(id)
	return found


func _save_ending(id: String) -> void:
	var cfg := ConfigFile.new()
	cfg.load(ENDINGS_PATH)  # ok if the file does not exist yet
	cfg.set_value("endings", id, true)
	cfg.save(ENDINGS_PATH)


# --- Hints ---

func current_puzzle() -> String:
	if not lights_on:
		return "breaker"
	if not ritual_done:
		return "ritual"
	if not mirror_done:
		return "mirror"
	if not pipes_done:
		return "pipes"
	if not coasters_done:
		return "coasters"
	if not keypad_done:
		return "keypad"
	return "door"


## Returns {"friend": String, "text": String} and charges 1 °C.
func request_hint() -> Dictionary:
	var puzzle := current_puzzle()
	var level: int = hint_levels.get(puzzle, 0)
	var hints: Array = Lines.HINTS[puzzle]
	var entry: Array = hints[mini(level, hints.size() - 1)]
	hint_levels[puzzle] = level + 1
	hints_used += 1
	return {"friend": str(entry[0]), "text": str(entry[1])}


static func verdict(temp: float, ending_id: String = "door") -> String:
	var pool: Array = Lines.VERDICTS.get(ending_id, Lines.VERDICTS["door"])
	if temp < 8.0:
		return pool[0]
	if temp < 14.0:
		return pool[1]
	if temp < 20.0:
		return pool[2]
	return pool[3]


static func format_time(seconds: float) -> String:
	var total := int(seconds)
	return "%d:%02d" % [total / 60, total % 60]
