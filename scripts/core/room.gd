class_name Room
extends Node3D
## Builds the bathroom (4 x 3 m, 2.6 m high) and every object in it by code.
## Coordinates: x in [-2, 2], z in [-1.5, 1.5], floor at y = 0.
## North wall (z = -1.5) has the door. Player starts looking north.

const H := 2.6
const TILE_LINE := 1.4

var env: Environment
var emergency_light: OmniLight3D
var main_light: OmniLight3D
var black_light: OmniLight3D
var corridor_light: OmniLight3D
var tube_mat: StandardMaterial3D
var black_tube_mat: StandardMaterial3D
var hidden_labels: Array[Label3D] = []

var door: Door
var keypad: Keypad
var breaker: BreakerPanel
var toilet: DecorItem
var chain: ToiletChain
var hot_tap: Tap
var cold_tap: Tap
var mirror: MirrorFog
var dryer: HandDryer
var dispenser: Dispenser
var mop: Mop
var valve: Valve
var plug: SinkPlug
var sink_mount: Node3D
var flood: Flood

var mat_tile: StandardMaterial3D
var mat_paint: StandardMaterial3D
var mat_floor: StandardMaterial3D
var mat_ceiling: StandardMaterial3D


func _ready() -> void:
	_make_materials()
	_build_environment()
	_build_shell()
	_build_corridor()
	_build_lights()
	_build_door_wall()
	_build_east_wall()
	_build_west_wall()
	_build_south_wall()
	_build_decor()
	_build_graffiti()
	_build_flood()
	GameState.lights_turned_on.connect(_on_lights_on)


## Creates a Node3D on a wall whose local +Z points into the room and local +X is the viewer's right.
## `along` is the world x (north/south walls) or world z (east/west walls).
func mount(wall: String, along: float, y: float) -> Node3D:
	var n := Node3D.new()
	match wall:
		"north":
			n.position = Vector3(along, y, -1.5)
		"south":
			n.position = Vector3(along, y, 1.5)
			n.rotation.y = PI
		"west":
			n.position = Vector3(-2.0, y, along)
			n.rotation.y = PI / 2.0
		"east":
			n.position = Vector3(2.0, y, along)
			n.rotation.y = -PI / 2.0
	add_child(n)
	return n


func _make_materials() -> void:
	mat_tile = Build.tile_material(Color(0.86, 0.85, 0.78), Color(0.86, 0.85, 0.78), Color(0.45, 0.45, 0.4), 4.0, false, 11)
	mat_paint = Build.tile_material(Color(0.42, 0.58, 0.48), Color(0.42, 0.58, 0.48), Color(0.4, 0.55, 0.45), 2.0, false, 22, false)
	mat_floor = Build.tile_material(Color(0.5, 0.22, 0.15), Color(0.32, 0.3, 0.27), Color(0.2, 0.18, 0.16), 3.0, true, 33)
	mat_ceiling = Build.tile_material(Color(0.6, 0.6, 0.55), Color(0.6, 0.6, 0.55), Color(0.5, 0.5, 0.45), 2.0, false, 44)


func _build_environment() -> void:
	env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color.BLACK
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.4, 0.5, 0.45)
	env.ambient_light_energy = 0.35
	env.fog_enabled = true
	env.fog_light_color = Color(0.1, 0.13, 0.12)
	env.fog_density = 0.04
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)


