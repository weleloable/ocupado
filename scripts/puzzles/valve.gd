class_name Valve
extends Interactable
## Red hot-water valve on the toilet pipe. Without it open, the hot tap runs cold.
## Local space: +Z points into the room, the pipe runs vertically through the origin.
## It flashes when the player opens the hot tap with the valve closed (see GameState.valve_hint).

var _wheel: Node3D
var _angle: float = 0.0
var _red: StandardMaterial3D


func _ready() -> void:
	prompt_text = "Abrir la válvula roja"
	var metal := Build.mat(Color(0.5, 0.5, 0.53))
	_red = Build.mat_unique(Color(0.9, 0.08, 0.06), 1.2)
	add_mesh_box(Vector3(0.1, 0.1, 0.1), Vector3.ZERO, metal)
	add_mesh_cylinder(0.018, 0.12, Vector3(0, 0, 0.08), metal, Vector3(PI / 2.0, 0, 0))
	_wheel = Node3D.new()
	_wheel.position = Vector3(0, 0, 0.15)
	add_child(_wheel)
	track_mesh(Build.cylinder(_wheel, 0.1, 0.02, Vector3.ZERO, _red, Vector3(PI / 2.0, 0, 0)))
	track_mesh(Build.box(_wheel, Vector3(0.2, 0.02, 0.024), Vector3.ZERO, _red))
	track_mesh(Build.box(_wheel, Vector3(0.02, 0.2, 0.024), Vector3.ZERO, _red))
	# Hanging tag.
	add_mesh_box(Vector3(0.3, 0.1, 0.008), Vector3(0, -0.19, 0.12), Build.mat(Color(0.95, 0.95, 0.9)))
	Build.label_fit(self, "AGUA\nCALIENTE", Vector3(0, -0.19, 0.126), 0.0, Vector2(0.26, 0.085), Color(0.75, 0.08, 0.08))
	add_shape(Vector3(0.28, 0.4, 0.3), Vector3(0, -0.06, 0.12))
	GameState.valve_hint.connect(_flash)


func interact() -> void:
	GameState.valve_open = not GameState.valve_open
	prompt_text = "Cerrar la válvula roja" if GameState.valve_open else "Abrir la válvula roja"
	_angle += PI if GameState.valve_open else -PI
	create_tween().tween_property(_wheel, "rotation:z", _angle, 0.6).set_trans(Tween.TRANS_SINE)
	Sfx.play("clunk")
	if GameState.valve_open:
		Sfx.play("rattle", -4.0)
	GameState.say("valve_open" if GameState.valve_open else "valve_close")


## Draws the player's eye: three bright flashes.
func _flash() -> void:
	var t := create_tween()
	for _i in 3:
		t.tween_property(_red, "emission_energy_multiplier", 5.0, 0.25)
		t.tween_property(_red, "emission_energy_multiplier", 1.2, 0.35)
