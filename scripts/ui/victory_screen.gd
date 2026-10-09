class_name VictoryScreen
extends CanvasLayer
## End screen: ending reached, time, beer temperature and verdict.

signal replay_pressed
signal menu_pressed


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := UiUtil.full_rect_control(self)
	var bg := UiUtil.rect(root, Color(0.12, 0.07, 0.03, 0.0), Vector2.ZERO, UiUtil.VIEW)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	create_tween().tween_property(bg, "color:a", 0.92, 0.8)

	var temp := GameState.final_temp
	var info: Dictionary = Lines.ENDINGS.get(GameState.ending, Lines.ENDINGS["door"])
	UiUtil.label(root, str(info["title"]), Vector2(0, 26), Vector2(640, 50), 40, Color(1.0, 0.8, 0.3), HORIZONTAL_ALIGNMENT_CENTER, 6)
	UiUtil.label(root, str(info["name"]), Vector2(0, 76), Vector2(640, 16), 11, Color(0.7, 0.85, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	UiUtil.label(root, str(info["subtitle"]), Vector2(20, 94), Vector2(600, 18), 13,
			Color(0.9, 0.9, 0.85), HORIZONTAL_ALIGNMENT_CENTER)
	UiUtil.label(root, "Tiempo: %s" % GameState.format_time(GameState.final_time), Vector2(0, 126),
			Vector2(640, 20), 16, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	UiUtil.label(root, "Temperatura de la cerveza: %.1f °C" % temp, Vector2(0, 150), Vector2(640, 20), 16,
			Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	UiUtil.label(root, "Pistas pedidas: %d" % GameState.hints_used, Vector2(0, 174), Vector2(640, 18), 12,
			Color(0.8, 0.8, 0.8), HORIZONTAL_ALIGNMENT_CENTER)
	UiUtil.label(root, "\"%s\"" % GameState.verdict(temp, GameState.ending), Vector2(20, 200), Vector2(600, 24), 17,
			Color(1.0, 0.85, 0.4), HORIZONTAL_ALIGNMENT_CENTER)
	var found := GameState.discovered_endings().size()
	UiUtil.label(root, "Finales descubiertos: %d/%d" % [found, GameState.ENDING_IDS.size()], Vector2(0, 228),
			Vector2(640, 16), 11, Color(0.7, 0.85, 1.0), HORIZONTAL_ALIGNMENT_CENTER)

	UiUtil.button(root, "Volver a jugar", Vector2(240, 256), Vector2(160, 32)).pressed.connect(replay_pressed.emit)
	UiUtil.button(root, "Menú principal", Vector2(240, 298), Vector2(160, 32)).pressed.connect(menu_pressed.emit)
