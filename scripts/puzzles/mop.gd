class_name Mop
extends Interactable
## The mop, "la veterana de 2009". Decoration that is also a ritual element.


func _ready() -> void:
	prompt_text = "Tocar la fregona"
	add_mesh_cylinder(0.17, 0.28, Vector3(0, 0.14, 0), Build.mat(Color(0.85, 0.7, 0.15)))
	add_mesh_cylinder(0.015, 1.3, Vector3(0.05, 0.8, 0.0), Build.mat(Color(0.25, 0.4, 0.8)), Vector3(0, 0, -0.12))
	add_mesh_box(Vector3(0.2, 0.1, 0.2), Vector3(-0.02, 0.28, 0), Build.mat(Color(0.7, 0.68, 0.6)))
	add_shape(Vector3(0.4, 1.45, 0.4), Vector3(0, 0.72, 0))


func interact() -> void:
	Sfx.play("click", -4.0, 0.7)
	var t := create_tween()
	t.tween_property(self, "rotation:z", 0.05, 0.08)
	t.tween_property(self, "rotation:z", -0.05, 0.1)
	t.tween_property(self, "rotation:z", 0.0, 0.08)
	GameState.ritual_action("mop", "mop")
