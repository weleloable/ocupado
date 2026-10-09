class_name Tap
extends Interactable
## Sink tap (hot or cold).
## Cold: opening it is a ritual step; open together with the hot one the water turns lukewarm.
## Hot: runs cold until the red valve is opened; then it steams up the mirror (see MirrorFog).

var is_hot: bool = false
var is_open: bool = false
var _stream: MeshInstance3D


func _ready() -> void:
	var chrome := Build.mat(Color(0.75, 0.76, 0.8))
	add_mesh_cylinder(0.025, 0.12, Vector3(0, 0, 0), chrome)
	add_mesh_box(Vector3(0.03, 0.03, 0.12), Vector3(0, 0.05, 0.06), chrome)
	var knob_color := Color(0.85, 0.1, 0.1) if is_hot else Color(0.1, 0.3, 0.9)
	add_mesh_cylinder(0.04, 0.035, Vector3(0, 0.085, 0), Build.mat(knob_color, 0.4))
	_stream = Build.cylinder(self, 0.009, 0.12, Vector3(0, -0.015, 0.115), Build.mat(Color(0.6, 0.8, 1.0, 0.7), 0.5))
	_stream.visible = false
	add_shape(Vector3(0.16, 0.2, 0.2), Vector3(0, 0.03, 0.07))
	_refresh_prompt()


func interact() -> void:
	is_open = not is_open
	_stream.visible = is_open
	Sfx.play("click")
	var loop_id := "tap_hot" if is_hot else "tap_cold"
	if is_open:
		Sfx.start_loop(loop_id, "tap", -10.0)
		if is_hot:
			if GameState.valve_open:
				GameState.say("hot_tap_on")
			else:
				GameState.say("hot_tap_cold")
				GameState.valve_hint.emit()
		else:
			GameState.ritual_action("cold_tap", "cold_tap_on")
	else:
		Sfx.stop_loop(loop_id)
	_refresh_prompt()


func _refresh_prompt() -> void:
	var which := "caliente" if is_hot else "frío"
	prompt_text = ("Cerrar el grifo " if is_open else "Abrir el grifo ") + which
