class_name Phone
extends CanvasLayer
## Mobile phone overlay: the friends' group chat (each hint costs 1 °C), a line with the code digits
## found so far, and the riddles of the brother-in-law (right answer -1 °C, wrong answer +1 °C).

signal closed

const FRIEND_COLORS := {
	"Paco": "#b03030", "Lucía": "#2a6fb0", "Javi": "#2f8a3a", "Marta": "#9a4fb0", "Tú": "#555555",
}
const INK := Color(0.08, 0.1, 0.12)

var _messages: VBoxContainer
var _scroll: ScrollContainer
var _code_label: Label
var _chat_view: Control
var _riddle_view: Control
var _riddle_question: Label
var _riddle_feedback: Label
var _riddle_buttons: Array[Button] = []
var _mode_button: Button
var _riddle_mode: bool = false


func _ready() -> void:
	layer = 5
	visible = false
	var root := UiUtil.full_rect_control(self)
	UiUtil.rect(root, Color(0, 0, 0, 0.35), Vector2.ZERO, UiUtil.VIEW)
	var body := UiUtil.rect(root, Color(0.07, 0.07, 0.09), Vector2(372, 14), Vector2(210, 334))
	body.mouse_filter = Control.MOUSE_FILTER_STOP
	var screen := UiUtil.rect(body, Color(0.88, 0.92, 0.86), Vector2(8, 18), Vector2(194, 284))
	UiUtil.rect(screen, Color(0.1, 0.45, 0.35), Vector2.ZERO, Vector2(194, 22))
	UiUtil.label(screen, "LOS DEL BAR (4)", Vector2(6, 3), Vector2(182, 16), 11, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, 0)
	UiUtil.rect(screen, Color(0.72, 0.82, 0.74), Vector2(0, 22), Vector2(194, 17))
	_code_label = UiUtil.label(screen, "", Vector2(0, 23), Vector2(194, 15), 11, INK, HORIZONTAL_ALIGNMENT_CENTER, 0)

	# Chat view.
	_chat_view = Control.new()
	_chat_view.position = Vector2(4, 42)
	_chat_view.size = Vector2(186, 204)
	screen.add_child(_chat_view)
	_scroll = ScrollContainer.new()
	_scroll.size = Vector2(186, 204)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_chat_view.add_child(_scroll)
	_messages = VBoxContainer.new()
	_messages.custom_minimum_size = Vector2(176, 0)
	_messages.add_theme_constant_override("separation", 6)
	_scroll.add_child(_messages)

	# Riddle view.
	_riddle_view = Control.new()
	_riddle_view.position = Vector2(4, 42)
	_riddle_view.size = Vector2(186, 204)
	_riddle_view.visible = false
	screen.add_child(_riddle_view)
	UiUtil.label(_riddle_view, "Javi (el cuñado):", Vector2(2, 0), Vector2(180, 14), 11, Color(0.18, 0.5, 0.22), HORIZONTAL_ALIGNMENT_LEFT, 0)
	_riddle_question = UiUtil.label(_riddle_view, "", Vector2(2, 16), Vector2(180, 72), 11, INK, HORIZONTAL_ALIGNMENT_LEFT, 0)
	_riddle_question.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for i in 3:
		var b := UiUtil.button(_riddle_view, "", Vector2(2, 92 + i * 34), Vector2(180, 30), 11)
		b.pressed.connect(_on_answer.bind(i))
		_riddle_buttons.append(b)
	_riddle_feedback = UiUtil.label(_riddle_view, "", Vector2(2, 192), Vector2(180, 12), 10, Color(0.3, 0.3, 0.35), HORIZONTAL_ALIGNMENT_LEFT, 0)

	# Bottom buttons.
	var hint_button := UiUtil.button(screen, "Pista (+1 °C)", Vector2(5, 252), Vector2(88, 26), 10)
	hint_button.pressed.connect(request_hint)
	_mode_button = UiUtil.button(screen, "Acertijo (Javi)", Vector2(99, 252), Vector2(90, 26), 10)
	_mode_button.pressed.connect(func() -> void: _set_riddle_mode(not _riddle_mode))
	UiUtil.label(body, "[H] o [Esc] para guardarlo", Vector2(0, 308), Vector2(210, 14), 10,
			Color(0.75, 0.75, 0.75), HORIZONTAL_ALIGNMENT_CENTER, 0)

	_add_message("Javi", "¿Dónde te has metido? Te hemos pedido otra caña.")
	_add_message("Lucía", "Si te has vuelto a quedar encerrado, pide pista. Te ayudamos. A nuestra manera.")
	_add_message("Paco", "Si tardas mucho me la bebo yo, aviso.")
	_add_message("Javi", "Y si te aburres, dale a «Acertijo». Tengo uno buenísimo.")
	GameState.digit_revealed.connect(func(_trial: String, _pos: int) -> void: _refresh_code())
	_refresh_code()


