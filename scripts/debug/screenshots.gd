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
	for pose: Array in POSES:
		game.player.global_position = pose[0]
		game.player.rotation.y = deg_to_rad(pose[1])
		game.player.camera.rotation.x = deg_to_rad(pose[2])
		await get_tree().create_timer(0.3).timeout
		await RenderingServer.frame_post_draw
		var img := get_viewport().get_texture().get_image()
		var path := out_dir.path_join("%s.png" % pose[3])
		img.save_png(path)
		print("saved ", path)
	get_tree().quit()
