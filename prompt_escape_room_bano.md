# Prompt para Claude Code — "Ocupado" (escape room en el baño de un bar)

Vas a crear desde cero un juego completo y jugable en **Godot 4.x con GDScript**. Es para una game jam: tengo entre 1 y 2 horas en total, así que lo importante es que al final haya un juego que se pueda jugar de principio a fin sin errores. Prioriza siempre "funciona y es divertido" sobre "es bonito o completo".

Trabaja de forma autónoma: toma tú las decisiones que no estén especificadas aquí y no me hagas preguntas salvo que algo te bloquee de verdad. Al terminar, dame un resumen corto de qué hay hecho y qué debo probar a mano.

## El juego

**Título:** Ocupado

**Premisa:** Estás en un bar con tus amigos. Vas al baño, y al intentar salir la puerta no abre. Fuera te espera una cerveza recién servida que se va calentando. Tienes que escapar antes de que sea imbebible.

**Tono:** humor absurdo y costumbrista de bar español. El baño tiene un nivel de seguridad ridículamente alto para lo que es (teclado numérico en la puerta, cuadro eléctrico, etc.) y nadie lo cuestiona salvo el narrador.

**Perspectiva:** 3D en primera persona, una única sala pequeña (unos 4 x 3 m, 2,6 m de alto).

**Idioma:** todos los textos del juego en español. Código e identificadores en inglés.

**Duración de una partida:** 5-10 minutos.

## Controles

- WASD: moverse. Ratón: mirar (ratón capturado).
- E o clic izquierdo: interactuar con el objeto al que apuntas.
- H: sacar el móvil para pedir una pista.
- Esc: pausa (libera el ratón; opciones de continuar, reiniciar y salir).

Hay una cruceta pequeña en el centro. Cuando apuntas a algo interactuable a menos de ~2 m, el objeto se resalta y aparece un texto corto tipo "[E] Tirar de la cadena".

## La sala y sus elementos

- **Puerta** con un cartel y un **teclado numérico** de 4 dígitos al lado.
- **Cuadro eléctrico** en la pared con 4 interruptores y 4 pilotos.
- **Lavabo** con dos grifos (caliente y frío) y un **espejo** encima.
- **Secador de manos** en la pared.
- **Váter** con cisterna alta y cadena.
- **Dispensador de papel** metálico, cerrado.
- **Tubería roja de vapor** en la esquina noreste, con palanca, manómetro y cartel "VAPOR / AGUA CALIENTE". *(v3; en la v2 era una rueda en la tubería del váter y no se entendía)*
- **Tapón** naranja y grande del lavabo, en el centro de la pila y lejos de los grifos (sus colliders no deben tapar el tapón al apuntar). *(v2)*
- **Pintadas** en las paredes (usa `Label3D`): algunas visibles desde el principio y son solo chistes, otras ocultas hasta que se enciende la luz negra.
- Un rollo de papel vacío, un cartel de "Empleados deben lavarse las manos": decoración interactuable que solo dispara comentarios del narrador.
- Una **fregona** ("la veterana de 2009"): decoración con comentario del narrador, pero además es uno de los elementos del ritual (puzle 2). *(v2)*
- **Todos los textos `Label3D` deben encajar y estar centrados en su soporte** (cartel, botón, panel, pintada). Se usa el helper `Build.label_fit(parent, texto, pos, rot_y, tamaño_máximo_en_metros, color)`, que calcula el tamaño para que el texto quepa en el hueco; nunca se fija el tamaño a ojo. *(v2)*

Al empezar, la sala solo tiene una luz de emergencia tenue.

## Cadena de puzles

No hay inventario. Cada puzle revela información o activa algo.

**1. Cuadro eléctrico (lógica).** Cuatro interruptores en fila; cada uno invierte su piloto y el de sus vecinos (estilo Lights Out). El objetivo es dejar los cuatro pilotos encendidos. Elige un estado inicial que requiera al menos 3 pulsaciones y comprueba por fuerza bruta en un test que tiene solución. Al resolverlo se enciende la luz general y una **luz negra** que revela pintadas ocultas, entre ellas el poema de "El ritual del parroquiano". *(Sin cambios en la v2: gustó tal cual.)*

