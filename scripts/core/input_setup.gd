class_name InputSetup
extends RefCounted
## Registers every input action by code so project.godot never needs manual edits.


static func register() -> void:
	_add_key("move_forward", KEY_W)
	_add_key("move_forward", KEY_UP)
	_add_key("move_back", KEY_S)
	_add_key("move_back", KEY_DOWN)
	_add_key("move_left", KEY_A)
	_add_key("move_left", KEY_LEFT)
	_add_key("move_right", KEY_D)
	_add_key("move_right", KEY_RIGHT)
	_add_key("interact", KEY_E)
	_add_mouse("interact", MOUSE_BUTTON_LEFT)
	_add_key("hint", KEY_H)
	_add_key("pause", KEY_ESCAPE)
	_add_key("debug_1", KEY_F1)
	_add_key("debug_2", KEY_F2)
	_add_key("debug_3", KEY_F3)
	_add_key("debug_4", KEY_F4)
	_add_key("debug_5", KEY_F5)
	_add_key("debug_6", KEY_F6)


static func _ensure(action: StringName) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)


static func _add_key(action: StringName, key: Key) -> void:
	_ensure(action)
	var ev := InputEventKey.new()
	ev.physical_keycode = key
	if not InputMap.action_has_event(action, ev):
		InputMap.action_add_event(action, ev)


static func _add_mouse(action: StringName, button: MouseButton) -> void:
	_ensure(action)
	var ev := InputEventMouseButton.new()
	ev.button_index = button
	if not InputMap.action_has_event(action, ev):
		InputMap.action_add_event(action, ev)
