class_name Player
extends CharacterBody3D
## First-person player: WASD + mouse look, raycast interaction.

const SPEED := 2.2
const MOUSE_SENS := 0.0025
const GRAVITY := 9.8
const REACH := 2.0
const EYE_HEIGHT := 1.6

var camera: Camera3D
var ray: RayCast3D
var focused: Interactable = null
var _pitch: float = 0.0


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.28
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)

	camera = Camera3D.new()
	camera.position.y = EYE_HEIGHT
	camera.fov = 75.0
	camera.near = 0.03
	add_child(camera)
	camera.current = true

	ray = RayCast3D.new()
	ray.target_position = Vector3(0, 0, -REACH)
	ray.add_exception(self)
	camera.add_child(ray)


func _unhandled_input(event: InputEvent) -> void:
	if GameState.controls_locked:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var rel: Vector2 = (event as InputEventMouseMotion).screen_relative
		rotate_y(-rel.x * MOUSE_SENS)
		_pitch = clampf(_pitch - rel.y * MOUSE_SENS, -1.45, 1.45)
		camera.rotation.x = _pitch
	elif event.is_action_pressed("interact") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if focused != null and is_instance_valid(focused) and focused.can_interact():
			focused.interact()
			get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	var dir := Vector3.ZERO
	if not GameState.controls_locked:
		var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		dir = transform.basis * Vector3(input.x, 0.0, input.y)
		dir.y = 0.0
		if dir.length_squared() > 0.0:
			dir = dir.normalized()
	velocity.x = dir.x * SPEED
	velocity.z = dir.z * SPEED
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= GRAVITY * delta
	move_and_slide()
	_update_focus()


func _update_focus() -> void:
	var target: Interactable = null
	if not GameState.controls_locked and ray.is_colliding():
		var hit := ray.get_collider()
		if hit is Interactable and (hit as Interactable).can_interact():
			target = hit as Interactable
	if target == focused:
		return
	if focused != null and is_instance_valid(focused):
		focused.set_highlighted(false)
	focused = target
	if focused != null:
		focused.set_highlighted(true)
