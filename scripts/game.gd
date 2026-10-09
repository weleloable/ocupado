class_name Game
extends Node3D
## One play session: room, player, HUD and overlays. Owns the UI state machine.

enum UiState { PLAYING, PHONE, KEYPAD, PAUSED, WON }

var state: UiState = UiState.PLAYING
var room: Room
var player: Player
var hud: Hud


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

	_set_state(UiState.PLAYING)


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
	if state == UiState.PLAYING and event is InputEventMouseButton and event.is_pressed() \
			and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()
