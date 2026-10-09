class_name Valve
extends Interactable
## Red hot-water valve on the toilet pipe. Without it open, the hot tap runs cold.
## Local space: +Z points into the room, the pipe runs vertically through the origin.

var _wheel: Node3D
var _angle: float = 0.0


func _ready() -> void:
	prompt_text = "Abrir la válvula roja"
	var metal := Build.mat(Color(0.5, 0.5, 0.53))
	var red := Build.mat(Color(0.85, 0.1, 0.08), 0.3)
	add_mesh_box(Vector3(0.07, 0.07, 0.07), Vector3.ZERO, metal)
	add_mesh_cylinder(0.012, 0.1, Vector3(0, 0, 0.06), metal, Vector3(PI / 2.0, 0, 0))
	_wheel = Node3D.new()
	_wheel.position = Vector3(0, 0, 0.11)
	add_child(_wheel)
	track_mesh(Build.cylinder(_wheel, 0.065, 0.014, Vector3.ZERO, red, Vector3(PI / 2.0, 0, 0)))
	track_mesh(Build.box(_wheel, Vector3(0.13, 0.014, 0.016), Vector3.ZERO, red))
	track_mesh(Build.box(_wheel, Vector3(0.014, 0.13, 0.016), Vector3.ZERO, red))
	# Hanging tag.
	add_mesh_box(Vector3(0.2, 0.08, 0.006), Vector3(0, -0.125, 0.1), Build.mat(Color(0.95, 0.95, 0.9)))
	Build.label_fit(self, "AGUA
CALIENTE", Vector3(0, -0.125, 0.104), 0.0, Vector2(0.18, 0.065), Color(0.75, 0.08, 0.08))
	add_shape(Vector3(0.18, 0.26, 0.2), Vector3(0, -0.03, 0.09))


func interact() -> void:
	GameState.valve_open = not GameState.valve_open
	prompt_text = "Cerrar la válvula roja" if GameState.valve_open else "Abrir la válvula roja"
	_angle += PI if GameState.valve_open else -PI
	create_tween().tween_property(_wheel, "rotation:z", _angle, 0.6).set_trans(Tween.TRANS_SINE)
	Sfx.play("clunk")
	if GameState.valve_open:
		Sfx.play("rattle", -4.0)
	GameState.say("valve_open" if GameState.valve_open else "valve_close")
