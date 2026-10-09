class_name HandDryer
extends Interactable
## Ritual element. Wall-mounted: local +Z points into the room.

const RUN_TIME := 2.4

var _busy: bool = false


func _ready() -> void:
	prompt_text = "Usar el secador de manos"
	var white := Build.mat(Color(0.85, 0.85, 0.82))
	add_mesh_box(Vector3(0.34, 0.28, 0.2), Vector3(0, 0, 0.1), white)
	add_mesh_cylinder(0.045, 0.1, Vector3(0, -0.18, 0.13), Build.mat(Color(0.6, 0.6, 0.62)))
	add_mesh_box(Vector3(0.12, 0.04, 0.01), Vector3(0, 0.06, 0.205), Build.mat(Color(0.15, 0.15, 0.15)))
	Build.label(self, "PULSE", Vector3(0, 0.06, 0.212), 0.0, 14, Color.WHITE, 0.003)
	add_shape(Vector3(0.38, 0.4, 0.26), Vector3(0, -0.04, 0.13))


func can_interact() -> bool:
	return enabled and not _busy


func interact() -> void:
	if _busy:
		return
	_busy = true
	Sfx.play("dryer")
	var base := position
	var t := create_tween()
	for _i in 12:
		t.tween_property(self, "position", base + Vector3(0.004, 0, 0), 0.05)
		t.tween_property(self, "position", base, 0.05)
	t.tween_interval(RUN_TIME - 1.2)
	t.tween_callback(func() -> void: _busy = false)
	GameState.ritual_action("dryer", "dryer_idle")
