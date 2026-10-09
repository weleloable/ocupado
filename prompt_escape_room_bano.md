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
- **Pintadas** en las paredes (usa `Label3D`): algunas visibles desde el principio y son solo chistes, otras ocultas hasta que se enciende la luz negra.
- Un rollo de papel vacío, una fregona, un cartel de "Empleados deben lavarse las manos": decoración interactuable que solo dispara comentarios del narrador.

Al empezar, la sala solo tiene una luz de emergencia tenue.

## Cadena de puzles

No hay inventario. Cada puzle revela información o activa algo.

**1. Cuadro eléctrico (lógica).** Cuatro interruptores en fila; cada uno invierte su piloto y el de sus vecinos (estilo Lights Out). El objetivo es dejar los cuatro pilotos encendidos. Elige un estado inicial que requiera al menos 3 pulsaciones y comprueba por fuerza bruta en un test que tiene solución. Al resolverlo se enciende la luz general y una **luz negra** que revela pintadas ocultas. Una de ellas es "El ritual del parroquiano" con cuatro iconos o palabras en orden: SECADOR → CADENA → GRIFO FRÍO → SECADOR.

**2. El ritual (secuencia).** Hay que accionar esos elementos en ese orden exacto. Un error reinicia la secuencia (con burla del narrador). Los elementos se pueden usar libremente antes de resolver el puzle 1, pero la secuencia solo cuenta cuando la luz negra está encendida. Al completarla, el dispensador de papel se abre con un ruido y muestra una nota: "_ _ 1 2".

**3. El espejo (mecanismo).** Abrir el grifo caliente durante unos segundos empaña el espejo y aparece escrito con el dedo "3 3 _ _". Si se cierra el grifo, el vaho desaparece poco a poco. Este puzle se puede resolver en cualquier momento.

**4. Teclado de la puerta (código).** Al interactuar se abre una interfaz 2D con teclado numérico (ratón visible, Esc para cerrar). Código correcto: **3312**. Un código incorrecto da un pitido de error y un comentario del narrador.

**Final (chiste).** Al introducir el código correcto, el teclado se pone verde... y la puerta sigue sin abrir. El cartel de la puerta, que hasta ahora estaba girado o medio tapado, dice "TIRAR". El narrador comenta que el teclado nunca estuvo conectado a nada. El jugador interactúa con la puerta, se abre, y aparece la pantalla de victoria.

## La cerveza (puntuación)

En el HUD hay un termómetro pequeño con la temperatura de tu cerveza. Empieza a 4 °C y sube lentamente con el tiempo (aprox. 1 °C cada 40 segundos). Cada pista pedida suma 1 °C extra. No hay derrota: es solo la puntuación. La pantalla final muestra el tiempo, la temperatura y un veredicto según el rango, por ejemplo:

- Menos de 8 °C: "Perfecta. Tus amigos ni se han dado cuenta."
- 8-14 °C: "Bebible. Con dignidad justa."
- 14-20 °C: "Caldo. Te la bebes por orgullo."
- Más de 20 °C: "Se la ha bebido Paco. Hace rato."

## Narrador sarcástico

Un texto en la parte inferior de la pantalla, con efecto máquina de escribir y cola de mensajes, que comenta lo que haces. Guarda todas las frases en un único archivo de datos (diccionario por evento, con varias variantes por evento para que no se repita). Escribe tú las frases; ejemplos de tono:

- Al empezar: "La puerta no abre. Tranquilo, solo es tu cerveza la que sufre."
- Al tirar de la cadena sin motivo: "Muy bien. Has resuelto exactamente nada."
- Código incorrecto: "No. Pero qué seguridad tecleando."
- Al mirar la fregona: "Lleva aquí desde 2009. Es la que manda."

## Sistema de pistas

Con H aparece el móvil (overlay 2D) con un chat de grupo de tus amigos. Cada vez que pides pista, un amigo manda un mensaje con una pista del puzle activo: tres niveles por puzle (vaga, clara, solución directa), siempre mezclada con cachondeo ("¿sigues ahí? Has probado a darle a la luz, lumbreras"). Cada pista sube 1 °C la cerveza.

## Estilo visual: primitivas + retro

No hay modelos ni texturas externas; todo se construye con primitivas (`BoxMesh`, `CylinderMesh`, etc.) y materiales de color plano.

Para el aspecto retro, lo más robusto: resolución interna baja (por ejemplo 480x270) con stretch mode `viewport` y filtrado `nearest`, para que se vea pixelado. Paleta sucia de bar: azulejo blanco roto, verde hospital, rojo óxido. Si sobra tiempo, añade texturas procedurales sencillas (azulejos con `NoiseTexture2D` o generadas con `Image`) y niebla suave. No uses shaders complejos si dan cualquier problema.

## Sonido procedural

Sin archivos de audio. Genera los sonidos por código al arrancar, creando `AudioStreamWAV` a partir de muestras calculadas (ondas cuadradas, ruido, barridos): pitido de tecla, error, acierto, clic de interruptor, cisterna (ruido filtrado), secador (ruido continuo), grifo, y una fanfarria corta de victoria. Un zumbido de fluorescente de fondo si es fácil.

## Menú y pantalla final

- **Menú inicial:** título, "Jugar", "Salir" y los controles.
- **Pantalla de victoria:** tiempo, temperatura de la cerveza, veredicto y "Volver a jugar".

## Requisitos técnicos

- Comprueba primero la versión con `godot --version` y usa solo APIs de esa versión.
- GDScript con tipado estático.
- **Construye la sala y los objetos por código** desde scripts, con escenas `.tscn` mínimas. Escribir a mano `.tscn` grandes es propenso a errores que no puedes ver; generarlo por código es más fiable.
- Registra las acciones de entrada por código con `InputMap` al arrancar, para no depender de editar `project.godot` a mano.
- Arquitectura sencilla: un autoload `GameState` (progreso de puzles, tiempo, temperatura, señales), una clase base `Interactable` con método `interact()` y texto de prompt, y un script por puzle.
- Jugador: `CharacterBody3D` con `RayCast3D` para interactuar. Colisiones en paredes y muebles para que no se pueda salir de la sala.
- **Teclas de depuración:** F1-F4 resuelven al instante cada puzle. Las necesito para probar el final sin jugar todo.

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
- Se puede completar de principio a fin jugando normal, y también usando F1-F4.
- Ningún puzle puede quedar en un estado sin solución.
- Hay menú, narrador, pistas, sonido y pantalla final con la temperatura de la cerveza.
