class_name Game
extends Node3D
## One play session: room, player, HUD and overlays. Owns the UI state machine.

signal restart_requested
signal menu_requested

enum UiState { PLAYING, PHONE, KEYPAD, PIPES, TABLE, PAUSED, WON }

var state: UiState = UiState.PLAYING
var room: Room
var player: Player
var hud: Hud
var keypad_ui: KeypadUi
var pipes_ui: PipesUi
var table_ui: TableUi
var phone: Phone
var pause_menu: PauseMenu


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameState.start()

	room = Room.new()
	room.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(room)

	player = Player.new()
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	player.position = Vector3(0, 0.05, 0.7)
	add_child(player)

	hud = Hud.new()
	hud.process_mode = Node.PROCESS_MODE_PAUSABLE
	hud.player = player
	add_child(hud)

	keypad_ui = KeypadUi.new()
	keypad_ui.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(keypad_ui)
	keypad_ui.closed.connect(_on_overlay_closed)

	pipes_ui = PipesUi.new()
	pipes_ui.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(pipes_ui)
	pipes_ui.closed.connect(_on_overlay_closed)

	table_ui = TableUi.new()
	table_ui.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(table_ui)
	table_ui.closed.connect(_on_overlay_closed)

	phone = Phone.new()
	phone.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(phone)
	phone.closed.connect(_on_overlay_closed)

	pause_menu = PauseMenu.new()
	add_child(pause_menu)

	# Movil (web): joystick, mirar arrastrando y botones. En PC no se crea.
	if TouchControls.activo():
		var tactil := TouchControls.new()
		tactil.game = self
		add_child(tactil)
	pause_menu.resume_pressed.connect(_set_state.bind(UiState.PLAYING))
	pause_menu.restart_pressed.connect(restart_requested.emit)
	pause_menu.quit_pressed.connect(menu_requested.emit)

	GameState.keypad_ui_requested.connect(_open_keypad)
	GameState.pipes_ui_requested.connect(_open_overlay.bind(pipes_ui, UiState.PIPES))
	GameState.table_ui_requested.connect(_open_overlay.bind(table_ui, UiState.TABLE))
	GameState.game_won.connect(_on_won)
	_set_state(UiState.PLAYING)

	var intro := create_tween()
	intro.tween_interval(0.8)
	intro.tween_callback(GameState.say.bind("start"))
	intro.tween_interval(9.0)
	intro.tween_callback(func() -> void:
		if not GameState.lights_on:
			GameState.say("start_hint"))


func _exit_tree() -> void:
	Sfx.stop_all_loops()


func _set_state(new_state: UiState) -> void:
	state = new_state
	get_tree().paused = state == UiState.PAUSED
	pause_menu.visible = state == UiState.PAUSED
	GameState.controls_locked = state != UiState.PLAYING
	# En tactil no se captura: el navegador del movil no puede, y con el raton
	# "capturado" a medias cada toque se tomaria tambien como mirar y usar.
	if state == UiState.PLAYING and not TouchControls.activo():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		match state:
			UiState.PLAYING:
				_set_state(UiState.PAUSED)
			UiState.PAUSED:
				_set_state(UiState.PLAYING)
			UiState.KEYPAD:
				keypad_ui.close()
			UiState.PHONE:
				phone.close()
			UiState.PIPES:
				pipes_ui.close()
			UiState.TABLE:
				table_ui.close()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("hint"):
		if state == UiState.PLAYING:
			phone.open()
			_set_state(UiState.PHONE)
		elif state == UiState.PHONE:
			phone.close()
		get_viewport().set_input_as_handled()
		return
	if state != UiState.PLAYING:
		return
	if event is InputEventMouseButton and event.is_pressed() and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED \
			and not TouchControls.activo():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()
		return
	# Debug: instantly solve each puzzle.
	if event.is_action_pressed("debug_1"):
		GameState.solve_lights()
	elif event.is_action_pressed("debug_2"):
		GameState.solve_lights()
		GameState.solve_ritual()
	elif event.is_action_pressed("debug_3"):
		GameState.solve_mirror()
	elif event.is_action_pressed("debug_4"):
		GameState.solve_keypad()
	elif event.is_action_pressed("debug_5"):
		GameState.solve_pipes()
	elif event.is_action_pressed("debug_6"):
		GameState.solve_coasters()


func _open_keypad() -> void:
	if state != UiState.PLAYING:
		return
	keypad_ui.open()
	_set_state(UiState.KEYPAD)


func _on_overlay_closed() -> void:
	if state in [UiState.KEYPAD, UiState.PHONE, UiState.PIPES, UiState.TABLE]:
		_set_state(UiState.PLAYING)


func _on_won() -> void:
	pipes_ui.close()
	table_ui.close()
	keypad_ui.close()
	phone.close()
	_set_state(UiState.WON)
	print("VICTORIA: tiempo %s, cerveza %.1f C" % [GameState.format_time(GameState.final_time), GameState.final_temp])
	# Dentro de la app Ruta de Bares (web): se le avisa para guardar el record.
	AppBridge.fin()
	var victory := VictoryScreen.new()
	add_child(victory)
	victory.replay_pressed.connect(restart_requested.emit)
	victory.menu_pressed.connect(menu_requested.emit)


func _open_overlay(overlay: Node, target: UiState) -> void:
	if state != UiState.PLAYING:
		return
	overlay.call("open")
	_set_state(target)
