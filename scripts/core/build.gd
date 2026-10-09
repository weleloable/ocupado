class_name Build
extends RefCounted
## Small helpers to build the room out of primitives.

static var _mat_cache: Dictionary = {}


## Shared (cached) flat-color material. Do not mutate the result.
static func mat(color: Color, emission: float = 0.0, unshaded: bool = false) -> StandardMaterial3D:
	var key := "%s|%s|%s" % [color.to_html(), emission, unshaded]
	if _mat_cache.has(key):
		return _mat_cache[key]
	var m := mat_unique(color, emission, unshaded)
	_mat_cache[key] = m
	return m


## Fresh material that can be changed at runtime.
static func mat_unique(color: Color, emission: float = 0.0, unshaded: bool = false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.85
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	if emission > 0.0:
		m.emission_enabled = true
		m.emission = Color(color.r, color.g, color.b)
		m.emission_energy_multiplier = emission
	if unshaded:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if color.a < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m


## Procedural pixel-art tiles mapped with world triplanar UVs.
static func tile_material(c1: Color, c2: Color, grout: Color, tiles_per_meter: float,
		checker: bool, seed_value: int, use_grout: bool = true) -> StandardMaterial3D:
	var px := 16
	var img := Image.create_empty(px * 2, px * 2, false, Image.FORMAT_RGB8)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for ty in 2:
		for tx in 2:
			var base := c1
			if checker and (tx + ty) % 2 == 1:
				base = c2
			var tint := rng.randf_range(-0.04, 0.04)
			for y in px:
				for x in px:
					var c := base
					if use_grout and (x == 0 or y == 0):
						c = grout
					else:
						var n := rng.randf_range(-0.03, 0.03) + tint
						c = Color(c.r + n, c.g + n, c.b + n)
						if rng.randf() < 0.025:
							c = c.darkened(0.3)
					img.set_pixel(tx * px + x, ty * px + y, c)
	var m := StandardMaterial3D.new()
	m.albedo_texture = ImageTexture.create_from_image(img)
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = Vector3.ONE * (tiles_per_meter / 2.0)
	m.roughness = 0.7
	return m


static func box(parent: Node, size: Vector3, pos: Vector3, material: Material,
		rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	mi.position = pos
	mi.rotation = rot
	parent.add_child(mi)
	return mi


static func cylinder(parent: Node, radius: float, height: float, pos: Vector3, material: Material,
		rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	mesh.rings = 1
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	mi.position = pos
	mi.rotation = rot
	parent.add_child(mi)
	return mi


static func collider(body: CollisionObject3D, size: Vector3, pos: Vector3) -> CollisionShape3D:
	var shape := BoxShape3D.new()
	shape.size = size
	var cs := CollisionShape3D.new()
	cs.shape = shape
	cs.position = pos
	body.add_child(cs)
	return cs


## Static box with mesh and matching collision.
static func static_box(parent: Node, size: Vector3, pos: Vector3, material: Material) -> StaticBody3D:
	var body := StaticBody3D.new()
	parent.add_child(body)
	box(body, size, pos, material)
	collider(body, size, pos)
	return body


static func label(parent: Node, text: String, pos: Vector3, rot_y: float, font_size: int,
		color: Color, pixel_size: float = 0.004, outline: int = 0) -> Label3D:
	var l := Label3D.new()
	l.text = text
	l.position = pos
	l.rotation.y = rot_y
	l.font_size = font_size
	l.pixel_size = pixel_size
	l.modulate = color
	l.outline_size = outline
	l.outline_modulate = Color(0, 0, 0, color.a)
	l.shaded = false
	l.double_sided = false
	l.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	l.alpha_cut = Label3D.ALPHA_CUT_DISCARD
	parent.add_child(l)
	return l
