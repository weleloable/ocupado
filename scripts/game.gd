class_name Game
extends Node3D
## One play session: room, player, HUD and overlays. Owns the UI state machine.

signal restart_requested
signal menu_requested

enum UiState { PLAYING, PHONE, KEYPAD, PAUSED, WON }

var state: UiState = UiState.PLAYING
var room: Room
var player: Player
var hud: Hud
var keypad_ui: KeypadUi


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

	GameState.keypad_ui_requested.connect(_open_keypad)
	GameState.game_won.connect(_on_won)
	_set_state(UiState.PLAYING)

	await get_tree().create_timer(0.8).timeout
	GameState.say("start")
	await get_tree().create_timer(9.0).timeout
	if not GameState.lights_on:
		GameState.say("start_hint")


func _exit_tree() -> void:
	Sfx.stop_all_loops()


func _set_state(new_state: UiState) -> void:
	state = new_state
	get_tree().paused = state == UiState.PAUSED
	GameState.controls_locked = state != UiState.PLAYING
	if state == UiState.PLAYING:
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
		get_viewport().set_input_as_handled()
		return
	if state != UiState.PLAYING:
		return
	if event is InputEventMouseButton and event.is_pressed() and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
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


func _open_keypad() -> void:
	if state != UiState.PLAYING:
		return
	keypad_ui.open()
	_set_state(UiState.KEYPAD)


func _on_overlay_closed() -> void:
	if state == UiState.KEYPAD or state == UiState.PHONE:
		_set_state(UiState.PLAYING)


func _on_won() -> void:
	_set_state(UiState.WON)
	print("VICTORIA: tiempo %s, cerveza %.1f C" % [GameState.format_time(GameState.final_time), GameState.final_temp])
