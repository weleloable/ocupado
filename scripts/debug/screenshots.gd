extends Node
## Debug helper: `godot --path . -- --shots=<dir> [--lights]` saves PNGs from preset poses and quits.

var game: Game
var out_dir: String = ""
var lights: bool = false

## [position, yaw_degrees, pitch_degrees, name]
const POSES := [
	[Vector3(0, 0.05, 0.7), 0.0, 0.0, "north_door"],
	[Vector3(0.6, 0.05, -0.4), -90.0, -5.0, "east_breaker"],
	[Vector3(-0.9, 0.05, -0.2), 90.0, -10.0, "west_sink"],
	[Vector3(0, 0.05, -0.6), 180.0, -5.0, "south_wall"],
	[Vector3(0.6, 0.05, 0.4), -60.0, 0.0, "east_toilet"],
	[Vector3(-0.3, 0.05, -0.3), 145.0, -10.0, "southwest"],
]


## Close-ups of every sign / label, to check text fits its support.
const CLOSEUPS := [
	[Vector3(0.4, 0.05, -0.6), 0.0, -6.0, "c_door_sign"],
	[Vector3(-0.45, 0.05, -0.7), 0.0, -18.0, "c_keypad"],
	[Vector3(-0.9, 0.05, 0.8), 180.0, -26.0, "c_dryer"],
	[Vector3(0.9, 0.05, 0.8), 180.0, -22.0, "c_dispenser"],
	[Vector3(0.0, 0.05, 0.7), 180.0, 20.0, "c_employees"],
	[Vector3(1.2, 0.05, -0.75), -90.0, -14.0, "c_breaker"],
	[Vector3(-1.2, 0.05, -0.2), 90.0, 0.0, "c_mirror"],
	[Vector3(-0.9, 0.05, 0.2), 0.0, 8.0, "c_north_left"],
	[Vector3(1.0, 0.05, 0.6), -90.0, 4.0, "c_east_toilet"],
	[Vector3(1.2, 0.05, 0.63), -90.0, -34.0, "c_valve"],
	[Vector3(-1.0, 0.05, -0.2), 90.0, -44.0, "c_plug"],
	[Vector3(-0.2, 0.05, 0.5), 90.0, 12.0, "c_west_clues"],
]


func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	if lights:
		GameState.solve_lights()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--solve="):
			for c in arg.substr(8):
				match c:
					"1": GameState.solve_lights()
					"2": GameState.solve_ritual()
					"3": GameState.solve_mirror()
					"4": GameState.solve_keypad()
	await get_tree().create_timer(1.5).timeout
	var poses: Array = CLOSEUPS if "--closeups" in OS.get_cmdline_user_args() else POSES
	for pose: Array in poses:
		GameState.controls_locked = true
		game.player.global_position = pose[0]
		game.player.rotation.y = deg_to_rad(pose[1])
		game.player.camera.rotation.x = deg_to_rad(pose[2])
		await get_tree().create_timer(0.3).timeout
		await RenderingServer.frame_post_draw
		var img := get_viewport().get_texture().get_image()
		var path := out_dir.path_join("%s.png" % pose[3])
		img.save_png(path)
		print("saved ", path)
	if "--flood" in OS.get_cmdline_user_args():
		await _flood_shots()
	if "--ui" in OS.get_cmdline_user_args():
		await _ui_shots()
	get_tree().quit()


func _snap(shot_name: String) -> void:
	await get_tree().create_timer(0.4).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(out_dir.path_join(shot_name + ".png"))
	print("saved ", shot_name)


func _ui_shots() -> void:
	game.player.global_position = Vector3(0, 0.05, 0.7)
	game.player.rotation.y = 0.0
	game.player.camera.rotation.x = 0.0
	GameState.controls_locked = false
	GameState.say_text("Texto de prueba del narrador, bastante largo para ver si cabe en dos líneas sin salirse de la caja.")
	await get_tree().create_timer(3.0).timeout
	await _snap("ui_hud")
	var ev := InputEventAction.new()
	ev.action = "hint"
	ev.pressed = true
	game._unhandled_input(ev)
	game.phone.request_hint()
	game.phone.request_hint()
	await _snap("ui_phone")
	game.phone.close()
	GameState.keypad_ui_requested.emit()
	game.keypad_ui.type_code("33")
	await _snap("ui_keypad")
	game.keypad_ui.close()
	GameState.win()
	await get_tree().create_timer(1.0).timeout
	await _snap("ui_victory")


func _flood_shots() -> void:
	GameState.controls_locked = true
	game.player.global_position = Vector3(0.9, 0.05, 0.9)
	game.player.rotation.y = deg_to_rad(120.0)
	game.player.camera.rotation.x = deg_to_rad(-25.0)
	var room := game.room
	room.plug.interact()
	room.hot_tap.interact()
	room.cold_tap.interact()
	await get_tree().create_timer(1.5).timeout
	await _snap("f_sink_filling")
	room.flood.progress = Flood.TIME_TO_FLOOD * 0.55
	await _snap("f_flooding")
	room.flood.progress = Flood.TIME_TO_FLOOD * 0.97
	await _snap("f_almost")