**2. El ritual (cadena de pistas, 5 pasos).** *(Rediseñado en la v2 y otra vez en la v3.)* El jugador **no ve la lista completa**: la luz negra solo revela el primer paso (pintada en la pared de la puerta). Cada vez que acierta un objeto, aparece en la pared, **junto al objeto recién usado**, la frase en clave del siguiente, y el narrador avisa de dónde. Así tiene que ir recorriendo la sala:

| Paso | Objeto | Frase en clave | Dónde aparece la frase al acertar el paso anterior |
|---|---|---|---|
| 1 | **secador** | "1. EL VIENTO QUE SECA" | pared de la puerta, siempre visible con la luz negra (título "EL RITUAL DEL PARROQUIANO") |
| 2 | **fregona** | "2. LA VETERANA DE 2009" | pared sur, encima del secador |
| 3 | **cadena** del váter | "3. EL RÍO QUE ARRASTRA" | pared oeste, junto a la fregona |
| 4 | **grifo frío** (cuenta al *abrirlo*) | "4. LO FRÍO QUE MOJA" | pared este, junto al váter |
| 5 | **secador** otra vez | "5. OTRA VEZ EL VIENTO" | pared oeste, encima del espejo |

Reglas: las frases ya reveladas **se quedan** aunque falle la secuencia (así se pueden releer). Solo cuentan secador, fregona, cadena y grifo frío; el grifo caliente, la palanca de vapor, el espejo y el resto de decoración **no** reinician el ritual. Un elemento equivocado reinicia la secuencia (con burla del narrador); si el equivocado es el secador, cuenta como primer paso. La secuencia solo cuenta cuando la luz negra está encendida. Al completarla, el dispensador de papel se abre con un ruido y muestra una nota: "_ _ 1 2".

**La fregona tiene un único texto** del narrador ("Lleva aquí desde 2009. Es la que manda."), siempre el mismo, porque la pista "la veterana de 2009" remite exactamente a esa frase. Si se toca en el paso correcto, tras esa frase el narrador lee la pista del paso siguiente.

**3. El espejo (mecanismo en cadena).** *(Rediseñado en la v2; v3: el vapor está en una esquina.)* Ya no basta con abrir el grifo caliente. El espejo solo se empaña y muestra con el dedo "3 3 _ _" si se cumplen **a la vez** estas condiciones:
1. El **vapor está abierto**. Hay una **gran tubería roja de vapor** que va del suelo al techo en la **esquina noreste** (a la derecha de la puerta, visible desde el principio), con bandas amarillas, un **manómetro** y un tramo horizontal pegado a la pared norte con una **palanca amarilla** (no una rueda) y un cartel "VAPOR / AGUA CALIENTE". Palanca cruzada = cerrado; palanca a lo largo de la tubería = abierto. Al abrirla: la aguja del manómetro sube, suena un siseo y salen chorros de vapor. Si el vapor está cerrado, el grifo caliente sale frío, el narrador dice explícitamente que abras la llave de la tubería roja de la esquina junto a la puerta, y **la palanca parpadea tres veces**. Una pintada oculta lo refuerza: "Sin vapor no hay agua caliente".
2. El grifo caliente lleva abierto unos **2,5 s** (primero sale agua fría de la tubería; el narrador avisa cuando llega el agua caliente).
3. El **grifo frío está cerrado**: con los dos abiertos el agua sale tibia y la tibia no empaña (el narrador lo comenta). Es una trampa natural, porque el ritual deja el grifo frío abierto.
Después hacen falta unos 5 s de vapor. Si se deja de cumplir cualquiera de las condiciones, el vaho desaparece poco a poco (unos 14 s). Este puzle se puede resolver en cualquier momento, también antes de encender la luz.

**4. Teclado de la puerta (código).** Al interactuar se abre una interfaz 2D con teclado numérico (ratón visible, Esc para cerrar). Código correcto: **3312**. Un código incorrecto da un pitido de error y un comentario del narrador.

**Final 1 (chiste): "Tirar, que no empujar".** Al introducir el código correcto, el teclado se pone verde... y la puerta sigue sin abrir. El cartel de la puerta, que hasta ahora estaba girado o medio tapado, dice "TIRAR". El narrador comenta que el teclado nunca estuvo conectado a nada. El jugador interactúa con la puerta, se abre, y aparece la pantalla de victoria.

