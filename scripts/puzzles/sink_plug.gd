class_name SinkPlug
extends Interactable
## Rubber plug of the sink. Part of the secret "flood" ending (see Flood).
## Local space: the sink mount, +Z into the room. It lies at the front of the basin, clear of the
## taps (whose colliders would otherwise steal the aim) and big enough to point at easily.

const REST_POS := Vector3(0.12, 0.94, 0.37)
const DRAIN_POS := Vector3(0.0, 0.93, 0.27)


func _ready() -> void:
	prompt_text = "Poner el tapón"
	position = REST_POS
	var rubber := Build.mat(Color(1.0, 0.55, 0.1), 0.35)
	add_mesh_cylinder(0.06, 0.02, Vector3.ZERO, rubber)
	add_mesh_cylinder(0.02, 0.04, Vector3(0, 0.03, 0), rubber)
	add_shape(Vector3(0.2, 0.14, 0.2), Vector3(0, 0.04, 0))


func interact() -> void:
	GameState.plug_in = not GameState.plug_in
	position = DRAIN_POS if GameState.plug_in else REST_POS
	prompt_text = "Quitar el tapón" if GameState.plug_in else "Poner el tapón"
	Sfx.play("click", -2.0, 0.6)
	GameState.say("plug_in" if GameState.plug_in else "plug_out")
