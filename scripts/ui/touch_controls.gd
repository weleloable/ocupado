class_name TouchControls
extends CanvasLayer
## Mandos tactiles para jugar en el movil (la version web, dentro de la app Ruta
## de Bares). Solo existen en pantallas tactiles o con `-- --tactil`: en PC el
## juego sigue con teclado y raton, igual que antes.
##
##  - Mitad IZQUIERDA: joystick. Donde se apoya el dedo aparece la base y se
##    arrastra para andar (con fuerza: poco arrastre = andar despacio).
##  - Mitad DERECHA: arrastrar para mirar. Un toque corto sin arrastrar USA lo
##    que apunta la cruz (lo mismo que E o el clic).
##  - Botones: USAR (abajo a la derecha), Movil (pistas, como H) y Pausa (como
##    Esc). Con un panel abierto (movil, teclado, tuberias, posavasos) sale
##    "Cerrar", que hace de Esc: en el movil no hay tecla Esc.
##
## Por que hace falta: el juego solo mira y usa con el raton CAPTURADO, y un
## navegador de movil no captura el raton. En modo tactil el juego no lo intenta
## (ver Game._set_state) y estos mandos llaman directamente a Player.mirar /
## Player.interactuar.

const VIEW := Vector2(640, 360)
const JOY_RADIO := 40.0
## Hasta donde llega la zona del joystick (fraccion del ancho).
const JOY_ZONA := 0.42
## Radianes por pixel de arrastre: cruzar media pantalla (~320 px) gira ~165 grados.
const SENS_MIRAR := 0.009
## Un toque cuenta como "usar" si dura menos y se mueve menos que esto.
const TOQUE_MAX_S := 0.30
const TOQUE_MAX_PX := 10.0
const PANELES := [Game.UiState.PHONE, Game.UiState.KEYPAD, Game.UiState.PIPES, Game.UiState.TABLE]

## Para probar en PC y en el autotest (`-- --tactil`).
static var forzado: bool = false

var game: Game

var _dibujo: Control
var _joy_dedo: int = -1
var _joy_origen := Vector2.ZERO
var _joy_vec := Vector2.ZERO
var _mirar_dedo: int = -1
var _mirar_inicio := Vector2.ZERO
var _mirar_desde_ms: int = 0
var _mirar_movido: bool = false
## Dedo que pulso cada boton (para no tomar su levantar como un toque de mirar).
var _boton_de_dedo: Dictionary = {}
var _botones := {
	"usar": Rect2(552, 262, 72, 72),
	"movil": Rect2(8, 8, 60, 26),
	"pausa": Rect2(74, 8, 34, 26),
	"cerrar": Rect2(8, 8, 84, 28),
}
var _etiquetas: Dictionary = {}


static func activo() -> bool:
	return forzado or DisplayServer.is_touchscreen_available()


