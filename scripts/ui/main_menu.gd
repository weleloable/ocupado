class_name MainMenu
extends CanvasLayer
## Title screen.

signal play_pressed


func _ready() -> void:
	var root := UiUtil.full_rect_control(self)
	var bg := UiUtil.rect(root, Color(0.1, 0.16, 0.13), Vector2.ZERO, UiUtil.VIEW)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	# Tile stripes for flavour.
	for i in 12:
		UiUtil.rect(root, Color(1, 1, 1, 0.03), Vector2(i * 56, 0), Vector2(2, 360))
	UiUtil.rect(root, Color(0.75, 0.1, 0.1), Vector2(200, 40), Vector2(240, 64))
	UiUtil.label(root, "OCUPADO", Vector2(200, 46), Vector2(240, 52), 44, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 6)
	UiUtil.label(root, "Un escape room en el baño de un bar.\nTu cerveza se calienta. Tú verás.",
			Vector2(0, 112), Vector2(640, 36), 13, Color(0.9, 0.9, 0.8), HORIZONTAL_ALIGNMENT_CENTER)

	var play := UiUtil.button(root, "Jugar", Vector2(250, 162), Vector2(140, 34), 16)
	play.pressed.connect(play_pressed.emit)
	# En web "Salir" no puede cerrar nada (la pestana o la app son del navegador).
	if not OS.has_feature("web"):
		var quit := UiUtil.button(root, "Salir", Vector2(250, 204), Vector2(140, 34), 16)
		quit.pressed.connect(func() -> void: get_tree().quit())

	var controles := "WASD moverse  ·  Ratón mirar  ·  E / clic interactuar\nH pedir pista por el móvil  ·  Esc pausa"
	if TouchControls.activo():
		controles = "Izquierda: muévete  ·  Derecha: arrastra para mirar\nToca o pulsa USAR para usar  ·  Móvil: pistas"
	UiUtil.label(root, controles,
			Vector2(0, 262), Vector2(640, 36), 12, Color(0.75, 0.85, 0.75), HORIZONTAL_ALIGNMENT_CENTER)
	UiUtil.label(root, "Finales descubiertos: %d/%d" % [GameState.discovered_endings().size(), GameState.ENDING_IDS.size()],
			Vector2(0, 304), Vector2(640, 16), 11, Color(0.7, 0.85, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	UiUtil.label(root, "Game jam · Godot " + Engine.get_version_info()["string"], Vector2(0, 336),
			Vector2(632, 16), 9, Color(1, 1, 1, 0.35), HORIZONTAL_ALIGNMENT_RIGHT, 0)
