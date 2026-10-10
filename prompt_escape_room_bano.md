# Prompt para Claude Code — "Ocupado" (escape room en el baño de un bar) · versión 4.2

Vas a crear desde cero un juego completo y jugable en **Godot 4.7 con GDScript**. Este documento es la especificación detallada de una versión que ya existe y que ha sido probada por el jugador. **El objetivo es reproducir un juego casi idéntico**: respeta las medidas, posiciones, colores, constantes, textos literales y la arquitectura que se describen aquí. Donde algo no esté especificado, decide tú con el mismo estilo.

Trabaja de forma autónoma; no hagas preguntas salvo que algo te bloquee de verdad. Prioriza siempre que el juego funcione de principio a fin sin errores. Al terminar, da un resumen corto de qué hay hecho y qué hay que probar a mano.

**Todos los textos del juego en español. Código, identificadores y comentarios en inglés. GDScript con tipado estático.**

---

## 1. El juego en una página

- **Título:** Ocupado.
- **Premisa:** estás en un bar con tus amigos (Paco, Lucía, Javi y Marta). Vas al baño y la puerta no abre. Fuera te espera una cerveza que se va calentando.
- **Tono:** humor absurdo y costumbrista de bar español. El baño tiene una seguridad ridícula (teclado numérico, cuadro eléctrico, caldera…) y solo el narrador lo cuestiona.
- **Perspectiva:** 3D en primera persona, una única sala de 4 × 3 m y 2,6 m de alto.
- **Duración:** 10-15 minutos.
- **Puntuación:** la temperatura de la cerveza. No hay derrota.
- **Dos finales:** "Tirar, que no empujar" (salida normal) y "Que lo limpie el bar" (secreto: inundar el baño).
- **Pruebas:** cuadro eléctrico (da la luz), ritual en cadena, espejo con vapor, tuberías de la caldera, posavasos (deducción), acertijos del cuñado (extra) y teclado de la puerta con el código **3312**. Cada una de cuatro pruebas revela **una** cifra del código.

## 2. Entorno, versión y configuración

- Godot **4.7.2 stable**. En la máquina del jugador **no está en el PATH**: está en `C:\Users\Eduardo\Documents\EDUARDO\Godot_v4.7.2-stable_win64.exe\` (es una carpeta) y dentro hay `Godot_v4.7.2-stable_win64.exe` (editor) y `Godot_v4.7.2-stable_win64_console.exe` (úsalo para todo lo headless y para leer errores). Comprueba la versión con `--version` y usa solo APIs de esa versión.
- Antes de ejecutar nada tras crear o renombrar clases con `class_name`, ejecuta `godot --headless --path . --import`: sin eso, la caché de clases globales no existe y aparecen errores de "identifier not found".
- `project.godot` (se escribe a mano, es pequeño):

```
config_version=5

[application]
config/name="Ocupado"
config/description="Escape room en el baño de un bar. Tu cerveza se calienta."
run/main_scene="res://scenes/main.tscn"
config/features=PackedStringArray("4.7", "GL Compatibility")
config/icon="res://icon.png"

[autoload]
GameState="*res://scripts/autoload/game_state.gd"
Sfx="*res://scripts/autoload/sfx.gd"

[display]
window/size/viewport_width=640
window/size/viewport_height=360
window/size/window_width_override=1280
window/size/window_height_override=720
window/stretch/mode="viewport"