func _build_shell() -> void:
	Build.static_box(self, Vector3(4.4, 0.2, 3.4), Vector3(0, -0.1, 0), mat_floor)
	Build.static_box(self, Vector3(4.4, 0.2, 3.4), Vector3(0, H + 0.1, 0), mat_ceiling)
	_wall(Vector3(0, 0, 1.6), Vector3(4.4, 0, 0.2), 0.0, H)        # south
	_wall(Vector3(-2.1, 0, 0), Vector3(0.2, 0, 3.4), 0.0, H)       # west
	_wall(Vector3(2.1, 0, 0), Vector3(0.2, 0, 3.4), 0.0, H)        # east
	# North wall with a door hole at x in [-0.05, 0.85], y in [0, 2.05].
	_wall(Vector3(-1.125, 0, -1.6), Vector3(2.15, 0, 0.2), 0.0, H)
	_wall(Vector3(1.525, 0, -1.6), Vector3(1.35, 0, 0.2), 0.0, H)
	_wall(Vector3(0.4, 0, -1.6), Vector3(0.9, 0, 0.2), 2.05, H)
	# Dark skirting line where tiles meet paint.
	var trim := Build.mat(Color(0.25, 0.32, 0.28))
	Build.box(self, Vector3(4.0, 0.04, 0.02), Vector3(0, TILE_LINE, 1.49), trim)
	Build.box(self, Vector3(0.02, 0.04, 3.0), Vector3(-1.99, TILE_LINE, 0), trim)
	Build.box(self, Vector3(0.02, 0.04, 3.0), Vector3(1.99, TILE_LINE, 0), trim)
	Build.box(self, Vector3(1.95, 0.04, 0.02), Vector3(-1.025, TILE_LINE, -1.49), trim)
	Build.box(self, Vector3(1.15, 0.04, 0.02), Vector3(1.425, TILE_LINE, -1.49), trim)


## Wall slab with tiles below TILE_LINE and green paint above.
func _wall(center: Vector3, size: Vector3, y0: float, y1: float) -> void:
	var body := StaticBody3D.new()
	add_child(body)
	Build.collider(body, Vector3(size.x, y1 - y0, size.z), Vector3(center.x, (y0 + y1) * 0.5, center.z))
	if y0 < TILE_LINE:
		var top := minf(y1, TILE_LINE)
		Build.box(body, Vector3(size.x, top - y0, size.z), Vector3(center.x, (y0 + top) * 0.5, center.z), mat_tile)
	if y1 > TILE_LINE:
		var bottom := maxf(y0, TILE_LINE)
		Build.box(body, Vector3(size.x, y1 - bottom, size.z), Vector3(center.x, (bottom + y1) * 0.5, center.z), mat_paint)


## Little bar corridor behind the door, seen when it opens.
func _build_corridor() -> void:
	var m_floor := Build.mat(Color(0.35, 0.22, 0.12))
	var m_wall := Build.mat(Color(0.55, 0.33, 0.18))
	Build.static_box(self, Vector3(1.8, 0.2, 2.4), Vector3(0.4, -0.1, -2.9), m_floor)
	Build.static_box(self, Vector3(0.2, H, 2.4), Vector3(-0.6, H / 2.0, -2.9), m_wall)
	Build.static_box(self, Vector3(0.2, H, 2.4), Vector3(1.4, H / 2.0, -2.9), m_wall)
	Build.static_box(self, Vector3(1.8, H, 0.2), Vector3(0.4, H / 2.0, -4.1), m_wall)
	Build.static_box(self, Vector3(1.8, 0.2, 2.4), Vector3(0.4, H + 0.1, -2.9), m_wall)
	Build.label_fit(self, "BAR", Vector3(0.4, 1.9, -3.99), 0.0, Vector2(0.9, 0.45), Color(1.0, 0.55, 0.2))
	# Stool with your beer on it.
	Build.cylinder(self, 0.2, 0.05, Vector3(0.4, 0.75, -3.5), Build.mat(Color(0.3, 0.15, 0.08)))
	Build.cylinder(self, 0.03, 0.75, Vector3(0.4, 0.375, -3.5), Build.mat(Color(0.4, 0.4, 0.42)))
	Build.cylinder(self, 0.045, 0.17, Vector3(0.4, 0.86, -3.5), Build.mat(Color(1.0, 0.72, 0.1), 0.6))
	Build.cylinder(self, 0.046, 0.035, Vector3(0.4, 0.96, -3.5), Build.mat(Color(1, 1, 0.95), 0.4))
	corridor_light = OmniLight3D.new()
	corridor_light.position = Vector3(0.4, 2.1, -3.0)
	corridor_light.light_color = Color(1.0, 0.7, 0.4)
	corridor_light.light_energy = 2.0
	corridor_light.omni_range = 3.2
	corridor_light.visible = false
	add_child(corridor_light)


