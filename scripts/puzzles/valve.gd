class_name Valve
extends Interactable
## Lever valve of the red steam pipe (see SteamPipe). Without steam, the hot tap runs cold.
## Local space: the valve sits on a pipe that runs along X; the lever is closed when it points
## across the pipe (towards the room) and open when it lies along the pipe.
## It flashes when the player opens the hot tap with the steam closed (GameState.valve_hint).

const CLOSED_ANGLE := PI / 2.0
const OPEN_ANGLE := 0.0

var _lever: Node3D
var _lever_mat: StandardMaterial3D


func _ready() -> void:
	prompt_text = "Abrir el vapor"
	var metal := Build.mat(Color(0.45, 0.45, 0.48))
	_lever_mat = Build.mat_unique(Color(1.0, 0.8, 0.05), 1.0)
	add_mesh_box(Vector3(0.14, 0.12, 0.14), Vector3.ZERO, metal)
	add_mesh_cylinder(0.02, 0.1, Vector3(0, 0.1, 0), metal)
	_lever = Node3D.new()
	_lever.position = Vector3(0, 0.17, 0)
	_lever.rotation.y = CLOSED_ANGLE
	add_child(_lever)
	track_mesh(Build.box(_lever, Vector3(0.3, 0.035, 0.05), Vector3(0.08, 0, 0), _lever_mat))
	track_mesh(Build.cylinder(_lever, 0.035, 0.05, Vector3(-0.08, 0, 0), _lever_mat))
	# Generous aim area: lever, body and a stretch of pipe.
	add_shape(Vector3(0.5, 0.34, 0.34), Vector3(0, 0.06, 0))
	GameState.valve_hint.connect(_flash)


func interact() -> void:
	GameState.valve_open = not GameState.valve_open
	prompt_text = "Cerrar el vapor" if GameState.valve_open else "Abrir el vapor"
	var target := OPEN_ANGLE if GameState.valve_open else CLOSED_ANGLE
	create_tween().tween_property(_lever, "rotation:y", target, 0.35).set_trans(Tween.TRANS_BACK)
	Sfx.play("clunk")
	if GameState.valve_open:
		Sfx.play("rattle", -4.0)
	GameState.valve_changed.emit(GameState.valve_open)
	GameState.say("valve_open" if GameState.valve_open else "valve_close")


## Draws the player's eye: three bright flashes of the lever.
func _flash() -> void:
	var t := create_tween()
	for _i in 3:
		t.tween_property(_lever_mat, "emission_energy_multiplier", 6.0, 0.25)
		t.tween_property(_lever_mat, "emission_energy_multiplier", 1.0, 0.35)