**Final 2 (secreto): "Que lo limpie el bar".** *(Nuevo en la v2.)* No hace falta resolver ningún puzle. Si el jugador **pone el tapón** en el lavabo y deja **abiertos los dos grifos** (caliente y frío) durante unos 14 s, el lavabo rebosa, el agua sube por la sala (animación visible de agua translúcida hasta ~1 m), la puerta revienta y aparece la pantalla de victoria con otro título ("¡DILUVIO!"), otro subtítulo y otros veredictos de la cerveza. Reglas:
- Si el jugador cierra un grifo o quita el tapón, el agua baja poco a poco (no se pierde nada ni hay estado sin solución).
- Las pistas están ocultas: una pintada de luz negra ("¿Prisa? Tapa el lavabo, abre todo y espera. El bar ya limpiará") y, tras resolver el teclado, una cuarta pista del móvil.
- El juego guarda en `user://endings.cfg` los finales descubiertos y muestra "Finales descubiertos: X/2" en el menú y en la pantalla final.

## La cerveza (puntuación)

En el HUD hay un termómetro pequeño con la temperatura de tu cerveza. Empieza a 4 °C y sube lentamente con el tiempo (aprox. 1 °C cada 40 segundos). Cada pista pedida suma 1 °C extra. No hay derrota: es solo la puntuación. La pantalla final muestra el tiempo, la temperatura y un veredicto según el rango, por ejemplo:

- Menos de 8 °C: "Perfecta. Tus amigos ni se han dado cuenta."
- 8-14 °C: "Bebible. Con dignidad justa."
- 14-20 °C: "Caldo. Te la bebes por orgullo."
- Más de 20 °C: "Se la ha bebido Paco. Hace rato."

En el final 2 ("Diluvio") los veredictos son otros: "Perfecta. Flotaba, pero perfecta." / "Bebible. Mojada, pero bebible." / "Caldo con espuma de lejía." / "Se la ha bebido Paco. A nado."

## Narrador sarcástico

Un texto en la parte inferior de la pantalla, con efecto máquina de escribir y cola de mensajes, que comenta lo que haces. Guarda todas las frases en un único archivo de datos (diccionario por evento, con varias variantes por evento para que no se repita). Escribe tú las frases; ejemplos de tono:

- Al empezar: "La puerta no abre. Tranquilo, solo es tu cerveza la que sufre."
- Al tirar de la cadena sin motivo: "Muy bien. Has resuelto exactamente nada."
- Código incorrecto: "No. Pero qué seguridad tecleando."
- Al mirar la fregona: "Lleva aquí desde 2009. Es la que manda."

## Sistema de pistas

Con H aparece el móvil (overlay 2D) con un chat de grupo de tus amigos. Cada vez que pides pista, un amigo manda un mensaje con una pista del puzle activo: tres niveles por puzle (vaga, clara, solución directa), siempre mezclada con cachondeo ("¿sigues ahí? Has probado a darle a la luz, lumbreras"). Cada pista sube 1 °C la cerveza.

Los niveles de las pistas del ritual y del espejo son: ritual → "lee la pintada de la puerta, solo da el primer paso; cada acierto enseña el siguiente por la sala" / "empieza por el secador, y la veterana de 2009 es la que lleva ahí desde 2009" / el orden completo; espejo → "que salga caliente" / "falta vapor: mira la tubería roja de la esquina junto a la puerta, y con el grifo frío cerrado" / los pasos exactos. Al llegar a la puerta, la cuarta pista insinúa el final secreto del tapón.

## Estilo visual: primitivas + retro

No hay modelos ni texturas externas; todo se construye con primitivas (`BoxMesh`, `CylinderMesh`, etc.) y materiales de color plano.

Para el aspecto retro, lo más robusto: resolución interna baja (por ejemplo 480x270) con stretch mode `viewport` y filtrado `nearest`, para que se vea pixelado. Paleta sucia de bar: azulejo blanco roto, verde hospital, rojo óxido. Si sobra tiempo, añade texturas procedurales sencillas (azulejos con `NoiseTexture2D` o generadas con `Image`) y niebla suave. No uses shaders complejos si dan cualquier problema.

## Sonido procedural

Sin archivos de audio. Genera los sonidos por código al arrancar, creando `AudioStreamWAV` a partir de muestras calculadas (ondas cuadradas, ruido, barridos): pitido de tecla, error, acierto, clic de interruptor, cisterna (ruido filtrado), secador (ruido continuo), grifo, y una fanfarria corta de victoria. Un zumbido de fluorescente de fondo si es fácil.

