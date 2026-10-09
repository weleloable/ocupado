class_name KeypadUi
extends CanvasLayer
## 2D numeric keypad overlay. Mouse or keyboard digits; Esc closes (handled by Game).

signal closed

var _display: Label
var _entered: String = ""
var _locked: bool = false


func _ready() -> void:
	layer = 5
	visible = false
	var root := UiUtil.full_rect_control(self)
	UiUtil.rect(root, Color(0, 0, 0, 0.45), Vector2.ZERO, UiUtil.VIEW)
	var panel := UiUtil.rect(root, Color(0.16, 0.16, 0.18), Vector2(215, 22), Vector2(210, 316))
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	UiUtil.label(panel, "SEGURIDAD BAÑO S.L.", Vector2(0, 4), Vector2(210, 16), 10,
			Color(0.7, 0.7, 0.7), HORIZONTAL_ALIGNMENT_CENTER, 0)
	UiUtil.rect(panel, Color(0.04, 0.08, 0.04), Vector2(16, 22), Vector2(178, 40))
	_display = UiUtil.label(panel, "", Vector2(16, 28), Vector2(178, 30), 22,
			Color(0.3, 1.0, 0.4), HORIZONTAL_ALIGNMENT_CENTER, 0)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.position = Vector2(19, 72)
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	panel.add_child(grid)
	for key in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "C", "0", "OK"]:
		var b := Button.new()
		b.text = key
		b.custom_minimum_size = Vector2(54, 44)
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 18)
		b.pressed.connect(_press.bind(key))
		grid.add_child(b)
	UiUtil.label(panel, "Teclea o pulsa. [Esc] cerrar", Vector2(0, 292), Vector2(210, 16), 10,
			Color(0.75, 0.75, 0.75), HORIZONTAL_ALIGNMENT_CENTER, 0)


func open() -> void:
	visible = true
	_entered = ""
	_locked = false
	_refresh()


func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


## Used by the debug autotest to type a code without the mouse.
func type_code(code: String) -> void:
	for c in code:
		_press(c)


func _press(key: String) -> void:
	if _locked:
		return
	if key == "C":
		_entered = ""
		Sfx.play("beep", 0.0, 0.8)
	elif key == "OK":
		if not _entered.is_empty():
			_submit()
			return
	elif _entered.length() < 4:
		_entered += key
		Sfx.play("beep")
		if _entered.length() == 4:
			_refresh()
			_submit()
			return
	_refresh()


func _submit() -> void:
	_locked = true
	if _entered == GameState.CODE:
		_display.text = "ABIERTO"
		_display.label_settings.font_color = Color(0.3, 1.0, 0.4)
		Sfx.play("success")
		GameState.solve_keypad()
		await get_tree().create_timer(1.2).timeout
		close()
	else:
		_display.text = "ERROR"
		_display.label_settings.font_color = Color(1.0, 0.25, 0.2)
		Sfx.play("error")
		GameState.say("keypad_wrong")
		await get_tree().create_timer(0.8).timeout
		_entered = ""
		_locked = false
		_refresh()


func _refresh() -> void:
	_display.label_settings.font_color = Color(0.3, 1.0, 0.4)
	var shown := ""
	for i in 4:
		shown += (_entered[i] if i < _entered.length() else "_") + (" " if i < 3 else "")
	_display.text = shown


func _input(event: InputEvent) -> void:
	if not visible or not (event is InputEventKey):
		return
	var k := event as InputEventKey
	if not k.pressed or k.echo:
		return
	var code := k.keycode
	if code >= KEY_0 and code <= KEY_9:
		_press(str(code - KEY_0))
	elif code >= KEY_KP_0 and code <= KEY_KP_9:
		_press(str(code - KEY_KP_0))
	elif code == KEY_BACKSPACE:
		if not _locked and not _entered.is_empty():
			_entered = _entered.substr(0, _entered.length() - 1)
			_refresh()
	elif code == KEY_ENTER or code == KEY_KP_ENTER:
		_press("OK")
	else:
		return
	get_viewport().set_input_as_handled()
