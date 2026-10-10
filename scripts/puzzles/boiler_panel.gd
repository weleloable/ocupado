class_name BoilerPanel
extends Interactable
## Boiler control cabinet on the east wall. Opens the pipes puzzle; once solved, its screen shows
## the digit that the puzzle reveals. Local space: +Z points into the room.

var _screen_label: Label3D
var _lamp_mat: StandardMaterial3D
var _looked: bool = false


func _ready() -> void:
	prompt_text = "Revisar la caldera"
	add_mesh_box(Vector3(0.44, 0.54, 0.1), Vector3(0, 0, 0.05), Build.mat(Color(0.42, 0.46, 0.45)))
	add_mesh_box(Vector3(0.4, 0.5, 0.012), Vector3(0, 0, 0.104), Build.mat(Color(0.33, 0.37, 0.36)))
	Build.label_fit(self, "CALDERA", Vector3(0, 0.215, 0.112), 0.0, Vector2(0.3, 0.05), Color(0.95, 0.9, 0.7))
	# Screen and status lamp.
	add_mesh_box(Vector3(0.32, 0.1, 0.01), Vector3(0, 0.12, 0.112), Build.mat(Color(0.03, 0.06, 0.04)))
	_screen_label = Build.label_fit(self, "-  -  -  -", Vector3(0, 0.12, 0.12), 0.0, Vector2(0.26, 0.07), Color(0.2, 0.55, 0.3))
	_lamp_mat = Build.mat_unique(Color(0.85, 0.1, 0.08), 2.0, true)
	add_mesh_box(Vector3(0.04, 0.04, 0.012), Vector3(0.16, 0.21, 0.112), _lamp_mat)
	# Broken pipe diagram: stubs with gaps.
	var blue := Build.mat(Color(0.35, 0.5, 0.65), 0.3)
	add_mesh_box(Vector3(0.1, 0.02, 0.01), Vector3(-0.13, -0.06, 0.112), blue)
	add_mesh_box(Vector3(0.1, 0.02, 0.01), Vector3(0.03, -0.06, 0.112), blue)
	add_mesh_box(Vector3(0.02, 0.1, 0.01), Vector3(0.13, -0.12, 0.112), blue)
	add_mesh_box(Vector3(0.1, 0.02, 0.01), Vector3(-0.13, -0.18, 0.112), blue)
	add_mesh_box(Vector3(0.1, 0.02, 0.01), Vector3(0.03, -0.18, 0.112), blue)
	add_shape(Vector3(0.48, 0.58, 0.18), Vector3(0, 0, 0.09))
	GameState.pipes_solved.connect(_on_solved)


func interact() -> void:
	if GameState.pipes_done:
		GameState.say("boiler_done")
		return
	if not _looked:
		_looked = true
		GameState.say("boiler_look")
	GameState.pipes_ui_requested.emit()


func _on_solved() -> void:
	prompt_text = "Mirar la caldera"
	_screen_label.text = GameState.digit_pattern(GameState.DIGIT_TRIALS["pipes"])
	_screen_label.modulate = Color(0.3, 1.0, 0.4)
	_lamp_mat.albedo_color = Color(0.2, 1.0, 0.3)
	_lamp_mat.emission = Color(0.2, 1.0, 0.3)