func open() -> void:
	visible = true
	_refresh_code()
	_scroll_to_bottom()


func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


func request_hint() -> void:
	_add_message("Tú", "Ayuda. Sigo en el baño.")
	var hint := GameState.request_hint()
	_add_message(str(hint["friend"]), str(hint["text"]))
	Sfx.play("phone")
	GameState.say("hint_used")
	_set_riddle_mode(false)


func _refresh_code() -> void:
	_code_label.text = "CÓDIGO   " + GameState.code_so_far()


func _set_riddle_mode(on: bool) -> void:
	_riddle_mode = on
	_chat_view.visible = not on
	_riddle_view.visible = on
	_mode_button.text = "Volver al chat" if on else "Acertijo (Javi)"
	if on:
		_riddle_feedback.text = ""
		_refresh_riddle()
	else:
		_scroll_to_bottom()


func _refresh_riddle() -> void:
	var idx := GameState.riddles_solved
	if idx >= Riddles.LIST.size():
		_riddle_question.text = "Javi se ha quedado sin acertijos. Por hoy. Te ha dejado la cuenta."
		for b in _riddle_buttons:
			b.visible = false
		return
	var riddle: Dictionary = Riddles.LIST[idx]
	_riddle_question.text = "(%d/%d) %s" % [idx + 1, Riddles.LIST.size(), riddle["question"]]
	var options: Array = riddle["options"]
	for i in 3:
		_riddle_buttons[i].visible = true
		_riddle_buttons[i].text = str(options[i])


func _on_answer(i: int) -> void:
	var idx := GameState.riddles_solved
	if idx >= Riddles.LIST.size():
		return
	var ok: bool = i == int(Riddles.LIST[idx]["answer"])
	GameState.answer_riddle(ok)
	Sfx.play("phone")
	if ok:
		GameState.say("riddle_right")
		_riddle_feedback.text = "¡Toma! Lo sabía. (-1 °C)"
		_refresh_riddle()
		if GameState.riddles_solved >= Riddles.LIST.size():
			GameState.say("riddle_done")
	else:
		GameState.say("riddle_wrong")
		_riddle_feedback.text = "No, hombre, no. (+1 °C)"


func _add_message(friend: String, text: String) -> void:
	var rtl := RichTextLabel.new()
	rtl.bbcode_enabled = true
	rtl.fit_content = true
	rtl.scroll_active = false
	rtl.custom_minimum_size = Vector2(176, 0)
	rtl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rtl.add_theme_color_override("default_color", Color(0.1, 0.1, 0.12))
	rtl.add_theme_font_size_override("normal_font_size", 11)
	rtl.add_theme_font_size_override("bold_font_size", 11)
	var color: String = FRIEND_COLORS.get(friend, "#333333")
	rtl.text = "[b][color=%s]%s:[/color][/b] %s" % [color, friend, text]
	_messages.add_child(rtl)
	_scroll_to_bottom()


func _scroll_to_bottom() -> void:
	var t := create_tween()
	t.tween_interval(0.05)
	t.tween_callback(func() -> void: _scroll.scroll_vertical = int(_scroll.get_v_scroll_bar().max_value))
