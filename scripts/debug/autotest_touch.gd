extends Node
## Debug: `godot --headless --path . -- --autotest-tactil` prueba los mandos del movil
## (TouchControls) con toques de verdad (InputEventScreenTouch / InputEventScreenDrag,
## los mismos que manda el navegador del movil) y dice PASS/FAIL.

var game: Game
var _ok: bool = true
## De coordenadas de la vista (640 x 360) a las de la ventana: los toques llegan en
## coordenadas de ventana y el juego los pasa a las de la vista (stretch canvas_items).
var _xf: Transform2D


func _ready() -> void:
	await _wait(1.0)
	_xf = get_viewport().get_final_transform()
	var tactil := _buscar_mandos()
	var p := game.player
	_check(tactil != null, "touch controls exist in touch mode")
	_check(Input.mouse_mode != Input.MOUSE_MODE_CAPTURED, "the mouse is not captured in touch mode")

	# Joystick: arrastrar hacia arriba anda hacia delante; soltar para.
	var antes := p.global_position
	_tocar(0, Vector2(100, 280), true)
	await _frame()
	_arrastrar(0, Vector2(100, 240), Vector2(0, -40))
	await _wait(0.6)
	var avance := antes.distance_to(p.global_position)
	_check(avance > 0.4, "joystick forward moves the player (%.2f m)" % avance)
	_check(p.global_position.z < antes.z, "... and it moves forward (towards -z)")
	_tocar(0, Vector2(100, 240), false)
	await _wait(0.2)
	var parado := p.global_position
	await _wait(0.4)
	_check(parado.distance_to(p.global_position) < 0.01, "releasing the joystick stops the player")

	# Medio recorrido = mitad de velocidad (el joystick tiene fuerza).
	antes = p.global_position
	_tocar(0, Vector2(100, 280), true)
	await _frame()
	_arrastrar(0, Vector2(100, 260), Vector2(0, -20))
	await _wait(0.5)
	var medio := antes.distance_to(p.global_position)
	_tocar(0, Vector2(100, 260), false)
	await _wait(0.2)
	_check(medio > 0.1 and medio < avance * 0.7, "half a joystick walks slower (%.2f m vs %.2f m)" % [medio, avance])

	# Mirar: arrastrar a la derecha gira la vista; arrastrar no "usa" nada.
	var yaw := p.rotation.y
	_tocar(1, Vector2(450, 180), true)
	await _frame()
	_arrastrar(1, Vector2(510, 180), Vector2(60, 0))
	await _frame()
	_tocar(1, Vector2(510, 180), false)
	await _frame()
	var girado := p.rotation.y - yaw
	_check(absf(girado + 60.0 * TouchControls.SENS_MIRAR) < 0.02, "dragging on the right turns the view (%.2f rad)" % girado)

	# Un toque corto a la derecha usa lo que apunta la cruz (el tapon).
	await _apuntar(Vector3(-1.0, 0.05, -0.34), 90.0, -48.0)
	_check(p.focused == game.room.plug, "aiming at the plug")
	var tapon := GameState.plug_in
	_tocar(1, Vector2(450, 150), true)
	await _wait(0.05)
	_tocar(1, Vector2(450, 150), false)
	await _frame()
	_check(GameState.plug_in != tapon, "a short tap on the right uses what the crosshair aims at")

	# Arrastrar y soltar NO es un toque: no usa nada.
	await _apuntar(Vector3(-1.0, 0.05, -0.34), 90.0, -48.0)
	tapon = GameState.plug_in
	_tocar(1, Vector2(450, 150), true)
	await _frame()
	_arrastrar(1, Vector2(452, 150), Vector2(2, 0))
	_arrastrar(1, Vector2(470, 150), Vector2(18, 0))
	await _frame()
	_tocar(1, Vector2(470, 150), false)
	await _frame()
	_check(GameState.plug_in == tapon, "a drag is not a tap: it does not use anything")

	# Boton USAR. Primero el tapon a su sitio: puesto, se mueve al desague y la cruz ya
	# no lo apunta desde aqui (sin esto el boton no tendria nada que usar).
	if GameState.plug_in:
		game.room.plug.interact()
	await _apuntar(Vector3(-1.0, 0.05, -0.34), 90.0, -48.0)
	_check(p.focused == game.room.plug, "aiming at the plug again")
	tapon = GameState.plug_in
	await _boton(tactil, "usar")
	_check(GameState.plug_in != tapon, "the USAR button uses what the crosshair aims at")

	# Movil (pistas) y Cerrar (no hay tecla Esc en un movil).
	await _boton(tactil, "movil")
	_check(game.state == Game.UiState.PHONE and game.phone.visible, "the Movil button opens the phone")
	await _boton(tactil, "cerrar")
	_check(game.state == Game.UiState.PLAYING and not game.phone.visible, "Cerrar closes the panel")

	# Pausa.
	await _boton(tactil, "pausa")
	_check(get_tree().paused and game.pause_menu.visible, "the pause button pauses")
	var reanudar := InputEventAction.new()
	reanudar.action = "pause"
	reanudar.pressed = true
	game._unhandled_input(reanudar)
	await _frame()
	_check(not get_tree().paused, "resumed")

	# Con el dedo en el joystick se abre un panel: al cerrarlo el jugador NO sigue andando.
	await _apuntar(Vector3(0, 0.05, 0.7), 0.0, 0.0)
	_tocar(0, Vector2(100, 280), true)
	await _frame()
	_arrastrar(0, Vector2(100, 240), Vector2(0, -40))
	await _wait(0.2)
	await _boton(tactil, "movil")
	await _wait(0.2)
	await _boton(tactil, "cerrar")
	await _wait(0.2)
	var quieto := p.global_position
	await _wait(0.4)
	_check(quieto.distance_to(p.global_position) < 0.01, "opening a panel releases the joystick")
	_tocar(0, Vector2(100, 240), false)

	# El aviso a la app no hace nada fuera de la web (y no revienta).
	AppBridge.fin()
	_check(true, "AppBridge.fin() outside the web is a no-op")

	print("AUTOTEST TACTIL RESULT: ", "PASS" if _ok else "FAIL")
	get_tree().quit(0 if _ok else 1)