func _build_lights() -> void:
	# Green emergency light above the door: the only real light at start.
	emergency_light = OmniLight3D.new()
	emergency_light.position = Vector3(0.4, 2.3, -1.2)
	emergency_light.light_color = Color(0.4, 1.0, 0.5)
	emergency_light.light_energy = 0.9
	emergency_light.omni_range = 4.5
	add_child(emergency_light)
	Build.box(self, Vector3(0.44, 0.15, 0.06), Vector3(0.4, 2.33, -1.47), Build.mat(Color(0.15, 0.85, 0.3), 1.5))
	Build.label_fit(self, "SALIDA", Vector3(0.4, 2.33, -1.437), 0.0, Vector2(0.36, 0.09), Color.WHITE)

	var fill := OmniLight3D.new()
	fill.position = Vector3(0, 2.2, 0.6)
	fill.light_color = Color(0.6, 0.7, 0.9)
	fill.light_energy = 0.25
	fill.omni_range = 5.0
	add_child(fill)

	main_light = OmniLight3D.new()
	main_light.position = Vector3(0, 2.4, -0.1)
	main_light.light_color = Color(0.95, 1.0, 0.9)
	main_light.light_energy = 0.0
	main_light.omni_range = 6.0
	add_child(main_light)

	black_light = OmniLight3D.new()
	black_light.position = Vector3(0, 2.35, 0.7)
	black_light.light_color = Color(0.55, 0.25, 1.0)
	black_light.light_energy = 0.0
	black_light.omni_range = 6.0
	add_child(black_light)

	tube_mat = Build.mat_unique(Color(0.55, 0.55, 0.55))
	Build.box(self, Vector3(1.2, 0.06, 0.12), Vector3(0, H - 0.03, -0.1), tube_mat)
	black_tube_mat = Build.mat_unique(Color(0.25, 0.1, 0.4))
	Build.box(self, Vector3(0.6, 0.05, 0.08), Vector3(0, H - 0.03, 0.7), black_tube_mat)


## North wall: door (with frame) and keypad.
func _build_door_wall() -> void:
	var frame_mat := Build.mat(Color(0.32, 0.18, 0.1))
	Build.box(self, Vector3(0.08, 2.1, 0.06), Vector3(-0.09, 1.05, -1.47), frame_mat)
	Build.box(self, Vector3(0.08, 2.1, 0.06), Vector3(0.89, 1.05, -1.47), frame_mat)
	Build.box(self, Vector3(1.06, 0.08, 0.06), Vector3(0.4, 2.09, -1.47), frame_mat)
	var pivot := Node3D.new()
	pivot.position = Vector3(-0.05, 0.0, -1.53)
	add_child(pivot)
	door = Door.new()
	door.corridor_light = corridor_light
	pivot.add_child(door)
	keypad = Keypad.new()
	mount("north", -0.45, 1.35).add_child(keypad)