[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/canvas_textures/default_texture_filter=0
textures/default_filters/anisotropic_filtering_level=4
```

- Resolución interna **640 × 360** con stretch `viewport` y filtro `nearest`: el juego se ve pixelado (retro) en una ventana de 1280 × 720. Todas las coordenadas de UI de este documento son en ese espacio de 640 × 360.
- Las acciones de entrada se registran por código con `InputMap` (clase `InputSetup`, llamada desde `GameState._ready`): `move_forward` (W, ↑), `move_back` (S, ↓), `move_left` (A, ←), `move_right` (D, →), `interact` (E y clic izquierdo), `hint` (H), `pause` (Esc), `debug_1`…`debug_6` (F1…F6). Usa `physical_keycode`.
- `.gitignore`: `.godot/`, `*.tmp`, `export/`, `*.exe`, `*.pck`. `.gitattributes`: `* text=auto eol=lf` y `*.png binary`. **Nunca** subas a git los `.exe` exportados (pesan ~100 MB): usa `git add` con cuidado.

## 3. Arquitectura y archivos

Escenas `.tscn` mínimas: solo `scenes/main.tscn` (un `Node` con `main.gd`). **Todo lo demás se construye por código.**

```
scenes/main.tscn                  Node "Main" con scripts/main.gd
scripts/main.gd                   menú o partida; reinicio con reload_current_scene; flags de depuración
scripts/game.gd                   class Game: sala, jugador, HUD, overlays y máquina de estados de UI
scripts/autoload/game_state.gd    progreso, cifras, temperatura, pistas, finales, señales
scripts/autoload/sfx.gd           sonidos sintetizados por código (AudioStreamWAV)
scripts/core/input_setup.gd       class InputSetup
scripts/core/build.gd             class Build: materiales, primitivas, colisiones, textos 3D
scripts/core/interactable.gd      class Interactable (StaticBody3D) base de todo lo usable
scripts/core/decor_item.gd        class DecorItem: decoración que solo dispara al narrador
scripts/core/player.gd            class Player (CharacterBody3D)
scripts/core/room.gd              class Room: construye la sala entera
scripts/data/lines.gd             class Lines: TODOS los textos del narrador, pistas, finales, veredictos
scripts/data/riddles.gd           class Riddles: acertijos del cuñado
scripts/puzzles/lights_out.gd     class LightsOut (lógica pura del cuadro eléctrico)
scripts/puzzles/breaker_panel.gd  class BreakerPanel + breaker_switch.gd (class BreakerSwitch)
scripts/puzzles/hand_dryer.gd     class HandDryer
scripts/puzzles/toilet_chain.gd   class ToiletChain
scripts/puzzles/mop.gd            class Mop
scripts/puzzles/tap.gd            class Tap
scripts/puzzles/mirror.gd         class MirrorFog
scripts/puzzles/valve.gd          class Valve (palanca de vapor)
scripts/puzzles/steam_pipe.gd     class SteamPipe (tubería roja, manómetro, vapor)
scripts/puzzles/dispenser.gd      class Dispenser
scripts/puzzles/pipe_grid.gd      class PipeGrid (lógica pura de las tuberías)
scripts/puzzles/boiler_panel.gd   class BoilerPanel
scripts/puzzles/seating.gd        class SeatingPuzzle (lógica pura de los posavasos)
scripts/puzzles/coaster.gd        class Coaster
scripts/puzzles/table_board.gd    class TableBoard
scripts/puzzles/keypad.gd         class Keypad
scripts/puzzles/door.gd           class Door
scripts/puzzles/sink_plug.gd      class SinkPlug
scripts/puzzles/flood.gd          class Flood (final secreto)
scripts/ui/ui_util.gd             class UiUtil: label/rect/button/full_rect_control; VIEW = 640x360
scripts/ui/hud.gd                 class Hud (+ narrator.gd: class Narrator)
scripts/ui/phone.gd               class Phone
scripts/ui/keypad_ui.gd           class KeypadUi
scripts/ui/pipes_ui.gd            class PipesUi (clase interna PipeTile)
scripts/ui/table_ui.gd            class TableUi
scripts/ui/pause_menu.gd          class PauseMenu
scripts/ui/main_menu.gd           class MainMenu
scripts/ui/victory_screen.gd      class VictoryScreen
scripts/debug/autotest.gd         partida completa automática
scripts/debug/autotest_flood.gd   final secreto automático
scripts/debug/screenshots.gd      capturas de pantalla para revisar el aspecto
tests/test_lights_out.gd, tests/test_pipes.gd, tests/test_seating.gd
tools/make_icon.gd                genera icon.png e icon.ico
tools/compare_crops.gd            amplía recortes de capturas para compararlos
```

### 3.1 `Build` (helpers de construcción)

- `mat(color, emission=0, unshaded=false)`: material **cacheado** (no modificar). `mat_unique(...)`: material nuevo (para lo que cambia en ejecución). Todos con `roughness 0.85`, filtro `nearest`, transparencia si `color.a < 1`.
- `tile_material(c1, c2, grout, tiles_per_meter, checker, seed, use_grout=true)`: textura procedural `Image` de 32 × 32 (2 × 2 baldosas de 16 px) con junta de 1 px, ruido por píxel ±0,03, tinte por baldosa ±0,04 y 2,5 % de píxeles sucios (−30 %). Mapeo **triplanar en espacio mundo** (`uv1_world_triplanar`), `uv1_scale = tiles_per_meter / 2`, filtro `nearest`, `roughness 0.7`.
- `box(parent, size, pos, mat, rot)`, `cylinder(parent, radius, height, pos, mat, rot)` (12 segmentos), `collider(body, size, pos)`, `static_box(parent, size, pos, mat)`.
- **Textos 3D**: `label(parent, text, pos, rot_y, font_size, color, pixel_size, outline)` y sobre todo `label_fit(parent, text, pos, rot_y, max_size: Vector2, color, outline=0, font_size=96)`, que mide el texto con la fuente y calcula `pixel_size` para que **todo el texto quepa en `max_size` metros** (ancho de la línea más larga y alto total). Reglas obligatorias de todo `Label3D`:
  - fuente = `FontVariation` de `ThemeDB.fallback_font` con `variation_embolden = 0.35` (`Build.label_font()`, compartida);
  - `texture_filter = LINEAR_WITH_MIPMAPS_ANISOTROPIC` (no `nearest`: con `nearest` las letras se deforman al verlas de lado);
  - `alpha_cut = DISABLED` (mezcla suave), `shaded = false`, `double_sided = false`;
  - la posición se desplaza **4 mm (`LABEL_LIFT = 0.004`) hacia el lado al que mira el texto** (`+z` si `cos(rot_y) >= 0`, si no `−z`) para que nunca haya z-fighting con su superficie;
  - el contorno escala con el tamaño de fuente (`outline * font_size / 48`);
  - **ningún texto se fija a ojo**: siempre `label_fit` con el hueco real disponible. Un texto que no se pueda leer a 2 m se agranda o se quita.

### 3.2 `Interactable`

`class_name Interactable extends StaticBody3D`: `prompt_text`, `enabled`, `get_prompt()`, `can_interact()`, `interact()`, `set_highlighted(on)`. Al apuntar, todos sus mallas registradas (`add_mesh_box`, `add_mesh_cylinder`, `track_mesh`) reciben un `material_overlay` sin sombreado amarillo (`Color(1, 0.85, 0.2, 0.3)`). `add_shape(size, pos)` añade una colisión de caja. **Los colliders de apuntado deben ser generosos y no solaparse con los de objetos vecinos** (el grifo frío llegó a "robar" el apuntado al tapón).

### 3.3 `Room.mount(wall, along, y)`

Devuelve un `Node3D` pegado a una pared con **+Z local hacia dentro de la sala y +X local a la derecha del espectador**. `along` es la x del mundo (paredes norte/sur) o la z del mundo (este/oeste):
- `north`: posición `(along, y, -1.5)`, sin rotar.
- `south`: `(along, y, 1.5)`, `rotation.y = PI`.
- `west`: `(-2, y, along)`, `rotation.y = PI/2`.
- `east`: `(2, y, along)`, `rotation.y = -PI/2`.
Todos los objetos de pared se construyen en ese espacio local.

### 3.4 Reglas de código aprendidas

- **No uses `await` con temporizadores en nodos que pueden liberarse** (reiniciar la partida a mitad da errores). Usa `create_tween()` con `tween_interval` + `tween_callback`, que mueren con el nodo.
- El ratón se lee con `InputEventMouseMotion.screen_relative` (no `relative`, que viene escalado por el stretch).
- Las conexiones de señales del autoload a nodos que se liberan se limpian solas; no conectes lambdas que capturen nodos al autoload.

## 4. Flujo, estados y jugador

- `main.gd`: si `GameState.skip_menu` o hay un flag de depuración → empieza partida; si no → `MainMenu`. Reiniciar = `GameState.skip_menu = true` + `get_tree().reload_current_scene.call_deferred()`. Volver al menú = lo mismo con `skip_menu = false`.
- `Game` (`process_mode ALWAYS`; sala, jugador, HUD y overlays en `PAUSABLE`, menú de pausa y victoria en `ALWAYS`). Estados: `PLAYING, PHONE, KEYPAD, PIPES, TABLE, PAUSED, WON`. En `PLAYING` el ratón está capturado; en cualquier otro, visible y `GameState.controls_locked = true`. **Esc** cierra el overlay abierto, o pausa/reanuda. **H** abre/cierra el móvil. Clic con el ratón liberado en `PLAYING` lo vuelve a capturar. Teclas de depuración (solo en `PLAYING`): F1 luz, F2 luz+ritual, F3 espejo, F4 teclado, F5 tuberías, F6 posavasos.
- Intro: a los 0,8 s el narrador dice `start`; a los 9,8 s, si no hay luz, `start_hint`.
- **Jugador** (`CharacterBody3D`): cápsula r 0,28 m, alto 1,7 m; cámara a 1,6 m, FOV 75, **near 0,05, far 30** (con far grande hay z-fighting en los textos); velocidad 2,2 m/s; sensibilidad 0,0025 rad/px; pitch limitado a ±1,45 rad; gravedad 9,8. `RayCast3D` hijo de la cámara de **2,0 m**. Empieza en `(0, 0.05, 0.7)` mirando al norte (la puerta). Interactuar = acción `interact` con el ratón capturado.

## 5. La sala

### 5.1 Carcasa y materiales

- Interior: x ∈ [−2, 2], z ∈ [−1,5, 1,5], suelo y = 0, techo y = 2,6. Paredes de 0,2 m de grosor (cajas estáticas). Pared norte con hueco de puerta en x ∈ [−0,05, 0,85], y ∈ [0, 2,05].
- Paredes partidas en altura: **azulejo** blanco roto (`tile_material(Color(0.86,0.85,0.78), same, grout Color(0.45,0.45,0.4), 4 baldosas/m)`) hasta y = 1,4 (`TILE_LINE`) y **pintura verde hospital** (`Color(0.42,0.58,0.48)`, sin juntas, 2/m) por encima. Moldura oscura `Color(0.25,0.32,0.28)` de 4 cm en y = 1,4, que sobresale 2 cm: **ningún cartel debe cruzar y = 1,4** (corta el texto).
- Suelo: damero rojo óxido `Color(0.5,0.22,0.15)` / gris `Color(0.32,0.3,0.27)`, 3/m. Techo gris `Color(0.6,0.6,0.55)`, 2/m.
- `WorldEnvironment`: fondo negro, ambiente `Color(0.4,0.5,0.45)` energía 0,35 (0,6 con la luz), niebla densidad 0,04 color `Color(0.1,0.13,0.12)`.

### 5.2 Luces

- Emergencia verde (luz inicial): Omni en `(0.4, 2.3, -1.2)`, `Color(0.4,1,0.5)`, energía 0,9, rango 4,5. Cartel "SALIDA" verde emisivo de 0,44 × 0,15 encima de la puerta (y 2,33).
- Relleno tenue: Omni `(0, 2.2, 0.6)`, azulada, 0,25, rango 5.
- Fluorescente principal: Omni `(0, 2.4, -0.1)` blanca, energía 0 → 1,5 al resolver el cuadro, con parpadeo (1,4 / 0,1 / 1,2 / 0,2 / 1,5 en ~0,45 s) y tubo emisivo en el techo.
- **Luz negra**: Omni `(0, 2.35, 0.7)`, `Color(0.55,0.25,1)`, 0 → 0,8; tubo violeta emisivo. Zumbido de fluorescente en bucle (−18 dB) desde que hay luz.

### 5.3 El pasillo del bar (se ve al abrir la puerta)

Detrás de la pared norte, z de −1,7 a −4,1, x de −0,5 a 1,3: suelo y paredes marrones, texto "BAR" naranja en el fondo, un taburete con **tu cerveza** (cilindro amarillo emisivo con espuma blanca) y una luz cálida (`Color(1,0.7,0.4)`, energía 2) que **solo se enciende al abrirse la puerta** (si no, atraviesa la pared).

### 5.4 Posición de cada objeto

| Objeto | Dónde | Detalles |
|---|---|---|
| Puerta | bisagra en `(-0.05, 0, -1.53)` | hoja de madera 0,9 × 2,04 × 0,05 desde la bisagra hacia +x; marco 0,08; manilla dorada; cartel de 0,52 × 0,17 a y 1,55 con "OCUPADO" (rojo) delante y "TIRAR" (azul) detrás |
| Teclado | `mount(north, -0.45, 1.35)` | caja 0,2 × 0,3, pantallita roja (verde al resolver), 12 teclas, "CÓDIGO" encima (hueco 0,34 × 0,07) |
| Tablón "MESA 7" | `mount(north, -1.3, 1.05)` | corcho 0,74 × 0,5 (por debajo de la moldura) |
| Cuadro eléctrico | `mount(east, -0.75, 1.45)` | panel 0,8 × 0,62; título "CUADRO ELÉCTRICO / NO TOCAR" amarillo encima |
| Tubería de vapor | eje en `(1.86, 0, -1.36)` (esquina NE) | ver puzle 3 |
| Caldera | `mount(east, 0.3, 1.25)` | armario 0,44 × 0,54 |
| Váter | `mount(east, 0.75, 0)` | taza (cilindro r 0,17), asiento y tapa levantada; cisterna alta 0,5 × 0,28 a y 2,15; tubería gris; cadena en local `(0.17, 0, 0.2)` con tirador a y 1,3 |
| Rollo vacío | `mount(east, 0.12, 0.8)` | portarrollos + cartón |
| Lavabo | `mount(west, -0.2, 0)` | pila 0,62 × 0,48 a y 0,85, pie; grifo caliente (pomo rojo) en local `(-0.17, 1.0, 0.07)`, frío (azul) en `(0.17, 1.0, 0.07)` |
| Espejo | lavabo, local `(0, 1.62, 0)` | marco 0,62 × 0,72; capa de vaho |
| Tapón | lavabo, reposo `(0.12, 0.94, 0.37)`, puesto `(0, 0.93, 0.27)` | goma naranja r 0,06, collider 0,2 × 0,14 × 0,2, en el centro de la pila |
| Cartel NO INUNDAR | `mount(west, -0.82, 1.78)` | ver final 2 |
| Secador | `mount(south, -0.9, 1.3)` | caja blanca 0,34 × 0,28 × 0,2, boquilla, botón "PULSE" |
| Dispensador | `mount(south, 0.9, 1.35)` | metálico 0,36 × 0,42, tapa con bisagra abajo y "PAPEL" |
| Cartel empleados | `mount(south, 0, 1.95)` | placa 0,9 × 0,44; "LOS EMPLEADOS / DEBEN LAVARSE / LAS MANOS" azul oscuro (hueco 0,8 × 0,36) |
| Fregona | `(-1.65, 0, 1.15)` | cubo amarillo r 0,17, palo azul inclinado, cabezal |
| Posavasos | `mount(south,-0.45,1.0)`, `(east,1.2,1.0)`, `(west,-1.2,1.0)`, `(west,0.5,1.2)` | índices 0..3 en ese orden |

## 6. Pruebas

### 6.1 Cuadro eléctrico (lógica, da la luz)

- 4 interruptores en fila; cada uno invierte su piloto y el de sus vecinos (Lights Out). Estado inicial **apagado, encendido, apagado, encendido**; solución mínima: interruptores **2, 3 y 4** (3 pulsaciones). Pilotos rojos/verdes emisivos; palanca naranja que sube/baja.
- `LightsOut` es lógica pura con `initial_state`, `press`, `is_solved` y `min_presses` (fuerza bruta). `tests/test_lights_out.gd` comprueba que el inicio necesita ≥ 3 pulsaciones y que **los 16 estados tienen solución**.
- Al resolverse: `GameState.solve_lights()` → luz general + luz negra + pintadas ocultas. Tocarlo después: `breaker_locked`.

### 6.2 El ritual (cadena de pistas, 5 pasos) → cifra "1" (3.ª)

- Secuencia: **secador → fregona → cadena → grifo frío → secador** (`RITUAL_SEQUENCE`). Solo cuenta con la luz negra encendida.
- **No se ve la lista completa.** Con la luz negra aparece en la pared norte (escrito en el vaho) "EL RITUAL DEL / PARROQUIANO / 1. EL VIENTO / QUE SECA". Cada acierto revela, junto al objeto recién usado, la frase del siguiente paso (fundido de 0,8 s) y el narrador la lee (`ritual_clue_N`):
  - tras el secador: pared sur encima del secador, "2. LA VETERANA / DE 2009";
  - tras la fregona: pared oeste junto a la fregona, "3. EL RÍO / QUE ARRASTRA";
  - tras la cadena: pared este junto al váter, "4. LO FRÍO / QUE MOJA";
  - tras el grifo frío: pared oeste encima del espejo, "5. OTRA VEZ / EL VIENTO".
  Las frases reveladas se quedan aunque se falle.
- Reglas: solo secador, fregona, cadena y grifo frío (al **abrirlo**) cuentan. Un elemento equivocado reinicia (sonido de error + `ritual_fail`); si el equivocado es el secador, cuenta como paso 1. Fuera de secuencia, cada objeto dice su texto normal (`dryer_idle`, `flush_idle`, `cold_tap_on`). Acierto: sonido "tick".
- **La fregona tiene un único texto**: "Lleva aquí desde 2009. Es la que manda." (la pista "la veterana de 2009" remite a esa frase, y hay una pintada de mugre "ESTO NO SE LIMPIA DESDE 2009"). Al tocarla dice siempre esa frase y luego alimenta el ritual.
- El secador y la cadena se bloquean mientras suenan (2,4 s y 2,2 s). El secador vibra; la cadena baja 10 cm y sube.
- Al completar: el dispensador abre la tapa (105°, rebote) con "clunk" y muestra una nota con **"_ _ 1 _"**.

### 6.3 El espejo y el vapor (mecanismo) → cifra "3" (1.ª)

El espejo solo se empaña si se cumplen **a la vez**:
1. **Vapor abierto.** Tubería roja (`Color(0.78,0.08,0.06)` algo emisiva) de suelo a techo, r 0,08, en la esquina NE (a la derecha de la puerta, visible desde el inicio). Tiene bridas grises, dos bandas amarillas, un **manómetro** a y 1,55 (aguja de "7 en punto" a "2 en punto" con tween elástico) y una **boquilla con chorros de vapor** (4 esferas blancas translúcidas en bucle). Un tramo horizontal (r 0,05) va pegado a la pared norte hacia −x 0,76 m a y 1,0 y entra en la pared con un codo. En su centro, la **palanca amarilla** (`Valve`): cruzada a la tubería = cerrado, a lo largo = abierto (tween 0,35 s). Cartel colgante "VAPOR / AGUA CALIENTE". Al abrir: "clunk" + "rattle", siseo en bucle ("steam", −14 dB) y `valve_open`.
2. **Grifo caliente abierto** desde hace **2,5 s** (`WARMUP`): primero sale fría. Si el vapor está cerrado, el narrador dice `hot_tap_cold` (dónde está la llave) y **la palanca parpadea 3 veces** (`GameState.valve_hint`).
3. **Grifo frío cerrado**: con los dos abiertos sale tibia y no empaña (`tap_mixed`). Es una trampa natural, porque el ritual deja el grifo frío abierto.
- Al calentarse avisa con `hot_water_arrives` (o `tap_mixed`). El vaho sube a 0,2/s y baja a 0,07/s; el texto "3 _ _ _" aparece entre vaho 0,35 y 0,95. Con vaho ≥ 0,95 → `solve_mirror()`. Se puede resolver en cualquier momento.

### 6.4 Tuberías de la caldera (puzle) → cifra "3" (2.ª)

- Armario "CALDERA" en la pared este con pantalla ("- - - -", verde con "_ 3 _ _" al resolver), piloto rojo/verde y un esquema de tuberías rotas. Interactuar abre `PipesUi` (la primera vez dice `boiler_look`).
- `PipeGrid` (lógica pura): rejilla de **5 columnas × 4 filas**; piezas `STRAIGHT = N|S`, `CORNER = N|E`, `TEE = N|E|W`, `EMPTY`; cada giro es un cuarto de vuelta en sentido horario (`rotate_mask`). El vapor entra por el **oeste de la fila 1** y debe salir por el **este de la fila 2** (filas desde 0). Búsqueda en anchura por aberturas compatibles.

```
KINDS (fila a fila):
CORNER, STRAIGHT, TEE,      CORNER, STRAIGHT
STRAIGHT, CORNER, STRAIGHT, TEE,    CORNER
CORNER, CORNER,   STRAIGHT, TEE,    STRAIGHT
TEE,    STRAIGHT, CORNER,   EMPTY,  CORNER
START_ROTATIONS:
2,1,3,0,1 / 0,0,1,2,3 / 1,0,0,1,0 / 3,0,2,0,1
Ruta de solución (índice: giro): 5:1, 6:2, 11:0, 12:1, 13:0, 14:1
```

- `tests/test_pipes.gd`: el inicio no está resuelto, la solución conocida sí, y hacen falta ≥ 6 giros (son 8).
- UI: título "CUADRO DE LA CALDERA", subtítulo, rejilla de piezas de 56 px en `(180, 92)`, "VAPOR >" a la izquierda de la fila de entrada, "> CALDERA" a la derecha de la de salida (se pone verde al resolver), contador "El vapor llega a N piezas." Las piezas se dibujan con `_draw` (líneas de 12 px desde el centro hacia cada abertura): gris si están secas, **azul `(0.35,0.85,1)` si les llega el vapor**. Clic izquierdo gira, clic derecho gira al revés. Al resolver: "Presión estable. La caldera se enciende.", "success", `solve_pipes()` y se cierra a los 1,8 s. La rotación persiste aunque se cierre.

### 6.5 Los posavasos (acertijo de deducción) → cifra "2" (4.ª)

- "Mientras estabas en el baño, alguien se bebió tu caña." Cuatro posavasos pegados con chicle (disco r 0,1 crema con centro de color distinto y un chicle rosa; sin texto). Al leerlos: `read_coaster(i)` y el narrador dice "Posavasos: «…»" con:
  1. "PACO se sienta en un extremo de la barra."
  2. "MARTA está justo a la izquierda de LUCÍA."
  3. "JAVI no está al lado de PACO."
  4. "LUCÍA está más a la derecha que JAVI."
- **Solución única** (asientos 1→4): **Javi, Marta, Lucía, Paco**. El culpable es el del **asiento 2: Marta** → cifra "2". `tests/test_seating.gd` comprueba por fuerza bruta que solo hay una solución.
- Tablón de corcho "MESA 7 / ¿QUIÉN SE SENTABA / DÓNDE?" y un papel con el resultado ("SE LA BEBIÓ MARTA / _ _ _ 2" al resolver).
- `TableUi`: título "MESA 7 · ¿QUIÉN SE SENTABA DÓNDE?"; a la izquierda "Lo que dicen los posavasos:" con las frases leídas y "??? (posavasos sin leer)" para el resto; a la derecha "La barra (de izquierda a derecha):", cuatro botones de asiento que ciclan "-", Paco, Lucía, Javi, Marta (cada nombre con su color), y "Comprobar". Si falta alguien: "Faltan amigos por sentar."; si faltan posavasos: aviso + `board_missing`; si no cuadra: error, `board_wrong`, "No cuadra: se cumplen N de 4 pistas (en verde)." y las frases en verde/rojo; si cuadra: "Cuadra. Tu caña estaba delante del asiento 2: se la bebió Marta.", `solve_coasters()` y se cierra a los 2,2 s.

### 6.6 Acertijos del cuñado (extra, sin cifra)

En el móvil, botón "Acertijo (Javi)". Tres acertijos seguidos (`Riddles.LIST`); **acertar baja la cerveza 1 °C, fallar la sube 1 °C** (`GameState.answer_riddle`), con texto del narrador. Al acabar: "Javi se ha quedado sin acertijos. Por hoy. Te ha dejado la cuenta."

```
1. "A ver, listo: «Oro parece, plata no es». ¿Qué es?"  [El plátano ✔ | Una moneda de dos euros | El oro mate]
2. "Esta te la sabes: «Blanca por dentro, verde por fuera. Si quieres que te lo diga, espera»."  [El aguacate | La pera ✔ | La lechuga]
3. "Última, que me voy a por otra caña: «Cuanto más grande es, menos se ve»."  [La cuenta | El baño | La oscuridad ✔]
```

### 6.7 El código y el teclado

| Prueba | Cifra | Posición | Dónde se lee |
|---|---|---|---|
| Espejo | 3 | 1.ª | "3 _ _ _" en el vaho |
| Tuberías | 3 | 2.ª | "_ 3 _ _" en la pantalla de la caldera |
| Ritual | 1 | 3.ª | "_ _ 1 _" en la nota del dispensador |
| Posavasos | 2 | 4.ª | "_ _ _ 2" en el tablón |

- `GameState.DIGIT_TRIALS = {"mirror": 0, "pipes": 1, "ritual": 2, "coasters": 3}`; `reveal_digit(trial)`, `code_so_far()` ("3  _  _  2") y `digit_pattern(pos)` (se usan dos espacios entre caracteres). El móvil muestra siempre "CÓDIGO   3  _  _  2".
- `KeypadUi`: panel `(215,22)` 210 × 316, "SEGURIDAD BAÑO S.L.", pantalla verde con "_ _ _ _", rejilla 3 × 4 (1-9, C, 0, OK) de 54 × 44; teclado físico (dígitos, numpad, Retroceso, Enter). **Se comprueba solo al teclear la 4.ª cifra.** Correcto → "ABIERTO", "success", `solve_keypad()`, se cierra a los 1,2 s. Incorrecto → "ERROR" en rojo, "error", `keypad_wrong`, se limpia a los 0,8 s.

### 6.8 Final 1 — "Tirar, que no empujar"

Con el código correcto el teclado se pone verde… y la puerta sigue igual (`keypad_correct`: el teclado nunca estuvo conectado a nada). A los 2,5 s el cartel de la puerta **gira 180°** y pasa de "OCUPADO" a "TIRAR" (`sign_flip`). Antes de eso, interactuar con la puerta = "Empujar la puerta" (`door_locked`, traqueteo); después, "Tirar de la puerta": se desactiva su colisión, se enciende la luz del pasillo, la puerta gira −105° hacia dentro en 1,3 s, suena la fanfarria y `GameState.win("door")`.

### 6.9 Final 2 (secreto) — "Que lo limpie el bar"

- **Tapón puesto + grifo caliente abierto + grifo frío abierto** durante `TIME_TO_FLOOD = 14 s` (no hace falta haber resuelto nada). El progreso baja a 0,6× si se deja de cumplir (el agua se va; no hay estado sin solución).
- Visual (`Flood`): agua translúcida azul en la pila (primer 15 %), y luego una caja de agua que sube por toda la sala hasta 1,0 m (desde el 20 %). Narrador a 15 % (`overflow_start` + traqueteo) y 60 % (`flood_rising`). Al 100 %: `flood_burst`, la puerta revienta (`Door.burst_open`: −110° en 0,45 s con rebote, luz del pasillo) y a los 1,6 s fanfarria y `win("flood")`.
- La pista es discreta: un **cartel amarillo de aviso** junto al espejo (placa 0,39 × 0,59 `Color(0.95,0.8,0.12)` con marco negro, pictograma negro de **una fregona dentro de un cubo** hecho con primitivas, y el texto "NO INUNDAR. / NO ERES TÚ QUIEN / LIMPIA EL ESTROPICIO"). Es interactuable (`flood_sign`). Además, la 4.ª pista del móvil en la fase de la puerta lo insinúa.

### 6.10 Finales descubiertos

Se guardan en `user://endings.cfg` (`ConfigFile`, sección `endings`). Menú y pantalla final muestran "Finales descubiertos: X/2". **Los modos de depuración ponen `GameState.persist_endings = false`** para no tocar la partida guardada real.

## 7. La cerveza

`temperatura = max(2, 4 + segundos/40 + pistas + ajuste)`, donde `ajuste` es −1 por acertijo acertado y +1 por fallado. Se pausa con la pausa. Termómetro arriba a la derecha. Veredictos por rango (<8, 8-14, 14-20, >20), distintos según el final (ver textos).

## 8. Pintadas (estilos y lista)

Nada de colores fluorescentes de relleno: todo debe parecer escrito en un baño. Estilos (`Room.Ink`):
- **Rotulador** (siempre visible): negro `(0.06,0.06,0.08,0.9)`, rojo `(0.5,0.06,0.06,0.9)`, azul `(0.1,0.18,0.45,0.9)`, sin contorno.
- **Mugre** (solo con luz negra): marrón `(0.36,0.26,0.1,0.92)` con contorno `(0.2,0.13,0.04,0.45)` de 3.
- **Vaho** (escritura con el dedo, para el ritual): blanco azulado translúcido `(0.92,0.97,1,0.72)` con contorno `(0.7,0.86,1,0.28)` de 4.
- Cada pintada se inclina ±2,5° con una semilla `text.hash()` (siempre igual) para parecer escrita a mano; se separan 1,2 cm de la pared.

| Pared, along, y | Texto | Hueco | Estilo |
|---|---|---|---|
| north, 1.35, 1.75 | AQUÍ SE VIENE / A LLORAR | 0,7 × 0,26 | rotulador negro |
| south, −0.9, 1.85 | SI LEES ESTO, / ESTÁS EN UN BAÑO | 0,85 × 0,3 | rotulador rojo |
| east, 0.3, 1.97 | PACO / TE QUIERO / (NO) | 0,55 × 0,4 | rotulador rojo |
| east, −0.75, 2.3 | ESTO NO SE LIMPIA / DESDE 2009 | 0,75 × 0,2 | mugre, oculta |
| north, −1.28, 1.86 | EL RITUAL DEL / PARROQUIANO / 1. EL VIENTO / QUE SECA | 1,0 × 0,7 | vaho, oculta |
| south, −0.9, 2.2 | 2. LA VETERANA / DE 2009 | 0,9 × 0,34 | vaho, pista del ritual |
| west, 1.0, 1.75 | 3. EL RÍO / QUE ARRASTRA | 0,9 × 0,34 | vaho, pista |
| east, 1.05, 1.75 | 4. LO FRÍO / QUE MOJA | 0,8 × 0,34 | vaho, pista |
| west, −0.2, 2.25 | 5. OTRA VEZ / EL VIENTO | 0,9 × 0,34 | vaho, pista |

No añadas más pintadas: el jugador pidió paredes menos recargadas, y las pistas demasiado explícitas ("sin vapor no hay agua caliente", "tapa el lavabo y abre todo") se quitaron a propósito.

## 9. Interfaz 2D (en 640 × 360)

- **HUD:** cruceta blanca de 2 × 2 en el centro; texto de interacción "[E] …" centrado en y 194 (color `(1,0.92,0.6)`, tamaño 13, contorno 4); "[H] Móvil   [Esc] Pausa" arriba a la izquierda; arriba a la derecha "TU CERVEZA", un termómetro vertical de 70 px (de azul claro a rojo, de 4 a 24 °C) y la temperatura "4.0 °C".
- **Narrador:** caja negra (α 0,65) en `(40, 292)` de 560 × 60, texto de 13 px con salto de línea, **máquina de escribir a 45 caracteres/s** (`VC_CHARS_AFTER_SHAPING`), blip "type" cada 3 letras (−16 dB), cola de 3 mensajes como máximo (sin duplicados), cada mensaje dura `2 + 0,035 × longitud` s (más rápido si hay cola).
- **Móvil:** cuerpo negro en `(372, 14)` de 210 × 334; pantalla verde clara 194 × 284; cabecera "LOS DEL BAR (4)"; franja "CÓDIGO   _ _ _ _"; chat con burbujas de RichText (nombre en color: Paco `#b03030`, Lucía `#2a6fb0`, Javi `#2f8a3a`, Marta `#9a4fb0`, Tú `#555555`); abajo "Pista (+1 °C)" y "Acertijo (Javi)" / "Volver al chat"; pie "[H] o [Esc] para guardarlo". Mensajes iniciales: Javi "¿Dónde te has metido? Te hemos pedido otra caña.", Lucía "Si te has vuelto a quedar encerrado, pide pista. Te ayudamos. A nuestra manera.", Paco "Si tardas mucho me la bebo yo, aviso.", Javi "Y si te aburres, dale a «Acertijo». Tengo uno buenísimo." Pedir pista añade "Tú: Ayuda. Sigo en el baño." + la pista + sonido "phone" + `hint_used`.
- **Pistas:** la fase actual es la primera no resuelta de: breaker → ritual → mirror → pipes → coasters → keypad → door. Cada fase tiene 3 niveles (la puerta, 4) y pasado el último se repite el último.
- **Pausa:** fondo oscuro, "PAUSA", "La cerveza también se ha pausado. Por respeto.", botones Continuar / Reiniciar / Salir al menú.
- **Menú:** fondo verde oscuro, rayas sutiles, recuadro rojo con "OCUPADO" (44 px), "Un escape room en el baño de un bar. / Tu cerveza se calienta. Tú verás.", botones Jugar y Salir, controles, "Finales descubiertos: X/2" y "Game jam · Godot <versión>".
- **Victoria:** fundido marrón; título del final (40 px), nombre del final, subtítulo, tiempo (m:ss), temperatura, pistas pedidas, veredicto entre comillas, finales descubiertos, botones "Volver a jugar" y "Menú principal".

## 10. Textos literales (copiar tal cual en `scripts/data/lines.gd`)

`Lines.pick(event)` elige una variante al azar sin repetir la anterior. `GameState.say(event)` / `say_text(texto)` los envían al narrador.

```gdscript
const NARRATOR := {
	"start": ["La puerta no abre. Tranquilo, solo es tu cerveza la que sufre.", "Encerrado en el baño de un bar. Tu madre estaría orgullosa.", "La puerta no cede. Fuera, una caña recién tirada empieza a perder la fe en ti."],
	"start_hint": ["Hay un cuadro eléctrico en la pared. En un baño. Con su 'NO TOCAR' y todo.", "Esta penumbra tiene pinta de cuadro eléctrico. Lo pone en la pared, literalmente."],
	"door_locked": ["Empujas. La puerta, muy digna, no hace nada.", "Está cerrada. Igual que tu futuro como cerrajero.", "Nada. La puerta tiene más carácter que tú.", "Le das un empujón. La puerta ni se inmuta. Es de roble. O de orgullo."],
	"door_open": ["Tiras. Se abre. Probablemente llevaba abierta toda la noche.", "La puerta se abre hacia dentro. Como debe ser. Nadie lea esto como una metáfora."],
	"keypad_wrong": ["No. Pero qué seguridad tecleando.", "Incorrecto. El teclado te juzga en silencio.", "Pitido de error. Universalmente reconocido como 'no, campeón'.", "Ese código no. Ni ese, ni el de tu tarjeta, ni el de tu madre."],
	"keypad_correct": ["Luz verde. Clic. ...Y la puerta sigue igual. El teclado nunca estuvo conectado a nada. Lo puso el dueño para dar empaque.", "Código correcto. El teclado se pone verde con mucho orgullo. Lástima que no esté conectado a ningún sitio."],
	"sign_flip": ["Ah, mira. El cartel de la puerta se ha dado la vuelta. Pone TIRAR. Siempre puso TIRAR.", "El cartel de OCUPADO gira y revela su otra cara: TIRAR. Toda la noche empujando."],
	"keypad_done": ["El teclado sigue en verde. Decorativo y feliz.", "No le des más al teclado. Ya ha hecho su papel: ninguno."],
	"breaker_locked": ["Ya hay luz. No lo toques, que esto lo montó el cuñado del dueño.", "Las cuatro verdes. Déjalo así antes de que salte todo el bar."],
	"breaker_solved": ["¡Luz! Y una luz negra. En un baño. Mejor no preguntar por qué.", "Se hace la luz. También una luz negra, que revela cosas que nadie debería ver en un baño."],
	"flush_idle": ["Muy bien. Has resuelto exactamente nada.", "La cisterna ruge. Tu dignidad, también.", "Has tirado de la cadena. El váter estaba vacío. Como tu plan."],
	"dryer_idle": ["El secador escupe aire tibio y cierta sensación de fracaso.", "Brrrrr. Tienes las manos secas. Encerrado sigues igual.", "El secador funciona. Es lo único en este baño que hace su trabajo."],
	"cold_tap_on": ["Agua fría. Refrescante. Inútil.", "Abres el grifo frío. El agua sale con desgana, como un lunes."],
	"hot_tap_on": ["Agua caliente. Tarda, pero llega. Como el camarero.", "El grifo caliente echa vapor. Este baño es más sauna que bar."],
	"ritual_fail": ["Mal. El ritual se reinicia. Los parroquianos de verdad no se equivocan.", "Eso no tocaba. Vuelta a empezar, aprendiz.", "Error de protocolo. El espíritu del bar está decepcionado."],
	"ritual_clue_1": ["Bien. En la pared de encima aparece escrito en el vaho: «2. LA VETERANA DE 2009»."],
	"ritual_clue_2": ["Sigue el hilo. Junto a la fregona se empaña un nuevo recado: «3. EL RÍO QUE ARRASTRA»."],
	"ritual_clue_3": ["Cada acierto deja un recado. Junto al váter alguien escribe con el dedo: «4. LO FRÍO QUE MOJA»."],
	"ritual_clue_4": ["Casi. Encima del espejo, en el vaho, lo último: «5. OTRA VEZ EL VIENTO»."],
	"ritual_solved": ["¡Clonc! El dispensador de papel se ha abierto. El ritual funciona. Nadie sabe por qué.", "El dispensador de papel se abre de golpe. Tanto ritual para un trozo de papel."],
	"dispenser_closed": ["Está cerrado. Cerradísimo. Ni papel ni esperanza.", "Dispensador metálico. Con cerradura. Para papel. Claro que sí."],
	"dispenser_note": ["Una nota con una sola cifra: '_ _ 1 _'. Alguien repartió el código por todo el baño.", "La nota dice '_ _ 1 _'. Las otras cifras estarán en otro sitio. Típico."],
	"mirror_look": ["Te miras al espejo. Te devuelve una mirada de 'te lo dije'.", "Un espejo sucio. Tú, al otro lado, también.", "Te ves bien. Para estar encerrado en un baño, digo."],
	"mirror_fogged": ["El espejo está empañado y alguien ha escrito con el dedo: '3 _ _ _'. Una cifra. Qué asco y qué útil."],
	"mirror_reveal": ["El vaho revela una cifra escrita con el dedo: '3 _ _ _'. La higiene, una vez más, al servicio del misterio.", "Con el vaho aparece un número en el espejo: '3 _ _ _'. Alguien se aburría mucho aquí."],
	"mirror_after": ["El espejo, ya sin vaho. Ponía '3 _ _ _'. Por si se te olvida."],
	"hint_used": ["Has pedido ayuda por el grupo. Tu cerveza se calienta de vergüenza.", "Pista pedida. Un grado más. La cerveza lo apunta.", "Tus amigos te ayudan. A su manera. Y tu cerveza lo paga."],
	"mop": ["Lleva aquí desde 2009. Es la que manda."],
	"roll": ["Rollo vacío. El clásico.", "Solo queda el cartón. Aquí alguien ha vivido una tragedia.", "El rollo está vacío. Como la promesa del dueño de 'reponer mañana'."],
	"employees_sign": ["'Los empleados deben lavarse las manos.' El camarero no lo ha leído en su vida.", "Un cartel muy serio en un baño muy poco serio."],
	"toilet": ["Un váter. Mejor no mirar dentro.", "Está... limpio. Sospechosamente limpio.", "El váter no es la salida. Ni lo pienses."],
	"hot_tap_cold": ["Sale fría. Al agua caliente le falta vapor: abre la llave de la tubería roja de la esquina, junto a la puerta.", "Agua helada. La tubería roja de vapor de la esquina tiene una llave: ábrela y espera.", "El grifo caliente escupe agua fría. El vapor está cortado en la llave de la tubería roja, junto a la puerta."],
	"valve_open": ["El vapor entra en las tuberías con un bufido. Algo caliente viene de camino.", "Clonc. La tubería roja ruge y empieza a sisear. Agua caliente en camino, con la calma de un lunes."],
	"valve_close": ["Cortas el vapor. La caldera suspira, aliviada.", "Llave cerrada. El vapor se queda en su cueva."],
	"hot_water_arrives": ["Por fin agua caliente. Este baño empieza a parecer una sauna finlandesa de baja categoría.", "Sale vapor. El espejo está de acuerdo en ponerse misterioso."],
	"tap_mixed": ["Fría y caliente a la vez: tibia. Y la tibia no empaña nada.", "Con los dos grifos abiertos sale agua tibia. Tibia, como tu cerveza... pronto."],
	"plug_in": ["Pones el tapón. Esto no puede acabar mal.", "Tapón puesto. Los fontaneros ya te odian."],
	"plug_out": ["Quitas el tapón. Cobarde.", "Tapón fuera. Los fontaneros respiran."],
	"overflow_start": ["El lavabo está a punto de rebosar. Esto va a salir regular.", "El agua empieza a rebosar. Algo se ha roto: tu sentido común."],
	"flood_rising": ["El agua ya cubre el suelo. A tus amigos ni se les pasa por la cabeza que estés tramando esto.", "Sube el agua. Es un plan. Pésimo, pero un plan."],
	"flood_burst": ["¡La puerta cede! El baño vomita agua y a ti detrás.", "CRAAAC. La puerta no aguanta y el baño entero sale por ella."],
	"boiler_look": ["El cuadro de la caldera tiene una pantalla apagada y un esquema de tuberías cortadas. Alguien lo ha dejado hecho un lío.", "La caldera pide que arregles las tuberías. Qué cara más seria para un baño."],
	"boiler_done": ["La caldera ronronea feliz. En la pantalla pone '_ 3 _ _'.", "Todo conectado. La pantalla sigue mostrando '_ 3 _ _'."],
	"pipes_solved": ["El vapor llega a la caldera, que se enciende con un zumbido. En la pantalla: '_ 3 _ _'. Otra cifra.", "Tuberías conectadas. La caldera te enseña una cifra: '_ 3 _ _'."],
	"board_missing": ["Te faltan posavasos por leer. Hay cuatro repartidos por el baño, pegados con chicle.", "Con las pistas a medias, la mesa no se arregla. Busca los posavasos que faltan."],
	"board_wrong": ["Eso no cuadra con lo que dicen los posavasos. Alguien se ha sentado donde no debe.", "Mal sentados. Algún posavasos se queja.", "Esa mesa no es. Vuelve a leer los posavasos."],
	"coasters_solved": ["¡Cuadra! Tu caña estaba delante del asiento 2: se la bebió Marta. Siempre Marta. Cifra nueva: '_ _ _ 2'.", "Resuelto. Marta, asiento 2, culpable de tu cerveza. Cifra nueva: '_ _ _ 2'."],
	"board_done": ["La mesa ya está bien sentada. El culpable, Marta, asiento 2: '_ _ _ 2'."],
	"riddle_right": ["Javi: «¡Toma! Lo sabía.» Y tu cerveza baja un grado.", "Javi te manda un pulgar arriba. Tu cerveza baja un grado."],
	"riddle_wrong": ["Javi: «No, hombre, no.» Tu cerveza sube un grado de la vergüenza.", "Respuesta equivocada. Javi suspira y tu cerveza sube un grado."],
	"riddle_done": ["Javi se ha quedado sin acertijos. Por hoy."],
	"flood_sign": ["Un cartel de aviso: no inundar. Y no eres tú quien limpia. Quien lo puso sabía perfectamente lo que hacía.", "NO INUNDAR, dice, con una fregona en un cubo. Qué cosa más rara de avisar en un baño donde no pasa nada."],
}

const ENDINGS := {
	"door": {"title": "¡LIBRE!", "subtitle": "Has escapado del baño. Tu cerveza te esperaba.", "name": "Final 1: Tirar, que no empujar"},
	"flood": {"title": "¡DILUVIO!", "subtitle": "Has escapado a lo bruto. El bar es ahora una piscina y tú, el culpable.", "name": "Final 2: Que lo limpie el bar"},
}

const VERDICTS := {  # <8, 8-14, 14-20, >20 °C
	"door": ["Perfecta. Tus amigos ni se han dado cuenta.", "Bebible. Con dignidad justa.", "Caldo. Te la bebes por orgullo.", "Se la ha bebido Paco. Hace rato."],
	"flood": ["Perfecta. Flotaba, pero perfecta.", "Bebible. Mojada, pero bebible.", "Caldo con espuma de lejía.", "Se la ha bebido Paco. A nado."],
}

const HINTS := {  # [amigo, mensaje]: vaga, clara, solución
	"breaker": [["Javi", "¿Sigues ahí? Si está todo oscuro, digo yo que habrá un interruptor, lumbreras."], ["Lucía", "El cuadro eléctrico. Cada palanca cambia su luz y las de los lados. Queremos las cuatro verdes, no un belén."], ["Paco", "Dale a la 2, a la 3 y a la 4. De nada. Por cierto, me estoy comiendo tu tapa."]],
	"ritual": [["Marta", "Ahora que tienes luz negra, lee la pintada del ritual, la de la pared de la puerta. Solo te dice el primer paso. Cada acierto te enseña el siguiente, por la sala."], ["Javi", "El viento que seca es el secador. Tócalo y saldrá una frase nueva en la pared. Síguela: cada objeto correcto te da la pista del siguiente. La veterana de 2009 es la que lleva ahí desde 2009."], ["Lucía", "Secador, fregona, cadena, grifo frío y otra vez secador. Si fallas, desde el principio. Como un parroquiano de verdad."]],
	"mirror": [["Paco", "¿Te has lavado las manos? Con agua caliente. Y que salga caliente, que no es lo mismo."], ["Marta", "Si el grifo caliente sale frío, es que falta vapor. Mira la tubería roja de la esquina, junto a la puerta: tiene una llave. Y con el grifo frío cerrado, que si no sale tibia."], ["Javi", "Gira la palanca de la tubería roja de vapor (esquina de la puerta), cierra el grifo frío, abre el caliente y espera unos segundos mirando al espejo. Sale un '3' en el espejo. Si cierras el grifo, se borra."]],
	"pipes": [["Lucía", "El cuadro de la caldera, en la pared junto al cuadro eléctrico, tiene un esquema de tuberías. Alguien las ha dejado giradas a lo loco."], ["Marta", "Haz clic en cada tubería para girarla. El vapor entra por la izquierda y tiene que salir por la derecha, dos filas más abajo. Las que se iluminan ya están conectadas."], ["Javi", "El camino bueno, de izquierda a derecha: recta tumbada, curva izquierda-abajo, curva arriba-derecha, recta tumbada, T con salida a la izquierda, a la derecha y arriba, y recta tumbada."]],
	"coasters": [["Paco", "Hay posavasos pegados con chicle repartidos por todo el baño. Cada uno dice dónde se sienta alguien. Léelos todos."], ["Lucía", "Con los cuatro leídos, ve al tablón de corcho, el de la pared de la puerta, y coloca a los cuatro amigos en la barra, de izquierda a derecha."], ["Marta", "De izquierda a derecha: Javi, Marta, Lucía y Paco. Y la que estaba en el asiento 2... bueno, ya sabes quién se bebió tu caña."]],
	"keypad": [["Lucía", "Tienes trozos de un código, ¿no? Junta las piezas, que no es un mueble de Ikea."], ["Paco", "Cada prueba te da UNA cifra, y su sitio va marcado con guiones. Las vas apuntando en el móvil, mira arriba. Hasta yo lo veo, y voy por la cuarta."], ["Marta", "3312. Teclea 3312 en el teclado de la puerta. Sin miedo."]],
	"door": [["Javi", "¿El teclado está verde y sigues dentro? Lee el cartel de la puerta, anda."], ["Lucía", "El cartel lo pone clarito: TIRAR. No empujar. Tirar."], ["Paco", "Mira la puerta y dale a la E. Tira. Ya. Tu cerveza está llorando."], ["Marta", "Y si lo tuyo es la salida a lo bruto, el lavabo tiene tapón por algo. Tapón, los dos grifos abiertos y paciencia. Yo no he dicho nada."]],
}
```

Textos de interacción ("[E] …"): "Accionar interruptor N", "Usar el secador de manos", "Tirar de la cadena", "Abrir/Cerrar el grifo caliente/frío", "Mirarte al espejo", "Abrir el vapor" / "Cerrar el vapor", "Revisar la caldera" / "Mirar la caldera", "Leer el posavasos", "Ordenar la mesa 7" / "Mirar la mesa 7", "Abrir el dispensador" / "Leer la nota", "Usar el teclado" / "Mirar el teclado", "Empujar la puerta" / "Tirar de la puerta", "Poner el tapón" / "Quitar el tapón", "Tocar la fregona", "Mirar el váter", "Coger el rollo de papel", "Leer el cartel", "Leer el aviso".

## 11. Sonido procedural (`Sfx`, sin archivos)

Todo se sintetiza al arrancar en `AudioStreamWAV` de 16 bits mono a 22050 Hz, con envolventes de ataque y caída. Hay una reserva de 10 `AudioStreamPlayer` y bucles con identificador (`start_loop(id, sonido, dB)`, `stop_loop`, `stop_all_loops` al salir de la partida).

| Sonido | Síntesis |
|---|---|
| beep | cuadrada 1200 Hz, 0,06 s |
| type | cuadrada 1800 Hz, 12 ms (blip del narrador) |
| error | cuadrada 220 Hz 0,12 s + 150 Hz 0,28 s |
| success | cuadradas 660, 880 y 1320 Hz |
| tick | seno 990 Hz con caída de 0,2 s (acierto del ritual) |
| click | ruido corto + cuadrada 2400 Hz |
| phone | senos 1400 y 1800 Hz |
| clunk | barrido 320→70 Hz + ruido |
| rattle | 3 golpes de ruido + 90 Hz |
| flush | 2,4 s de ruido filtrado con gorgoteo modulado |
| dryer | 2,4 s de ruido + zumbido de 115 Hz |
| tap | 1 s de ruido en bucle (grifos) |
| steam | 1 s de ruido brillante en bucle (siseo del vapor) |
| door | barrido 110→210 Hz + ruido grave |
| hum | 1 s exacto de 100/200/300 Hz en bucle (fluorescente) |
| fanfare | do-mi-sol-do'-sol-do' en cuadrada con bajo triangular |

## 12. Icono y exportación

- `tools/make_icon.gd` (ejecutar con `--headless --script`) dibuja un icono de 64 × 64 px de pixel art: azulejo verde con juntas, una puerta marrón con un cartel blanco donde pone "OCUPADO" en rojo (fuente propia de 3 × 5 px, letras de 1 × 2 px) y una caña de cerveza con espuma abajo a la derecha. Guarda `icon.png` (256 × 256, `nearest`) e `icon.ico` (PNG embebidos de 256, 128, 64, 48, 32 y 16 px; cabecera ICO escrita a mano).
- Preset "Windows Desktop" en `export_presets.cfg`: `application/icon` y `console_wrapper_icon` = `res://icon.ico`, `product_name="Ocupado"`, versión 1.0.0, descripción "Ocupado: escape room en el baño de un bar", `embed_pck=true`, salida `./Ocupado.exe`.
- Para que el icono se incruste en el `.exe`, Godot necesita **rcedit** (ya está en `C:\Users\Eduardo\Documents\EDUARDO\herramientas\rcedit\rcedit-x64.exe`), configurado en Editor → Ajustes del editor → Exportar → Windows → Rcedit. No edites `editor_settings` con el editor abierto: lo sobrescribe al cerrar.

## 13. Pruebas automáticas y cómo verificar (obligatorio)

No se puede ver la pantalla, así que todo se verifica con estas herramientas, todas en Godot:

- `godot --headless --path . --script res://tests/test_lights_out.gd` (y `test_pipes.gd`, `test_seating.gd`) → "RESULT: PASS".
- `godot --headless --path . -- --autotest` → juega la partida entera con los objetos reales a `Engine.time_scale = 4` y debe terminar en **"AUTOTEST RESULT: PASS"**. Comprueba, como mínimo: apuntado real con el rayo al tapón y a la palanca desde posiciones cercanas y lejanas; puerta cerrada al inicio; el ritual no cuenta a oscuras; cuadro con 3 pulsaciones; ritual con un fallo, el grifo caliente neutral, la aparición de cada pista y la fregona con un solo texto; espejo que no se empaña con el vapor cerrado ni con agua tibia y sí después; cada prueba revela **una** cifra y las cuatro dan "3  3  1  2"; tuberías (un clic gira una pieza, la solución resuelve); posavasos (se rechaza sin leerlos todos y con un orden incorrecto); acertijos (−1 y +1 °C); pista del móvil (+1 °C); pausa; teclado con un código erróneo y otro correcto; victoria con pantalla final; y que las pistas nunca devuelven texto vacío.
- `-- --autotest-flood` → sin tapón no inunda; con tapón el agua sube; si se cierra un grifo baja; al final se gana con `ending == "flood"` y la puerta reventada.
- `-- --restart-test` → menú → jugar → reiniciar → menú, sin errores.
- `godot --headless --path . --quit-after 300` (arranque normal con menú) → **ni un error ni un warning** en la salida.
- **Capturas** (ejecución con ventana, no headless): `godot --path . -- --shots=<carpeta> [--closeups] [--lights] [--clues] [--steam] [--solve=1234] [--flood] [--ui] [--trials] [--oblique]` guarda PNG desde posiciones fijas (paredes, primeros planos de cada cartel, vistas laterales de los textos, la inundación y todas las pantallas 2D) y se cierra. **Mira las capturas** (las imágenes se pueden leer) para revisar colocaciones y que ningún texto se salga de su soporte, se corte o se vea roto. Durante las capturas pon `GameState.controls_locked = true` (si no, el ratón real mueve la cámara). `tools/compare_crops.gd` amplía y apila recortes de varias capturas para compararlos.

## 14. Trampas conocidas (no repetirlas)

1. Texto 3D con filtro `nearest` y recorte de alfa → ilegible de lado. Usa lo descrito en §3.1.
2. Texto a menos de ~5 mm de su superficie con un `far` de cámara grande → z-fighting (texto roto y parpadeante).
3. Texto más ancho que su cartel → parece descentrado. Usa siempre `label_fit`.
4. La moldura de y = 1,4 sobresale de la pared y corta cualquier cartel que la cruce.
5. Colliders de apuntado solapados (el grifo frío "robaba" el tapón). Compruébalo con el test de apuntado.
6. Una pista física poco clara (la primera válvula era una rueda en la tubería del váter y nadie la entendía): las pistas mecánicas deben ser grandes, estar a la vista desde el inicio y tener aviso del narrador **y** un parpadeo cuando el jugador falla.
7. Un objeto-pista con varios textos aleatorios (la fregona) puede ocultar la frase que lo hace pista: si un texto es pista, que sea el único.
8. `await` sobre temporizadores en nodos que se liberan → errores al reiniciar. Usa tweens.
9. Los modos de depuración no deben escribir los finales guardados.
10. No hagas `git add -A` con un `.exe` exportado en la carpeta.
11. En bash, los heredocs con textos largos en español pueden fallar: escribe los archivos con la herramienta de escritura.

## 15. Cómo trabajar

Por fases, dejando el juego ejecutable al final de cada una y con **un commit de git por fase** (rama principal; mensajes en español):
1. **Base:** proyecto, `Build`, `Interactable`, sala, luces, jugador, HUD mínimo; capturas para revisar.
2. **Pruebas principales:** cuadro, ritual, espejo + vapor, dispensador, teclado, puerta y final 1, con autotest.
3. **Capa de juego:** narrador, termómetro, móvil con pistas, menú, pausa, victoria, reinicio.
4. **Pruebas nuevas:** caldera + tuberías, posavasos + tablón, acertijos del cuñado, una cifra por prueba.
5. **Final secreto:** tapón, inundación, cartel NO INUNDAR, finales guardados.
6. **Pulido:** sonido, texturas, pintadas por estilos, icono y preset de exportación.

Tras cada fase: `--import`, tests, autotest y capturas, y corrige todo error o warning antes de seguir.

## 16. Hecho significa

- Arranca sin errores ni warnings.
- Se completa de principio a fin jugando normal y con F1-F6; **los dos finales son alcanzables**.
- Ningún puzle puede quedar sin solución (el cuadro siempre es resoluble, el ritual se reinicia, la inundación se vacía).
- Todos los tests y los dos autotests en PASS.
- Ningún texto 3D se sale de su soporte, se corta ni parpadea (revisado en capturas, también de lado).
- Hay menú, narrador, pistas, acertijos, sonido, icono y pantalla final con la temperatura, el veredicto y los finales descubiertos.

## 17. Historial de versiones (contexto)

- **v1:** juego base de la game jam: cuadro eléctrico, ritual de 4 pasos con la lista visible, espejo con solo grifo caliente, código partido en "33" + "12", final "TIRAR".
- **v2:** carteles ajustados a su soporte; ritual de 5 pasos en clave con la fregona; espejo con válvula y agua tibia; final secreto de la inundación; finales guardados.
- **v2.1:** válvula más visible y que parpadea; tapón accesible; test de apuntado.
- **v3:** el ritual pasa a ser una cadena de pistas (cada objeto da la siguiente); la fregona tiene un único texto; la válvula pasa a ser una tubería roja de vapor con palanca en la esquina NE.
- **v3.1:** textos 3D legibles de lado (filtro suave, negrita, doble resolución).
- **v4:** tuberías de la caldera, posavasos (deducción) y acertijos del cuñado; una cifra por prueba (4 pruebas con cifra; el cuñado da temperatura).
- **v4.1:** z-fighting de los textos corregido (cámara de 0,05 a 30 m, textos separados 4 mm); carteles pequeños agrandados.
- **v4.2:** pintadas con estilos de rotulador, mugre y vaho; menos mensajes; cartel "NO INUNDAR" con la fregona en el cubo en lugar de la pista explícita.
