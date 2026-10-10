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
	[Vector3(1.0, 0.05, -0.4), -30.0, -22.0, "c_steam"],
	[Vector3(0.2, 0.05, 0.4), -35.0, -5.0, "c_steam_far"],
	[Vector3(-0.9, 0.05, 0.4), 180.0, 12.0, "c_clue_south"],
	[Vector3(1.0, 0.05, 0.2), -90.0, 5.0, "c_clue_east"],
	[Vector3(-1.0, 0.05, -0.34), 90.0, -48.0, "c_plug"],
	[Vector3(-0.2, 0.05, 0.5), 90.0, 12.0, "c_west_clues"],
	[Vector3(1.2, 0.05, 0.3), -90.0, -27.0, "c_boiler"],
	[Vector3(-1.3, 0.05, -0.6), 0.0, -33.0, "c_board"],
	[Vector3(-0.45, 0.05, 0.7), 180.0, -39.0, "c_coaster1"],
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
	for arg: String in OS.get_cmdline_user_args():
		if arg == "--clues":
			for clue in game.room.ritual_clues:
				clue.visible = true
		if arg == "--steam":
			game.room.valve.interact()
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
	if "--oblique" in OS.get_cmdline_user_args():
		await _oblique_test()
		get_tree().quit()
		return
	if "--flood" in OS.get_cmdline_user_args():
		await _flood_shots()
	if "--trials" in OS.get_cmdline_user_args():
		await _trial_ui_shots()
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


## Text legibility test at oblique angles: `--oblique` renders each pose with every text mode.
const OBLIQUE := [
	[Vector3(1.5, 0.05, -0.9), 77.8, 4.0, "o_poem_77"],
	[Vector3(0.6, 0.05, 0.4), 44.7, 4.0, "o_poem_45"],
	[Vector3(1.2, 0.05, -0.6), 135.0, 4.0, "o_south_45"],
]


func _oblique_test() -> void:
	var originals := {}
	for l: Label3D in game.find_children("*", "Label3D", true, false):
		originals[l] = [l.texture_filter, l.alpha_cut, l.font_size, l.pixel_size, l.outline_size]
	for mode in 4:
		for l: Label3D in originals:
			var o: Array = originals[l]
			l.texture_filter = o[0]
			l.alpha_cut = o[1]
			l.font_size = o[2]
			l.pixel_size = o[3]
			l.outline_size = o[4]
			if mode >= 1:
				l.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
			if mode >= 2:
				l.alpha_cut = Label3D.ALPHA_CUT_DISABLED
			if mode >= 3:
				l.font_size = o[2] * 2
				l.pixel_size = o[3] * 0.5
				l.outline_size = o[4] * 2
		for pose: Array in OBLIQUE:
			GameState.controls_locked = true
			game.player.global_position = pose[0]
			game.player.rotation.y = deg_to_rad(pose[1])
			game.player.camera.rotation.x = deg_to_rad(pose[2])
			await _snap("%s_m%d" % [pose[3], mode])


func _trial_ui_shots() -> void:
	GameState.controls_locked = false
	game.player.global_position = Vector3(0, 0.05, 0.7)
	game.player.rotation.y = 0.0
	game.player.camera.rotation.x = 0.0
	GameState.pipes_ui_requested.emit()
	await _snap("t_pipes_start")
	game.pipes_ui._on_tile_clicked(5, 1)
	game.pipes_ui._on_tile_clicked(6, 2)
	await _snap("t_pipes_partial")
	game.pipes_ui.solve_for_test()
	await get_tree().create_timer(2.2).timeout
	GameState.coasters_read = [true, true, false, false]
	GameState.table_ui_requested.emit()
	game.table_ui.set_seats_for_test(["Paco", "Lucía", "Javi", "Marta"])
	await _snap("t_table")
	GameState.coasters_read = [true, true, true, true]
	game.table_ui.check_seating()
	await _snap("t_table_checked")
	game.table_ui.close()
	game.phone.open()
	game.phone._set_riddle_mode(true)
	await _snap("t_phone_riddle")
