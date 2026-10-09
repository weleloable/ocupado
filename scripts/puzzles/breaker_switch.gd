class_name BreakerSwitch
extends Interactable
## One lever of the breaker panel.

var panel: BreakerPanel
var index: int = 0
var lever: MeshInstance3D
var _up: bool = false


func _ready() -> void:
	prompt_text = "Accionar interruptor %d" % (index + 1)
	add_mesh_box(Vector3(0.09, 0.15, 0.03), Vector3(0, 0, 0.015), Build.mat(Color(0.12, 0.12, 0.13)))
	lever = add_mesh_box(Vector3(0.045, 0.06, 0.06), Vector3(0, -0.035, 0.05), Build.mat(Color(0.95, 0.45, 0.1)))
	add_shape(Vector3(0.14, 0.22, 0.1), Vector3(0, 0, 0.05))


func interact() -> void:
	panel.press(index)


func flip() -> void:
	_up = not _up
	lever.position.y = 0.035 if _up else -0.035
