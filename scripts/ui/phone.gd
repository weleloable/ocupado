class_name Phone
extends CanvasLayer
## Mobile phone overlay with the friends' group chat. Each hint costs 1 °C.

signal closed

var _messages: VBoxContainer
var _scroll: ScrollContainer

const FRIEND_COLORS := {
	"Paco": "#b03030", "Lucía": "#2a6fb0", "Javi": "#2f8a3a", "Marta": "#9a4fb0", "Tú": "#555555",
}


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

	_scroll = ScrollContainer.new()
	_scroll.position = Vector2(4, 26)
	_scroll.size = Vector2(186, 220)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	screen.add_child(_scroll)
	_messages = VBoxContainer.new()
	_messages.custom_minimum_size = Vector2(176, 0)
	_messages.add_theme_constant_override("separation", 6)
	_scroll.add_child(_messages)

	var hint_button := UiUtil.button(screen, "Pedir pista (+1 °C)", Vector2(6, 252), Vector2(182, 26), 12)
	hint_button.pressed.connect(request_hint)
	UiUtil.label(body, "[H] o [Esc] para guardarlo", Vector2(0, 308), Vector2(210, 14), 10,
			Color(0.75, 0.75, 0.75), HORIZONTAL_ALIGNMENT_CENTER, 0)

	_add_message("Javi", "¿Dónde te has metido? Te hemos pedido otra caña.")
	_add_message("Lucía", "Si te has vuelto a quedar encerrado, pide pista. Te ayudamos. A nuestra manera.")
	_add_message("Paco", "Si tardas mucho me la bebo yo, aviso.")


func open() -> void:
	visible = true
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
