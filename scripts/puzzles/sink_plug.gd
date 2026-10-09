class_name SinkPlug
extends Interactable
## Rubber plug of the sink. Part of the secret "flood" ending (see Flood).
## Local space: the sink mount, +Z into the room.

const REST_POS := Vector3(0.2, 0.935, 0.16)
const DRAIN_POS := Vector3(0.0, 0.935, 0.27)


func _ready() -> void:
	prompt_text = "Poner el tapón"
	position = REST_POS
	add_mesh_cylinder(0.04, 0.014, Vector3.ZERO, Build.mat(Color(0.12, 0.12, 0.14)))
	add_mesh_cylinder(0.012, 0.025, Vector3(0, 0.014, 0), Build.mat(Color(0.12, 0.12, 0.14)))
	add_shape(Vector3(0.12, 0.08, 0.12), Vector3(0, 0.02, 0))


func interact() -> void:
	GameState.plug_in = not GameState.plug_in
	position = DRAIN_POS if GameState.plug_in else REST_POS
	prompt_text = "Quitar el tapón" if GameState.plug_in else "Poner el tapón"
	Sfx.play("click", -2.0, 0.6)
	GameState.say("plug_in" if GameState.plug_in else "plug_out")
