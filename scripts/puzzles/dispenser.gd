class_name Dispenser
extends Interactable
## Metal paper dispenser. Opens when the ritual is completed, revealing the note "_ _ 1 2".

var _lid_pivot: Node3D
var _open: bool = false


func _ready() -> void:
	prompt_text = "Abrir el dispensador"
	var metal := Build.mat(Color(0.62, 0.63, 0.66))
	add_mesh_box(Vector3(0.36, 0.42, 0.12), Vector3(0, 0, 0.06), metal)
	# Note, hidden behind the lid.
	Build.box(self, Vector3(0.27, 0.27, 0.004), Vector3(0, 0.02, 0.123), Build.mat(Color(0.95, 0.93, 0.85)))
	Build.label_fit(self, "_  _  1  2", Vector3(0, 0.02, 0.127), 0.0, Vector2(0.21, 0.09), Color(0.1, 0.1, 0.15))
	# Lid hinged at the bottom.
	_lid_pivot = Node3D.new()
	_lid_pivot.position = Vector3(0, -0.21, 0.136)
	add_child(_lid_pivot)
	track_mesh(Build.box(_lid_pivot, Vector3(0.35, 0.41, 0.014), Vector3(0, 0.205, 0), metal))
	track_mesh(Build.box(_lid_pivot, Vector3(0.05, 0.05, 0.02), Vector3(0, 0.36, 0.012), Build.mat(Color(0.2, 0.2, 0.2))))
	Build.label_fit(_lid_pivot, "PAPEL", Vector3(0, 0.22, 0.009), 0.0, Vector2(0.26, 0.07), Color(0.15, 0.15, 0.2))
	add_shape(Vector3(0.38, 0.44, 0.16), Vector3(0, 0, 0.08))
	GameState.ritual_solved.connect(_on_ritual_solved)


func interact() -> void:
	if _open:
		GameState.say("dispenser_note")
	else:
		Sfx.play("rattle", -6.0)
		GameState.say("dispenser_closed")


func _on_ritual_solved() -> void:
	if _open:
		return
	_open = true
	prompt_text = "Leer la nota"
	Sfx.play("clunk")
	var t := create_tween()
	t.tween_property(_lid_pivot, "rotation:x", deg_to_rad(105.0), 0.5) \
			.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
