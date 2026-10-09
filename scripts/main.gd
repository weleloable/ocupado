extends Node
## Entry point: shows the main menu or starts a game directly.
## Debug args (after `--`): --autotest, --shots=<dir> [--lights] [--solve=1234]

const Screenshots := preload("res://scripts/debug/screenshots.gd")
const Autotest := preload("res://scripts/debug/autotest.gd")

var game: Game
var menu: MainMenu


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

	if autotest or not shots_dir.is_empty() or GameState.skip_menu:
		_start_game()
	else:
		_show_menu()

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


func _show_menu() -> void:
	GameState.reset()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	menu = MainMenu.new()
	add_child(menu)
	menu.play_pressed.connect(_on_play)


func _on_play() -> void:
	menu.queue_free()
	menu = null
	_start_game()


func _start_game() -> void:
	game = Game.new()
	add_child(game)
	game.restart_requested.connect(_reload.bind(true))
	game.menu_requested.connect(_reload.bind(false))


func _reload(skip_menu: bool) -> void:
	GameState.skip_menu = skip_menu
	get_tree().paused = false
	get_tree().reload_current_scene.call_deferred()
