class_name Keypad
extends Interactable
## 3D keypad next to the door. Opens the 2D keypad UI.

var _screen_mat: StandardMaterial3D


func _ready() -> void:
	prompt_text = "Usar el teclado"
	add_mesh_box(Vector3(0.2, 0.3, 0.04), Vector3(0, 0, 0.02), Build.mat(Color(0.18, 0.18, 0.2)))
	_screen_mat = Build.mat_unique(Color(0.8, 0.12, 0.08), 1.5, true)
	add_mesh_box(Vector3(0.15, 0.05, 0.01), Vector3(0, 0.1, 0.045), _screen_mat)
	var key_mat := Build.mat(Color(0.6, 0.6, 0.62))
	for r in 4:
		for c in 3:
			add_mesh_box(Vector3(0.036, 0.03, 0.012), Vector3((c - 1) * 0.048, 0.035 - r * 0.046, 0.046), key_mat)
	Build.label(self, "CÓDIGO", Vector3(0, 0.2, 0.02), 0.0, 32, Color(0.95, 0.95, 0.9), 0.0025, 0)
	add_shape(Vector3(0.26, 0.36, 0.1), Vector3(0, 0, 0.04))
	GameState.keypad_solved.connect(_on_solved)


func interact() -> void:
	if GameState.keypad_done:
		GameState.say("keypad_done")
	else:
		GameState.keypad_ui_requested.emit()


func _on_solved() -> void:
	prompt_text = "Mirar el teclado"
	_screen_mat.albedo_color = Color(0.15, 0.95, 0.25)
	_screen_mat.emission = Color(0.15, 0.95, 0.25)