func _ready() -> void:
	layer = 4
	process_mode = Node.PROCESS_MODE_ALWAYS
	_dibujo = UiUtil.full_rect_control(self)
	_dibujo.draw.connect(_pintar)
	_etiquetas["usar"] = UiUtil.label(_dibujo, "USAR", Vector2(552, 288), Vector2(72, 20), 13,
			Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_etiquetas["movil"] = UiUtil.label(_dibujo, "Móvil", Vector2(8, 12), Vector2(60, 18), 11,
			Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_etiquetas["pausa"] = UiUtil.label(_dibujo, "II", Vector2(74, 12), Vector2(34, 18), 11,
			Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_etiquetas["cerrar"] = UiUtil.label(_dibujo, "✕ Cerrar", Vector2(8, 13), Vector2(84, 18), 11,
			Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)


func _jugando() -> bool:
	return game != null and game.state == Game.UiState.PLAYING


func _en_panel() -> bool:
	return game != null and game.state in PANELES


func _process(_delta: float) -> void:
	# Al abrir un panel (o pausar) con el dedo puesto, se suelta todo: si no, al
	# volver el jugador seguiria andando solo.
	if not _jugando():
		_soltar_joystick()
		_mirar_dedo = -1
		_boton_de_dedo.clear()
	var jugando := _jugando()
	var panel := _en_panel()
	_etiquetas["usar"].visible = jugando
	_etiquetas["movil"].visible = jugando
	_etiquetas["pausa"].visible = jugando
	_etiquetas["cerrar"].visible = panel
	_dibujo.queue_redraw()


func _input(event: InputEvent) -> void:
	if game == null:
		return
	if event is InputEventScreenTouch:
		_toque(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_arrastre(event as InputEventScreenDrag)


func _toque(t: InputEventScreenTouch) -> void:
	var p := t.position
	if t.pressed:
		if _en_panel() and _botones["cerrar"].has_point(p):
			_accion("pause")
			get_viewport().set_input_as_handled()
			return
		if not _jugando():
			return
		for nombre: String in ["usar", "movil", "pausa"]:
			if (_botones[nombre] as Rect2).has_point(p):
				_boton_de_dedo[t.index] = nombre
				_pulsar(nombre)
				get_viewport().set_input_as_handled()
				return
		if p.x < VIEW.x * JOY_ZONA:
			if _joy_dedo == -1:
				_joy_dedo = t.index
				_joy_origen = p
				_joy_vec = Vector2.ZERO
		elif _mirar_dedo == -1:
			_mirar_dedo = t.index
			_mirar_inicio = p
			_mirar_desde_ms = Time.get_ticks_msec()
			_mirar_movido = false
		get_viewport().set_input_as_handled()
		return
	# Levantar el dedo.
	if _boton_de_dedo.has(t.index):
		_boton_de_dedo.erase(t.index)
		get_viewport().set_input_as_handled()
		return
	if t.index == _joy_dedo:
		_soltar_joystick()
		get_viewport().set_input_as_handled()
	elif t.index == _mirar_dedo:
		var corto := Time.get_ticks_msec() - _mirar_desde_ms <= int(TOQUE_MAX_S * 1000.0)
		if corto and not _mirar_movido and _jugando():
			game.player.interactuar()
		_mirar_dedo = -1
		get_viewport().set_input_as_handled()


func _arrastre(d: InputEventScreenDrag) -> void:
	if not _jugando():
		return
	if d.index == _joy_dedo:
		var v := d.position - _joy_origen
		if v.length() > JOY_RADIO:
			v = v.normalized() * JOY_RADIO
		_joy_vec = v / JOY_RADIO
		_aplicar_joystick()
		get_viewport().set_input_as_handled()
	elif d.index == _mirar_dedo:
		game.player.mirar(d.relative * SENS_MIRAR)
		if d.position.distance_to(_mirar_inicio) > TOQUE_MAX_PX:
			_mirar_movido = true
		get_viewport().set_input_as_handled()


## Las acciones de andar CON FUERZA: Player usa Input.get_vector, que la respeta.
func _aplicar_joystick() -> void:
	_fuerza("move_right", maxf(_joy_vec.x, 0.0))
	_fuerza("move_left", maxf(-_joy_vec.x, 0.0))
	_fuerza("move_back", maxf(_joy_vec.y, 0.0))
	_fuerza("move_forward", maxf(-_joy_vec.y, 0.0))


func _fuerza(accion: String, valor: float) -> void:
	if valor > 0.05:
		Input.action_press(accion, valor)
	else:
		Input.action_release(accion)


func _soltar_joystick() -> void:
	if _joy_dedo == -1 and _joy_vec == Vector2.ZERO:
		return
	_joy_dedo = -1
	_joy_vec = Vector2.ZERO
	for accion: String in ["move_right", "move_left", "move_back", "move_forward"]:
		Input.action_release(accion)


func _pulsar(nombre: String) -> void:
	match nombre:
		"usar":
			game.player.interactuar()
		"movil":
			_accion("hint")
		"pausa":
			_accion("pause")


## Una pulsacion de una accion (como si se pulsase y soltase su tecla).
func _accion(nombre: String) -> void:
	var ev := InputEventAction.new()
	ev.action = nombre
	ev.pressed = true
	Input.parse_input_event(ev)
	var suelta := InputEventAction.new()
	suelta.action = nombre
	suelta.pressed = false
	Input.parse_input_event(suelta)


func _pintar() -> void:
	var blanco := Color(1, 1, 1, 0.22)
	if _jugando():
		# Joystick: donde esta el dedo; si no, una pista tenue de donde ponerlo.
		var base := _joy_origen if _joy_dedo != -1 else Vector2(84, 280)
		_dibujo.draw_circle(base, JOY_RADIO, Color(0, 0, 0, 0.25))
		_dibujo.draw_arc(base, JOY_RADIO, 0.0, TAU, 40, blanco, 2.0)
		_dibujo.draw_circle(base + _joy_vec * JOY_RADIO, 16.0, Color(1, 1, 1, 0.45 if _joy_dedo != -1 else 0.25))
		var usar: Rect2 = _botones["usar"]
		var resaltado := game.player.focused != null and is_instance_valid(game.player.focused)
		_dibujo.draw_circle(usar.get_center(), usar.size.x / 2.0,
				Color(0.95, 0.65, 0.15, 0.75) if resaltado else Color(0, 0, 0, 0.35))
		_dibujo.draw_arc(usar.get_center(), usar.size.x / 2.0, 0.0, TAU, 48, blanco, 2.0)
		for nombre: String in ["movil", "pausa"]:
			_dibujo.draw_rect(_botones[nombre], Color(0, 0, 0, 0.45))
	elif _en_panel():
		_dibujo.draw_rect(_botones["cerrar"], Color(0.6, 0.12, 0.12, 0.85))
