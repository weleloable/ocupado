class_name TableUi
extends CanvasLayer
## 2D board of "mesa 7": place the four friends on the bar using the statements found on the
## coasters. Statements of coasters not read yet stay hidden.

signal closed

const CYCLE := ["", "Paco", "Lucía", "Javi", "Marta"]
const NAME_COLORS := {
	"Paco": Color(1.0, 0.55, 0.5), "Lucía": Color(0.55, 0.75, 1.0),
	"Javi": Color(0.55, 0.95, 0.6), "Marta": Color(0.85, 0.65, 1.0),
}

var seats: Array[String] = ["", "", "", ""]
var _seat_buttons: Array[Button] = []
var _statement_labels: Array[Label] = []
var _result: Label
var _locked: bool = false


func _ready() -> void:
	layer = 5
	visible = false
	var root := UiUtil.full_rect_control(self)
	UiUtil.rect(root, Color(0, 0, 0, 0.5), Vector2.ZERO, UiUtil.VIEW)
	var panel := UiUtil.rect(root, Color(0.3, 0.18, 0.09), Vector2(40, 20), Vector2(560, 320))
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	UiUtil.label(root, "MESA 7 · ¿QUIÉN SE SENTABA DÓNDE?", Vector2(0, 28), Vector2(640, 20), 16, Color(1.0, 0.9, 0.6), HORIZONTAL_ALIGNMENT_CENTER, 0)
	UiUtil.label(root, "Cuando te fuiste al baño, alguien se bebió tu caña. Colócalos en la barra.", Vector2(0, 50), Vector2(640, 16), 11,
			Color(0.9, 0.85, 0.75), HORIZONTAL_ALIGNMENT_CENTER, 0)

	UiUtil.label(root, "Lo que dicen los posavasos:", Vector2(56, 78), Vector2(250, 16), 12, Color(1.0, 0.9, 0.6), HORIZONTAL_ALIGNMENT_LEFT, 0)
	for i in 4:
		var l := UiUtil.label(root, "", Vector2(56, 98 + i * 42), Vector2(246, 40), 11, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, 0)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_statement_labels.append(l)

	UiUtil.label(root, "La barra (de izquierda a derecha):", Vector2(316, 78), Vector2(270, 16), 12, Color(1.0, 0.9, 0.6), HORIZONTAL_ALIGNMENT_LEFT, 0)
	for i in 4:
		UiUtil.label(root, "Asiento %d" % (i + 1), Vector2(316 + i * 68, 100), Vector2(64, 14), 10, Color(0.9, 0.85, 0.75), HORIZONTAL_ALIGNMENT_CENTER, 0)
		var b := UiUtil.button(root, "-", Vector2(316 + i * 68, 116), Vector2(64, 50), 13)
		b.pressed.connect(_on_seat_pressed.bind(i))
		_seat_buttons.append(b)
	UiUtil.rect(root, Color(0.55, 0.33, 0.15), Vector2(312, 170), Vector2(276, 8))
	var check := UiUtil.button(root, "Comprobar", Vector2(396, 192), Vector2(110, 28), 13)
	check.pressed.connect(check_seating)
	_result = UiUtil.label(root, "", Vector2(316, 230), Vector2(270, 70), 12, Color(1.0, 0.9, 0.5), HORIZONTAL_ALIGNMENT_LEFT, 0)
	_result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiUtil.label(root, "[Clic] cambia de amigo  ·  [Esc] cerrar", Vector2(0, 322), Vector2(640, 14), 10,
			Color(0.85, 0.8, 0.7), HORIZONTAL_ALIGNMENT_CENTER, 0)
	_refresh_statements()
	_refresh_seats()


func open() -> void:
	visible = true
	_refresh_statements()


func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


func _on_seat_pressed(index: int) -> void:
	if _locked:
		return
	seats[index] = CYCLE[(CYCLE.find(seats[index]) + 1) % CYCLE.size()]
	Sfx.play("click", -4.0, 1.2)
	_refresh_seats()
	_result.text = ""
	_refresh_statements()


func check_seating() -> void:
	if _locked:
		return
	if seats.has(""):
		_result.text = "Faltan amigos por sentar."
		return
	if GameState.coasters_read.has(false):
		_result.text = "Te faltan posavasos por leer: hay cuatro repartidos por el baño."
		GameState.say("board_missing")
		return
	if SeatingPuzzle.is_solution(seats):
		_locked = true
		_result.text = "Cuadra. Tu caña estaba delante del asiento %d: se la bebió %s." % [
				SeatingPuzzle.CULPRIT_SEAT, SeatingPuzzle.culprit()]
		Sfx.play("success")
		_refresh_statements(SeatingPuzzle.satisfied(seats))
		GameState.solve_coasters()
		var t := create_tween()
		t.tween_interval(2.2)
		t.tween_callback(close)
		return
	Sfx.play("error")
	GameState.say("board_wrong")
	var ok := SeatingPuzzle.satisfied(seats)
	var good := 0
	for v in ok:
		if v:
			good += 1
	_result.text = "No cuadra: se cumplen %d de 4 pistas (en verde)." % good
	_refresh_statements(ok)


## Debug autotest helper.
func set_seats_for_test(arrangement: Array) -> void:
	for i in 4:
		seats[i] = str(arrangement[i])
	_refresh_seats()


func _refresh_seats() -> void:
	for i in 4:
		var b := _seat_buttons[i]
		b.text = seats[i] if not seats[i].is_empty() else "-"
		var c: Color = NAME_COLORS.get(seats[i], Color.WHITE)
		b.add_theme_color_override("font_color", c)
		b.add_theme_color_override("font_hover_color", c)


## `feedback`: per statement true/false after a check (green/red); empty = neutral.
func _refresh_statements(feedback: Array = []) -> void:
	for i in 4:
		var l := _statement_labels[i]
		if GameState.coasters_read[i]:
			l.text = "%d. %s" % [i + 1, SeatingPuzzle.STATEMENTS[i]]
			var col := Color.WHITE
			if feedback.size() == 4:
				col = Color(0.5, 1.0, 0.55) if feedback[i] else Color(1.0, 0.5, 0.45)
			l.label_settings.font_color = col
		else:
			l.text = "%d. ??? (posavasos sin leer)" % (i + 1)
			l.label_settings.font_color = Color(0.7, 0.65, 0.6)
