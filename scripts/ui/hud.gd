class_name Hud
extends CanvasLayer
## Crosshair, interaction prompt, beer thermometer and narrator.

const THERMO_H := 70.0
const T_MIN := 4.0
const T_MAX := 24.0

var player: Player
var prompt_label: Label
var _temp_label: Label
var _temp_fill: ColorRect
var _bulb: ColorRect


func _ready() -> void:
	layer = 1
	var root := UiUtil.full_rect_control(self)
	UiUtil.rect(root, Color(1, 1, 1, 0.85), Vector2(319, 179), Vector2(2, 2))
	prompt_label = UiUtil.label(root, "", Vector2(120, 194), Vector2(400, 20), 13,
			Color(1.0, 0.92, 0.6), HORIZONTAL_ALIGNMENT_CENTER)

	# Beer thermometer (top right).
	UiUtil.label(root, "TU CERVEZA", Vector2(530, 6), Vector2(100, 14), 10,
			Color(1.0, 0.85, 0.4), HORIZONTAL_ALIGNMENT_RIGHT)
	UiUtil.rect(root, Color(0, 0, 0, 0.6), Vector2(609, 22), Vector2(14, THERMO_H + 4))
	_temp_fill = UiUtil.rect(root, Color(0.5, 0.8, 1.0), Vector2(611, 24), Vector2(10, 0))
	_bulb = UiUtil.rect(root, Color(0.5, 0.8, 1.0), Vector2(606, 24 + THERMO_H), Vector2(20, 14))
	_temp_label = UiUtil.label(root, "", Vector2(520, 30), Vector2(84, 16), 13,
			Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT)

	UiUtil.label(root, "[H] Móvil   [Esc] Pausa", Vector2(8, 6), Vector2(200, 14), 10,
			Color(1, 1, 1, 0.6))

	add_child(Narrator.new())


func _process(_delta: float) -> void:
	var text := ""
	if player != null and not GameState.controls_locked and player.focused != null \
			and is_instance_valid(player.focused):
		text = "[E] " + player.focused.get_prompt()
	prompt_label.text = text
	_update_thermo(GameState.get_temperature())


func _update_thermo(temp: float) -> void:
	var ratio := clampf((temp - T_MIN) / (T_MAX - T_MIN), 0.04, 1.0)
	var h := THERMO_H * ratio
	_temp_fill.position.y = 24 + THERMO_H - h
	_temp_fill.size.y = h
	var c := Color(0.5, 0.8, 1.0).lerp(Color(1.0, 0.25, 0.1), clampf((temp - T_MIN) / 16.0, 0.0, 1.0))
	_temp_fill.color = c
	_bulb.color = c
	_temp_label.text = "%.1f °C" % temp
