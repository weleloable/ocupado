class_name Flood
extends Node3D
## Secret ending: plug in + hot tap open + cold tap open for TIME_TO_FLOOD seconds makes the
## sink overflow and flood the room until the water bursts the door open.
## If the player stops, the water drains (progress falls at DRAIN_RATE), so nothing is lost.

const TIME_TO_FLOOD := 14.0
const MAX_LEVEL := 1.0
const DRAIN_RATE := 0.6
const SINK_SURFACE_Y := 0.925

var hot_tap: Tap
var cold_tap: Tap
var door: Door
var sink_mount: Node3D

var progress: float = 0.0
var level: float = 0.0
var _water: MeshInstance3D
var _sink_water: MeshInstance3D
var _stage: int = 0
var _done: bool = false


func _ready() -> void:
	var floor_mesh := BoxMesh.new()
	floor_mesh.size = Vector3(3.96, 1.0, 2.96)
	_water = MeshInstance3D.new()
	_water.mesh = floor_mesh
	_water.material_override = Build.mat_unique(Color(0.25, 0.55, 0.85, 0.55), 0.0, true)
	_water.visible = false
	add_child(_water)

	var sink_mesh := BoxMesh.new()
	sink_mesh.size = Vector3(0.46, 1.0, 0.32)
	_sink_water = MeshInstance3D.new()
	_sink_water.mesh = sink_mesh
	_sink_water.material_override = Build.mat_unique(Color(0.35, 0.65, 0.9, 0.7), 0.0, true)
	_sink_water.visible = false
	_sink_water.position = Vector3(0, SINK_SURFACE_Y, 0.27)
	sink_mount.add_child(_sink_water)


func is_active() -> bool:
	return GameState.plug_in and hot_tap.is_open and cold_tap.is_open


func _process(delta: float) -> void:
	if _done or GameState.won:
		return
	if is_active():
		progress = minf(progress + delta, TIME_TO_FLOOD)
	else:
		progress = maxf(0.0, progress - delta * DRAIN_RATE)
	var p := progress / TIME_TO_FLOOD

	var sink_h := clampf(p / 0.15, 0.0, 1.0) * 0.07
	_sink_water.visible = sink_h > 0.002
	_sink_water.scale.y = maxf(sink_h, 0.001)
	_sink_water.position.y = SINK_SURFACE_Y + sink_h * 0.5

	level = clampf((p - 0.2) / 0.8, 0.0, 1.0) * MAX_LEVEL
	_water.visible = level > 0.005
	_water.scale.y = maxf(level, 0.001)
	_water.position.y = level * 0.5

	if p <= 0.0:
		_stage = 0
	if p >= 0.15 and _stage < 1:
		_stage = 1
		GameState.say("overflow_start")
		Sfx.play("rattle", -8.0)
	if p >= 0.6 and _stage < 2:
		_stage = 2
		GameState.say("flood_rising")
	if p >= 1.0:
		_burst()


func _burst() -> void:
	_done = true
	GameState.say("flood_burst")
	door.burst_open()
	var t := create_tween()
	t.tween_interval(1.6)
	t.tween_callback(Sfx.play.bind("fanfare", 0.0, 1.0))
	t.tween_callback(GameState.win.bind("flood"))
