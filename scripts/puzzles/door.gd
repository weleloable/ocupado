class_name Door
extends Interactable
## The door. Its parent must be a pivot Node3D at the hinge. The sign reads OCUPADO
## until the keypad is "solved", then flips to reveal TIRAR, and pulling opens it.

var corridor_light: OmniLight3D
var _sign_pivot: Node3D
var _opening: bool = false


func _ready() -> void:
	prompt_text = "Empujar la puerta"
	var wood := Build.mat(Color(0.48, 0.28, 0.16))
	add_mesh_box(Vector3(0.9, 2.04, 0.05), Vector3(0.45, 1.02, 0), wood)
	add_mesh_box(Vector3(0.76, 0.02, 0.01), Vector3(0.45, 1.85, 0.03), Build.mat(Color(0.38, 0.22, 0.12)))
	add_mesh_box(Vector3(0.76, 0.02, 0.01), Vector3(0.45, 0.25, 0.03), Build.mat(Color(0.38, 0.22, 0.12)))
	add_mesh_box(Vector3(0.14, 0.035, 0.06), Vector3(0.78, 1.0, 0.05), Build.mat(Color(0.8, 0.75, 0.5)))
	add_shape(Vector3(0.9, 2.04, 0.1), Vector3(0.45, 1.02, 0))
	# Sign: front says OCUPADO, back says TIRAR.
	_sign_pivot = Node3D.new()
	_sign_pivot.position = Vector3(0.45, 1.55, 0.04)
	add_child(_sign_pivot)
	track_mesh(Build.box(_sign_pivot, Vector3(0.52, 0.17, 0.012), Vector3.ZERO, Build.mat(Color(0.92, 0.9, 0.84))))
	Build.label_fit(_sign_pivot, "OCUPADO", Vector3(0, 0, 0.008), 0.0, Vector2(0.4, 0.1), Color(0.75, 0.08, 0.08))
	Build.label_fit(_sign_pivot, "TIRAR", Vector3(0, 0, -0.008), PI, Vector2(0.36, 0.11), Color(0.1, 0.3, 0.75))
	GameState.keypad_solved.connect(_on_keypad_solved)


func interact() -> void:
	if _opening:
		return
	if not GameState.keypad_done:
		Sfx.play("rattle")
		GameState.say("door_locked")
		var t := create_tween()
		t.tween_property(self, "position:z", -0.01, 0.05)
		t.tween_property(self, "position:z", 0.0, 0.08)
		return
	_open_door()


func _open_door() -> void:
	_opening = true
	enabled = false
	collision_layer = 0
	if corridor_light != null:
		corridor_light.visible = true
	Sfx.play("door")
	GameState.say("door_open")
	var t := create_tween()
	t.tween_property(get_parent(), "rotation:y", deg_to_rad(-105.0), 1.3) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_interval(0.3)
	t.tween_callback(Sfx.play.bind("fanfare", 0.0, 1.0))
	t.tween_callback(GameState.win)


## Used by the flood ending: the water bursts the door open (no win here, Flood handles it).
func burst_open() -> void:
	if _opening:
		return
	_opening = true
	enabled = false
	collision_layer = 0
	if corridor_light != null:
		corridor_light.visible = true
	Sfx.play("door")
	Sfx.play("clunk")
	create_tween().tween_property(get_parent(), "rotation:y", deg_to_rad(-110.0), 0.45) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_keypad_solved() -> void:
	prompt_text = "Tirar de la puerta"
	var t := create_tween()
	t.tween_interval(2.5)
	t.tween_callback(Sfx.play.bind("click", 0.0, 1.0))
	t.tween_callback(GameState.say.bind("sign_flip"))
	t.tween_property(_sign_pivot, "rotation:y", PI, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
