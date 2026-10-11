extends Node
## Entry point: shows the main menu or starts a game directly.
## Debug args (after `--`): --autotest, --autotest-flood, --autotest-tactil, --tactil,
## --shots=<dir> [--lights] [--solve=1234]

const Screenshots := preload("res://scripts/debug/screenshots.gd")
const Autotest := preload("res://scripts/debug/autotest.gd")
const AutotestFlood := preload("res://scripts/debug/autotest_flood.gd")
const AutotestTouch := preload("res://scripts/debug/autotest_touch.gd")

var game: Game
var menu: MainMenu


func _ready() -> void:
	var shots_dir := ""
	var lights := false
	var autotest := false
	var autotest_flood := false
	var autotest_touch := false
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--shots="):
			shots_dir = arg.substr(8)
		elif arg == "--lights":
			lights = true
		elif arg == "--autotest-flood":
			autotest_flood = true
		elif arg == "--autotest":
			autotest = true
		elif arg == "--autotest-tactil":
			autotest_touch = true
			TouchControls.forzado = true
		elif arg == "--tactil":
			# Para probar los mandos del movil en PC.
			TouchControls.forzado = true

	# Web: `?prueba=ganar` empieza y gana sola a los 2 s, para probar el aviso a la app
	# (AppBridge) sin jugar 10 minutos. Solo hace trampas contra uno mismo: el record es local.
	var prueba_ganar := OS.has_feature("web") \
			and str(JavaScriptBridge.eval("new URLSearchParams(location.search).get('prueba') || ''", true)) == "ganar"
	if prueba_ganar:
		GameState.persist_endings = false
		_start_game()
		var t := create_tween()
		t.tween_interval(2.0)
		t.tween_callback(GameState.win.bind("door"))
		return

	var debug_run := autotest or autotest_flood or autotest_touch or not shots_dir.is_empty()
	if debug_run or "--restart-test" in OS.get_cmdline_user_args():
		GameState.persist_endings = false
	if debug_run or GameState.skip_menu:
		_start_game()
	else:
		_show_menu()

	if "--restart-test" in OS.get_cmdline_user_args():
		_restart_test()
	if autotest_flood:
		var flood_test := AutotestFlood.new()
		flood_test.game = game
		flood_test.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(flood_test)
	if autotest_touch:
		var touch_test := AutotestTouch.new()
		touch_test.game = game
		touch_test.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(touch_test)
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


## Debug: menu -> play -> restart -> menu, printing the state at each step.
func _restart_test() -> void:
	var step: int = Engine.get_meta("restart_step", 0)
	Engine.set_meta("restart_step", step + 1)
	var t := create_tween()
	t.tween_interval(1.0)
	match step:
		0:
			print("menu at start: %s" % (menu != null))
			t.tween_callback(func() -> void: menu.play_pressed.emit())
			t.tween_interval(1.0)
			t.tween_callback(func() -> void:
				print("play from menu: game=%s running=%s" % [game != null, GameState.running])
				GameState.solve_lights()
				game.restart_requested.emit())
		1:
			print("restart: game=%s menu=%s lights_on=%s" % [game != null, menu != null, GameState.lights_on])
			t.tween_callback(func() -> void: game.menu_requested.emit())
		2:
			print("back to menu: menu=%s game=%s" % [menu != null, game != null])
			t.tween_callback(get_tree().quit)


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
