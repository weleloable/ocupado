class_name Interactable
extends StaticBody3D
## Base class for everything the player can aim at and use.

var prompt_text: String = "Interactuar"
var enabled: bool = true
var _meshes: Array[MeshInstance3D] = []

static var _highlight_mat: StandardMaterial3D


func get_prompt() -> String:
	return prompt_text


func can_interact() -> bool:
	return enabled


func interact() -> void:
	pass


func set_highlighted(on: bool) -> void:
	var overlay: Material = _get_highlight() if on else null
	for m in _meshes:
		if is_instance_valid(m):
			m.material_overlay = overlay


func track_mesh(m: MeshInstance3D) -> MeshInstance3D:
	_meshes.append(m)
	return m


func add_mesh_box(size: Vector3, pos: Vector3, material: Material, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	return track_mesh(Build.box(self, size, pos, material, rot))


func add_mesh_cylinder(radius: float, height: float, pos: Vector3, material: Material,
		rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	return track_mesh(Build.cylinder(self, radius, height, pos, material, rot))


func add_shape(size: Vector3, pos: Vector3) -> void:
	Build.collider(self, size, pos)


static func _get_highlight() -> StandardMaterial3D:
	if _highlight_mat == null:
		_highlight_mat = StandardMaterial3D.new()
		_highlight_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_highlight_mat.albedo_color = Color(1.0, 0.85, 0.2, 0.3)
		_highlight_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return _highlight_mat
