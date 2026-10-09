class_name PauseMenu
extends CanvasLayer
## Pause overlay. Runs while the tree is paused.

signal resume_pressed
signal restart_pressed
signal quit_pressed


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	var root := UiUtil.full_rect_control(self)
	var dim := UiUtil.rect(root, Color(0, 0, 0, 0.7), Vector2.ZERO, UiUtil.VIEW)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	UiUtil.label(root, "PAUSA", Vector2(0, 70), Vector2(640, 40), 32, Color(1.0, 0.85, 0.4), HORIZONTAL_ALIGNMENT_CENTER)
	UiUtil.label(root, "La cerveza también se ha pausado. Por respeto.", Vector2(0, 112), Vector2(640, 16), 12,
			Color(0.8, 0.8, 0.8), HORIZONTAL_ALIGNMENT_CENTER)
	UiUtil.button(root, "Continuar", Vector2(240, 150), Vector2(160, 32)).pressed.connect(resume_pressed.emit)
	UiUtil.button(root, "Reiniciar", Vector2(240, 192), Vector2(160, 32)).pressed.connect(restart_pressed.emit)
	UiUtil.button(root, "Salir al menú", Vector2(240, 234), Vector2(160, 32)).pressed.connect(quit_pressed.emit)
