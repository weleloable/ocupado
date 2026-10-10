class_name SteamPipe
extends Node3D
## Red steam pipe in the corner next to the door: a vertical pipe floor-to-ceiling, a run along the
## north wall with the lever valve, a pressure gauge and a leaking nozzle. Opening the valve moves
## the gauge needle, plays a hiss and shows steam puffs, so it is obvious this is the steam that
## feeds the hot water. The node sits at the pipe axis; the run goes towards -X.

const RUN_LENGTH := 0.76
const NEEDLE_CLOSED := -2.6   # rad, about 7 o'clock
const NEEDLE_OPEN := -1.0     # rad, about 2 o'clock
const PUFFS := 4

var valve: Valve
var _needle: Node3D
var _puffs: Array[MeshInstance3D] = []
var _puff_mats: Array[StandardMaterial3D] = []
var _puff_tweens: Array[Tween] = []


func _ready() -> void:
	var red := Build.mat(Color(0.78, 0.08, 0.06), 0.6)
	var grey := Build.mat(Color(0.5, 0.5, 0.53))
	var yellow := Build.mat(Color(1.0, 0.8, 0.05), 0.6)

	# Vertical pipe, flanges and hazard bands.
	var body := StaticBody3D.new()
	add_child(body)
	Build.cylinder(body, 0.08, 2.6, Vector3(0, 1.3, 0), red)
	Build.collider(body, Vector3(0.18, 2.6, 0.18), Vector3(0, 1.3, 0))
	for y in [0.25, 2.35]:
		Build.cylinder(self, 0.115, 0.06, Vector3(0, y, 0), grey)
	for y in [0.6, 1.8]:
		Build.cylinder(self, 0.085, 0.07, Vector3(0, y, 0), yellow)
	Build.cylinder(self, 0.1, 0.1, Vector3(0, 1.0, 0), grey)

	# Run along the north wall (towards -X), brackets, and the elbow into the wall.
	Build.cylinder(self, 0.05, RUN_LENGTH, Vector3(-RUN_LENGTH * 0.5, 1.0, 0), red, Vector3(0, 0, PI / 2.0))
	for x in [-0.2, -0.56]:
		Build.box(self, Vector3(0.04, 0.12, 0.14), Vector3(x, 1.0, -0.07), grey)
	Build.cylinder(self, 0.05, 0.14, Vector3(-RUN_LENGTH, 1.0, -0.07), red, Vector3(PI / 2.0, 0, 0))
	Build.cylinder(self, 0.07, 0.04, Vector3(-RUN_LENGTH, 1.0, -0.13), grey, Vector3(PI / 2.0, 0, 0))

	# Lever valve in the middle of the run.
	valve = Valve.new()
	valve.position = Vector3(-RUN_LENGTH * 0.5, 1.0, 0)
	add_child(valve)

	# Hanging tag under the valve.
	Build.box(self, Vector3(0.34, 0.1, 0.01), Vector3(-RUN_LENGTH * 0.5, 0.82, 0.06), Build.mat(Color(0.95, 0.95, 0.9)))
	Build.label_fit(self, "VAPOR\nAGUA CALIENTE", Vector3(-RUN_LENGTH * 0.5, 0.82, 0.067), 0.0,
			Vector2(0.3, 0.085), Color(0.75, 0.08, 0.08))

	# Pressure gauge facing the room.
	Build.cylinder(self, 0.08, 0.04, Vector3(0, 1.55, 0.1), Build.mat(Color(0.2, 0.2, 0.22)), Vector3(PI / 2.0, 0, 0))
	Build.cylinder(self, 0.068, 0.012, Vector3(0, 1.55, 0.125), Build.mat(Color(0.95, 0.95, 0.9)), Vector3(PI / 2.0, 0, 0))
	Build.box(self, Vector3(0.025, 0.012, 0.004), Vector3(0.045, 1.57, 0.133), Build.mat(Color(0.1, 0.7, 0.2), 0.5))
	Build.box(self, Vector3(0.025, 0.012, 0.004), Vector3(-0.045, 1.52, 0.133), Build.mat(Color(0.85, 0.1, 0.1), 0.5))
	_needle = Node3D.new()
	_needle.position = Vector3(0, 1.55, 0.136)
	_needle.rotation.z = NEEDLE_CLOSED
	add_child(_needle)
	Build.box(_needle, Vector3(0.008, 0.06, 0.004), Vector3(0, 0.028, 0), Build.mat(Color(0.05, 0.05, 0.05)))

	# Leaking nozzle with steam puffs.
	Build.cylinder(self, 0.02, 0.1, Vector3(0, 0.45, 0.1), grey, Vector3(PI / 2.0, 0, 0))
	for i in PUFFS:
		var mat := Build.mat_unique(Color(1, 1, 1, 0.5), 0.0, true)
		var mesh := SphereMesh.new()
		mesh.radius = 0.05
		mesh.height = 0.1
		mesh.radial_segments = 8
		mesh.rings = 4
		var puff := MeshInstance3D.new()
		puff.mesh = mesh
		puff.material_override = mat
		puff.position = Vector3(0, 0.5, 0.18)
		puff.visible = false
		add_child(puff)
		_puffs.append(puff)
		_puff_mats.append(mat)

	GameState.valve_changed.connect(_on_valve_changed)


func _on_valve_changed(open: bool) -> void:
	create_tween().tween_property(_needle, "rotation:z", NEEDLE_OPEN if open else NEEDLE_CLOSED, 1.2) \
			.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	if open:
		Sfx.start_loop("steam", "steam", -14.0)
		_start_puffs()
	else:
		Sfx.stop_loop("steam")
		_stop_puffs()


func _start_puffs() -> void:
	_stop_puffs()
	for i in PUFFS:
		var puff := _puffs[i]
		var mat := _puff_mats[i]
		var start := Vector3(0, 0.5, 0.18)
		var t := create_tween().set_loops()
		t.tween_interval(i * 0.4)
		t.tween_callback(func() -> void:
			puff.visible = true
			puff.position = start
			puff.scale = Vector3.ONE * 0.4
			mat.albedo_color.a = 0.5)
		t.tween_property(puff, "position:y", start.y + 0.55, 1.2)
		t.parallel().tween_property(puff, "scale", Vector3.ONE * 1.8, 1.2)
		t.parallel().tween_property(mat, "albedo_color:a", 0.0, 1.2)
		t.tween_interval((PUFFS - 1 - i) * 0.4)
		_puff_tweens.append(t)


func _stop_puffs() -> void:
	for t in _puff_tweens:
		t.kill()
	_puff_tweens.clear()
	for puff in _puffs:
		puff.visible = false