## East wall: breaker panel, toilet with high cistern + chain, empty roll.
func _build_east_wall() -> void:
	breaker = BreakerPanel.new()
	mount("east", -0.75, 1.45).add_child(breaker)

	var m := mount("east", 0.75, 0.0)
	var porcelain := Build.mat(Color(0.93, 0.93, 0.9))
	valve = Valve.new()
	valve.position = Vector3(-0.12, 1.15, 0.05)
	m.add_child(valve)
	toilet = DecorItem.new().setup("Mirar el váter", "toilet")
	m.add_child(toilet)
	toilet.add_mesh_cylinder(0.17, 0.4, Vector3(0, 0.2, 0.36), porcelain)
	toilet.add_mesh_box(Vector3(0.42, 0.06, 0.5), Vector3(0, 0.43, 0.34), Build.mat(Color(0.2, 0.2, 0.22)))
	toilet.add_mesh_box(Vector3(0.4, 0.45, 0.04), Vector3(0, 0.68, 0.11), Build.mat(Color(0.2, 0.2, 0.22)))
	toilet.add_shape(Vector3(0.46, 0.5, 0.6), Vector3(0, 0.25, 0.32))
	# High cistern and pipe (static).
	var body := StaticBody3D.new()
	m.add_child(body)
	Build.box(body, Vector3(0.5, 0.28, 0.2), Vector3(0, 2.15, 0.11), porcelain)
	Build.cylinder(body, 0.025, 1.6, Vector3(-0.12, 1.25, 0.05), Build.mat(Color(0.6, 0.6, 0.62)))
	Build.collider(body, Vector3(0.5, 0.28, 0.2), Vector3(0, 2.15, 0.11))
	chain = ToiletChain.new()
	chain.position = Vector3(0.17, 0.0, 0.2)
	m.add_child(chain)

	var r := mount("east", 0.12, 0.8)
	var roll := DecorItem.new().setup("Coger el rollo de papel", "roll")
	r.add_child(roll)
	roll.add_mesh_box(Vector3(0.18, 0.03, 0.06), Vector3(0, 0.07, 0.03), Build.mat(Color(0.6, 0.6, 0.62)))
	roll.add_mesh_cylinder(0.035, 0.12, Vector3(0, 0.0, 0.06), Build.mat(Color(0.6, 0.45, 0.3)), Vector3(0, 0, PI / 2.0))
	roll.add_shape(Vector3(0.24, 0.2, 0.14), Vector3(0, 0.02, 0.06))


## West wall: sink with hot/cold taps and the mirror.
func _build_west_wall() -> void:
	var m := mount("west", -0.2, 0.0)
	var porcelain := Build.mat(Color(0.93, 0.93, 0.9))
	var body := StaticBody3D.new()
	m.add_child(body)
	Build.box(body, Vector3(0.62, 0.14, 0.48), Vector3(0, 0.85, 0.24), porcelain)
	Build.box(body, Vector3(0.48, 0.01, 0.34), Vector3(0, 0.925, 0.27), Build.mat(Color(0.55, 0.6, 0.62)))
	Build.box(body, Vector3(0.16, 0.78, 0.16), Vector3(0, 0.39, 0.14), porcelain)
	Build.collider(body, Vector3(0.62, 0.92, 0.48), Vector3(0, 0.46, 0.24))
	hot_tap = Tap.new()
	hot_tap.is_hot = true
	hot_tap.position = Vector3(-0.17, 1.0, 0.07)
	m.add_child(hot_tap)
	cold_tap = Tap.new()
	cold_tap.position = Vector3(0.17, 1.0, 0.07)
	m.add_child(cold_tap)
	mirror = MirrorFog.new()
	mirror.hot_tap = hot_tap
	mirror.cold_tap = cold_tap
	mirror.position = Vector3(0, 1.62, 0.0)
	m.add_child(mirror)
	plug = SinkPlug.new()
	m.add_child(plug)
	sink_mount = m


## South wall: hand dryer, paper dispenser.
func _build_south_wall() -> void:
	dryer = HandDryer.new()
	mount("south", -0.9, 1.3).add_child(dryer)
	dispenser = Dispenser.new()
	mount("south", 0.9, 1.35).add_child(dispenser)


## Mop in a corner and the "employees must wash hands" sign.
func _build_decor() -> void:
	mop = Mop.new()
	mop.position = Vector3(-1.65, 0.0, 1.15)
	add_child(mop)

	var sign_mount := mount("south", 0.0, 1.95)
	var sign := DecorItem.new().setup("Leer el cartel", "employees_sign")
	sign_mount.add_child(sign)
	sign.add_mesh_box(Vector3(0.62, 0.24, 0.015), Vector3(0, 0, 0.008), Build.mat(Color(0.95, 0.95, 0.9)))
	Build.label_fit(sign, "LOS EMPLEADOS DEBEN\nLAVARSE LAS MANOS", Vector3(0, 0, 0.017), 0.0,
			Vector2(0.54, 0.17), Color(0.1, 0.2, 0.55))
	sign.add_shape(Vector3(0.64, 0.26, 0.05), Vector3(0, 0, 0.02))


