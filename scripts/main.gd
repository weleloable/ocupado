extends Node
## Entry point: shows the main menu or starts a game directly.

const Screenshots := preload("res://scripts/debug/screenshots.gd")
const Autotest := preload("res://scripts/debug/autotest.gd")

var game: Game


func _ready() -> void:
	var shots_dir := ""
	var lights := false
	var autotest := false
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--shots="):
			shots_dir = arg.substr(8)
		elif arg == "--lights":
			lights = true
		elif arg == "--autotest":
			autotest = true
	_start_game()
	if autotest:
		var test := Autotest.new()
		test.game = game
		test.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(test)
	if not shots_dir.is_empty():
		var shots := Screenshots.new()
		shots.game = game
		shots.out_dir = shots_dir
		shots.lights = lights
		shots.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(shots)


func _start_game() -> void:
	game = Game.new()
	add_child(game)
