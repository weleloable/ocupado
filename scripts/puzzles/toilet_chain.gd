class_name ToiletChain
extends Interactable
## Ritual element: the chain hanging from the high cistern.

const FLUSH_TIME := 2.2

var _busy: bool = false
var _chain_root: Node3D


func _ready() -> void:
	prompt_text = "Tirar de la cadena"
	_chain_root = Node3D.new()
	add_child(_chain_root)
	var metal := Build.mat(Color(0.7, 0.7, 0.72))
	track_mesh(Build.cylinder(_chain_root, 0.01, 0.75, Vector3(0, 1.72, 0), metal))
	track_mesh(Build.box(_chain_root, Vector3(0.05, 0.13, 0.05), Vector3(0, 1.3, 0), Build.mat(Color(0.95, 0.95, 0.9))))
	add_shape(Vector3(0.18, 0.95, 0.18), Vector3(0, 1.62, 0))


func can_interact() -> bool:
	return enabled and not _busy


func interact() -> void:
	if _busy:
		return
	_busy = true
	Sfx.play("flush")
	var t := create_tween()
	t.tween_property(_chain_root, "position:y", -0.1, 0.12)
	t.tween_property(_chain_root, "position:y", 0.0, 0.3)
	GameState.ritual_action("chain", "flush_idle")
	await get_tree().create_timer(FLUSH_TIME).timeout
	_busy = false
