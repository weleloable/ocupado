class_name TableBoard
extends Interactable
## Cork board of "mesa 7". Opens the seating UI where the four friends are placed using the coaster
## statements. Once solved it shows who drank the beer and the digit it reveals.
## Local space: +Z points into the room.

var _result_label: Label3D


func _ready() -> void:
	prompt_text = "Ordenar la mesa 7"
	add_mesh_box(Vector3(0.74, 0.5, 0.03), Vector3(0, 0, 0.015), Build.mat(Color(0.35, 0.2, 0.1)))
	add_mesh_box(Vector3(0.68, 0.44, 0.02), Vector3(0, 0, 0.03), Build.mat(Color(0.72, 0.52, 0.32)))
	add_mesh_box(Vector3(0.5, 0.2, 0.006), Vector3(0, 0.1, 0.042), Build.mat(Color(0.97, 0.96, 0.9)))
	Build.label_fit(self, "MESA 7\n¿QUIÉN SE SENTABA\nDÓNDE?", Vector3(0, 0.1, 0.047), 0.0, Vector2(0.46, 0.17), Color(0.7, 0.08, 0.08))
	var pin := Build.mat(Color(0.85, 0.1, 0.1), 0.4)
	add_mesh_box(Vector3(0.025, 0.025, 0.012), Vector3(0, 0.19, 0.05), pin)
	# Paper that shows the result once solved.
	add_mesh_box(Vector3(0.34, 0.12, 0.006), Vector3(0, -0.1, 0.042), Build.mat(Color(0.97, 0.96, 0.9)))
	_result_label = Build.label_fit(self, "?\n_  _  _  _", Vector3(0, -0.1, 0.047), 0.0, Vector2(0.3, 0.1), Color(0.15, 0.15, 0.2))
	add_shape(Vector3(0.78, 0.54, 0.12), Vector3(0, 0, 0.06))
	GameState.coasters_solved.connect(_on_solved)


func interact() -> void:
	if GameState.coasters_done:
		GameState.say("board_done")
		return
	GameState.table_ui_requested.emit()


func _on_solved() -> void:
	prompt_text = "Mirar la mesa 7"
	_result_label.text = "SE LA BEBIÓ %s\n%s" % [SeatingPuzzle.culprit().to_upper(),
			GameState.digit_pattern(GameState.DIGIT_TRIALS["coasters"])]