Sonidos añadidos en la v2/v3: "clunk" y "rattle" para la palanca y el tapón, "steam" (siseo continuo) mientras el vapor está abierto, y reutiliza "door" y "fanfare" en la inundación.

## Menú y pantalla final

- **Menú inicial:** título, "Jugar", "Salir", los controles y "Finales descubiertos: X/2".
- **Pantalla de victoria:** título y nombre del final alcanzado, tiempo, temperatura de la cerveza, veredicto, finales descubiertos y "Volver a jugar" / "Menú principal". Hay dos finales: "Tirar, que no empujar" (puerta) y "Que lo limpie el bar" (diluvio).

## Requisitos técnicos

- Comprueba primero la versión con `godot --version` y usa solo APIs de esa versión.
- GDScript con tipado estático.
- **Construye la sala y los objetos por código** desde scripts, con escenas `.tscn` mínimas. Escribir a mano `.tscn` grandes es propenso a errores que no puedes ver; generarlo por código es más fiable.
- Registra las acciones de entrada por código con `InputMap` al arrancar, para no depender de editar `project.godot` a mano.
- Arquitectura sencilla: un autoload `GameState` (progreso de puzles, tiempo, temperatura, señales), una clase base `Interactable` con método `interact()` y texto de prompt, y un script por puzle.
- Jugador: `CharacterBody3D` con `RayCast3D` para interactuar. Colisiones en paredes y muebles para que no se pueda salir de la sala.
- **Teclas de depuración:** F1-F4 resuelven al instante cada puzle. Las necesito para probar el final sin jugar todo.
- **Herramientas de prueba (v2):** `godot --headless --path . -- --autotest` juega la partida entera con los objetos reales y debe acabar en PASS; `-- --autotest-flood` prueba el final secreto; `--script res://tests/test_lights_out.gd` comprueba el cuadro eléctrico. `-- --shots=<carpeta> [--closeups] [--lights] [--solve=1234] [--clues] [--steam] [--flood] [--ui]` guarda capturas de pantalla para revisar carteles y colocaciones. Los modos de prueba nunca modifican los finales guardados del jugador.

## Cómo trabajar

Trabaja por fases y deja el juego ejecutable al final de cada una. Si el tiempo se acaba, las primeras fases son las que importan.

1. **Base:** proyecto, sala con paredes y luz, jugador que se mueve y mira, cruceta e interacción con un objeto de prueba.
2. **Puzles:** los cuatro puzles y el final, con textos mínimos. El juego ya se puede completar.
3. **Capa de juego:** narrador, HUD de la cerveza, pistas, menú y pantalla de victoria.
4. **Pulido:** sonido, estilo retro, pintadas de chiste, objetos decorativos.

Después de cada fase, verifica tú mismo que no hay errores ejecutando Godot en modo headless (por ejemplo `godot --headless --path . --quit-after 120` y revisando la salida, o `--check-only` sobre los scripts) y corrige todo error o warning relevante antes de seguir. Tú no puedes ver la pantalla, así que sé conservador con posiciones y tamaños: sala simple, objetos grandes y bien separados, todos a la altura de los ojos o cerca, textos `Label3D` grandes y legibles.

Haz un commit de git al final de cada fase.

## Hecho significa

- El juego arranca sin errores en consola.
- Se puede completar de principio a fin jugando normal, y también usando F1-F4. Los dos finales son alcanzables.
- Ningún puzle puede quedar en un estado sin solución.
- Ningún texto 3D se sale de su cartel, botón o panel (se revisa con las capturas `--closeups`).
- Hay menú, narrador, pistas, sonido y pantalla final con la temperatura de la cerveza.

## Registro de cambios

### v2: cambios tras la primera prueba

Comentarios del jugador tras probar la v1: "algunos textos de carteles están descentrados", "el cuadro eléctrico me gustó, pero los otros puzles son muy simples", "añade un final más".