func _buscar_mandos() -> TouchControls:
	for hijo in game.get_children():
		if hijo is TouchControls:
			return hijo as TouchControls
	return null


func _tocar(dedo: int, en_vista: Vector2, pulsado: bool) -> void:
	var ev := InputEventScreenTouch.new()
	ev.index = dedo
	ev.position = _xf * en_vista
	ev.pressed = pulsado
	Input.parse_input_event(ev)


func _arrastrar(dedo: int, en_vista: Vector2, rel_vista: Vector2) -> void:
	var ev := InputEventScreenDrag.new()
	ev.index = dedo
	ev.position = _xf * en_vista
	ev.relative = _xf.basis_xform(rel_vista)
	ev.screen_relative = ev.relative
	Input.parse_input_event(ev)


func _boton(tactil: TouchControls, nombre: String) -> void:
	var centro: Vector2 = (tactil._botones[nombre] as Rect2).get_center()
	_tocar(7, centro, true)
	await _frame()
	_tocar(7, centro, false)
	await _wait(0.1)


func _apuntar(pos: Vector3, yaw: float, pitch: float) -> void:
	game.player.global_position = pos
	game.player.rotation.y = deg_to_rad(yaw)
	game.player.camera.rotation.x = deg_to_rad(pitch)
	await _wait(0.4)


func _frame() -> void:
	await get_tree().process_frame
	await get_tree().process_frame


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _check(cond: bool, what: String) -> void:
	print(("  ok   " if cond else "  FAIL ") + what)
	if not cond:
		_ok = false