func _build_graffiti() -> void:
	var marker := Color(0.08, 0.08, 0.1)
	var red := Color(0.6, 0.08, 0.08)
	var blue := Color(0.1, 0.2, 0.6)
	_graffiti("north", 1.45, 1.8, "AQUÍ SE VIENE\nA LLORAR", Vector2(0.85, 0.3), marker, false)
	_graffiti("south", -0.9, 1.85, "SI LEES ESTO,\nESTÁS EN UN BAÑO", Vector2(0.85, 0.3), red, false)
	_graffiti("west", 1.0, 1.72, "LA LLAVE ESTÁ\nEN TU CORAZÓN\n(es broma, es un teclado)", Vector2(0.9, 0.4), blue, false)
	_graffiti("east", 0.3, 1.72, "PACO\nTE QUIERO\n(NO)", Vector2(0.55, 0.4), red, false)
	# Hidden until the black light turns on.
	var neon := Color(0.75, 1.0, 0.2)
	var pink := Color(1.0, 0.35, 0.85)
	var cyan := Color(0.3, 0.95, 1.0)
	_graffiti("north", -1.28, 1.86,
			"EL RITUAL DEL PARROQUIANO\n1. EL VIENTO QUE SECA\n2. LA VETERANA DE 2009\n3. EL RÍO QUE ARRASTRA\n4. LO FRÍO QUE MOJA\n5. OTRA VEZ EL VIENTO",
			Vector2(1.15, 0.7), neon, true)
	_graffiti("west", 0.95, 2.2, "EL CALIENTE NO SALE\nSI ALGUIEN LO CIERRA", Vector2(1.0, 0.3), pink, true)
	_graffiti("south", 0.9, 1.88, "EL PAPEL NO SE GANA,\nSE MERECE", Vector2(0.8, 0.2), pink, true)
	_graffiti("east", -0.75, 2.3, "ESTO NO SE LIMPIA\nDESDE 2009", Vector2(0.75, 0.2), neon, true)
	_graffiti("west", -1.0, 1.9, "¿PRISA?\nTAPA EL LAVABO,\nABRE TODO Y ESPERA.\nEL BAR YA LIMPIARÁ", Vector2(0.8, 0.5), cyan, true)


func _graffiti(wall: String, along: float, y: float, text: String, max_size: Vector2, color: Color,
		hidden: bool) -> void:
	var m := mount(wall, along, y)
	var l := Build.label_fit(m, text, Vector3(0, 0, 0.012), 0.0, max_size, color, 5 if hidden else 0)
	if hidden:
		l.outline_modulate = Color(color.r * 0.3, color.g * 0.3, color.b * 0.3)
		l.visible = false
		hidden_labels.append(l)


## Flood controller of the secret ending (needs the taps, the door and the sink mount).
func _build_flood() -> void:
	flood = Flood.new()
	flood.hot_tap = hot_tap
	flood.cold_tap = cold_tap
	flood.door = door
	flood.sink_mount = sink_mount
	add_child(flood)


func _on_lights_on() -> void:
	for l in hidden_labels:
		l.visible = true
	tube_mat.emission_enabled = true
	tube_mat.emission = Color(0.9, 1.0, 0.9)
	tube_mat.emission_energy_multiplier = 2.0
	black_tube_mat.emission_enabled = true
	black_tube_mat.emission = Color(0.6, 0.3, 1.0)
	black_tube_mat.emission_energy_multiplier = 2.0
	var t := create_tween()
	t.tween_property(main_light, "light_energy", 1.4, 0.05)
	t.tween_property(main_light, "light_energy", 0.1, 0.08)
	t.tween_property(main_light, "light_energy", 1.2, 0.06)
	t.tween_property(main_light, "light_energy", 0.2, 0.1)
	t.tween_property(main_light, "light_energy", 1.5, 0.15)
	t.parallel().tween_property(black_light, "light_energy", 0.8, 0.3)
	t.parallel().tween_property(env, "ambient_light_energy", 0.6, 0.3)
	Sfx.start_loop("hum", "hum", -18.0)
