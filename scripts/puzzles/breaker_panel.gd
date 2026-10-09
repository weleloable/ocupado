class_name BreakerPanel
extends Node3D
## Puzzle 1: electrical panel with 4 switches and 4 pilot lights (Lights Out).
## Built in local space: +Z points into the room, +X is the viewer's right.

const COLOR_ON := Color(0.2, 1.0, 0.3)
const COLOR_OFF := Color(0.9, 0.12, 0.08)

var state: Array[bool] = []
var switches: Array[BreakerSwitch] = []
var pilot_mats: Array[StandardMaterial3D] = []
var solved: bool = false


func _ready() -> void:
	state = LightsOut.initial_state()
	var body := StaticBody3D.new()
	add_child(body)
	Build.box(body, Vector3(0.8, 0.62, 0.08), Vector3(0, 0, 0.04), Build.mat(Color(0.55, 0.57, 0.6)))
	Build.collider(body, Vector3(0.8, 0.62, 0.08), Vector3(0, 0, 0.04))
	# Yellow warning stripe.
	Build.box(self, Vector3(0.8, 0.05, 0.01), Vector3(0, 0.285, 0.085), Build.mat(Color(0.95, 0.8, 0.1)))
	Build.label(self, "CUADRO ELÉCTRICO\nNO TOCAR", Vector3(0, 0.43, 0.01), 0.0, 24,
			Color(0.95, 0.85, 0.2), 0.004, 6)
	for i in 4:
		var x := -0.27 + i * 0.18
		var pm := Build.mat_unique(COLOR_OFF, 2.0, true)
		Build.box(self, Vector3(0.06, 0.06, 0.03), Vector3(x, 0.17, 0.095), pm)
		pilot_mats.append(pm)
		var sw := BreakerSwitch.new()
		sw.panel = self
		sw.index = i
		sw.position = Vector3(x, -0.05, 0.08)
		add_child(sw)
		switches.append(sw)
		Build.label(self, str(i + 1), Vector3(x, -0.23, 0.085), 0.0, 28, Color.BLACK, 0.004)
	_refresh()
	GameState.lights_turned_on.connect(_on_lights_on)


func press(i: int) -> void:
	Sfx.play("click")
	if solved:
		GameState.say("breaker_locked")
		return
	state = LightsOut.press(state, i)
	switches[i].flip()
	_refresh()
	if LightsOut.is_solved(state):
		solved = true
		Sfx.play("success")
		GameState.solve_lights()


func _refresh() -> void:
	for i in pilot_mats.size():
		var c := COLOR_ON if state[i] else COLOR_OFF
		pilot_mats[i].albedo_color = c
		pilot_mats[i].emission = c


func _on_lights_on() -> void:
	solved = true
	for i in state.size():
		state[i] = true
	_refresh()