1. **Textos de carteles:** causa real: el texto estaba centrado pero era más ancho que su soporte (cartel de empleados, "PULSE" del secador, "OCUPADO", "CÓDIGO", etc.). Ahora todos usan `Build.label_fit`, que ajusta el tamaño al hueco. Revisado con capturas en primer plano.
2. **Puzle 2, el ritual:** de 4 pasos con los nombres a la vista a **5 pasos en clave** (adivinanza), con la **fregona** como nuevo elemento. Hay que haber mirado la fregona para entender "la veterana de 2009". Cuenta solo el grifo frío *al abrirlo*.
3. **Puzle 3, el espejo:** de "abre un grifo" a una **cadena de 3 condiciones** (válvula roja abierta, agua caliente con 2,5 s de retraso, grifo frío cerrado). Nuevos objetos: `Valve` (válvula roja). Nuevos mensajes del narrador para cada fallo.
4. **Final 2, el diluvio:** nuevos objetos `SinkPlug` (tapón) y `Flood` (controlador de la inundación). Pantalla de victoria con varios finales y registro persistente de los finales descubiertos.
5. **Pistas del móvil:** reescritas las del ritual y el espejo, y nueva cuarta pista en la puerta que insinúa el final secreto.
6. **Pruebas automáticas:** el autotest cubre el ritual nuevo, el espejo (incluidas las trampas: válvula cerrada y agua tibia) y hay un autotest propio del final del diluvio.

### Qué probar a mano en la siguiente sesión

- ¿Se entiende la adivinanza del ritual sin pistas? ¿Es demasiado difícil o demasiado fácil con la fregona?
- ¿Se descubre la válvula roja por el mensaje del narrador cuando el grifo caliente sale frío?
- ¿Es frustrante que el ritual deje el grifo frío abierto y haya que cerrarlo para el espejo? (Es intencionado, pero conviene confirmarlo.)
- Final 2: ¿se encuentra la pintada de la pared oeste? ¿Los 14 s de inundación se hacen largos? (`TIME_TO_FLOOD` en `scripts/puzzles/flood.gd`.)
- Sonido: no se ha podido escuchar nunca; revisar volúmenes.
- Carteles: ¿queda alguno descentrado o ilegible desde la distancia normal de juego?

### v2.1: ajustes tras la segunda prueba

- **Válvula poco clara:** ahora es más grande y brilla; el narrador dice con claridad dónde está cuando el grifo caliente sale frío; y la válvula **parpadea** en ese momento (`GameState.valve_hint`).
- **Tapón inaccesible:** estaba dentro del collider del grifo frío, que "robaba" el apuntado. Se movió al centro de la pila, es más grande y naranja, con un collider generoso. El autotest comprueba con el rayo real que se puede apuntar al tapón y a la válvula desde posiciones normales.

### v3: tercera prueba

Comentarios del jugador: "el puzle 2 me gusta como idea (ir tocando cosas) pero no que la lista esté completa: que cada objeto te dé la pista del siguiente", "la fregona tiene varios textos y podrías no ver el de 2009", "en el puzle 3 no es intuitivo girar una llave en la cañería del váter ni que sea un círculo: pon una tubería roja de vapor con la llave en una esquina".

1. **Ritual como cadena de pistas:** la pared de la puerta solo muestra el paso 1; cada acierto revela el siguiente en una pared distinta (`Room.ritual_clues`, `GameState.ritual_progressed`). El jugador recorre la sala. Las pistas reveladas se quedan.
2. **Fregona con un único texto:** `Lines.NARRATOR["mop"]` tiene una sola frase. El autotest lo comprueba.
3. **Vapor en la esquina:** la rueda de la tubería del váter desaparece. Nuevo `SteamPipe` (tubería roja suelo-techo, manómetro, boquilla con vapor, cartel) y `Valve` rehecha como palanca amarilla. Nueva señal `GameState.valve_changed` y sonido "steam". El tramo con la palanca queda a ~1,4 m de la puerta, a la derecha, y se ve desde la posición inicial.
4. **Pendiente:** al menos dos minijuegos nuevos (ideas propuestas al jugador, aún sin elegir).

### Qué probar a mano en la siguiente sesión (v3)

- ¿Se entiende que la tubería roja de la esquina es "el vapor del agua caliente"? ¿Se ve desde el principio?
- ¿Se leen bien las frases que aparecen junto a cada objeto? ¿Se encuentra la siguiente sin ayuda?
- ¿El siseo y los chorros de vapor quedan bien? (No he podido oírlos ni ver el movimiento, solo capturas fijas.)
