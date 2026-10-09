class_name Hud
extends CanvasLayer
## Crosshair and interaction prompt.

var player: Player
var prompt_label: Label


func _ready() -> void:
	layer = 1
	var root := UiUtil.full_rect_control(self)
	UiUtil.rect(root, Color(1, 1, 1, 0.85), Vector2(319, 179), Vector2(2, 2))
	prompt_label = UiUtil.label(root, "", Vector2(120, 194), Vector2(400, 20), 13,
			Color(1.0, 0.92, 0.6), HORIZONTAL_ALIGNMENT_CENTER)


func _process(_delta: float) -> void:
	var text := ""
	if player != null and not GameState.controls_locked and player.focused != null \
			and is_instance_valid(player.focused):
		text = "[E] " + player.focused.get_prompt()
	prompt_label.text = text
