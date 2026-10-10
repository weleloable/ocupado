class_name Lines
extends RefCounted
## All game texts: narrator lines (several variants per event) and phone hints.

const NARRATOR := {
	"start": [
		"La puerta no abre. Tranquilo, solo es tu cerveza la que sufre.",
		"Encerrado en el baño de un bar. Tu madre estaría orgullosa.",
		"La puerta no cede. Fuera, una caña recién tirada empieza a perder la fe en ti.",
	],
	"start_hint": [
		"Hay un cuadro eléctrico en la pared. En un baño. Con su 'NO TOCAR' y todo.",
		"Esta penumbra tiene pinta de cuadro eléctrico. Lo pone en la pared, literalmente.",
	],
	"door_locked": [
		"Empujas. La puerta, muy digna, no hace nada.",
		"Está cerrada. Igual que tu futuro como cerrajero.",
		"Nada. La puerta tiene más carácter que tú.",
		"Le das un empujón. La puerta ni se inmuta. Es de roble. O de orgullo.",
	],
	"door_pull_hint": [
		"El cartel dice TIRAR. Tú sabrás lo que haces.",
	],
	"door_open": [
		"Tiras. Se abre. Probablemente llevaba abierta toda la noche.",
		"La puerta se abre hacia dentro. Como debe ser. Nadie lea esto como una metáfora.",
	],
	"keypad_wrong": [
		"No. Pero qué seguridad tecleando.",
		"Incorrecto. El teclado te juzga en silencio.",
		"Pitido de error. Universalmente reconocido como 'no, campeón'.",
		"Ese código no. Ni ese, ni el de tu tarjeta, ni el de tu madre.",
	],
	"keypad_correct": [
		"Luz verde. Clic. ...Y la puerta sigue igual. El teclado nunca estuvo conectado a nada. Lo puso el dueño para dar empaque.",
		"Código correcto. El teclado se pone verde con mucho orgullo. Lástima que no esté conectado a ningún sitio.",
	],
	"sign_flip": [
		"Ah, mira. El cartel de la puerta se ha dado la vuelta. Pone TIRAR. Siempre puso TIRAR.",
		"El cartel de OCUPADO gira y revela su otra cara: TIRAR. Toda la noche empujando.",
	],
	"keypad_done": [
		"El teclado sigue en verde. Decorativo y feliz.",
		"No le des más al teclado. Ya ha hecho su papel: ninguno.",
	],
	"breaker_locked": [
		"Ya hay luz. No lo toques, que esto lo montó el cuñado del dueño.",
		"Las cuatro verdes. Déjalo así antes de que salte todo el bar.",
	],
	"breaker_solved": [
		"¡Luz! Y una luz negra. En un baño. Mejor no preguntar por qué.",
		"Se hace la luz. También una luz negra, que revela cosas que nadie debería ver en un baño.",
	],
	"flush_idle": [
		"Muy bien. Has resuelto exactamente nada.",
		"La cisterna ruge. Tu dignidad, también.",
		"Has tirado de la cadena. El váter estaba vacío. Como tu plan.",
	],
	"dryer_idle": [
		"El secador escupe aire tibio y cierta sensación de fracaso.",
		"Brrrrr. Tienes las manos secas. Encerrado sigues igual.",
		"El secador funciona. Es lo único en este baño que hace su trabajo.",
	],
	"cold_tap_on": [
		"Agua fría. Refrescante. Inútil.",
		"Abres el grifo frío. El agua sale con desgana, como un lunes.",
	],
	"hot_tap_on": [
		"Agua caliente. Tarda, pero llega. Como el camarero.",
		"El grifo caliente echa vapor. Este baño es más sauna que bar.",
	],
	"ritual_fail": [
		"Mal. El ritual se reinicia. Los parroquianos de verdad no se equivocan.",
		"Eso no tocaba. Vuelta a empezar, aprendiz.",
		"Error de protocolo. El espíritu del bar está decepcionado.",
	],
	"ritual_clue_1": [
		"Bien. Aparece en la pared de encima una frase con luz negra: «2. LA VETERANA DE 2009».",
	],
	"ritual_clue_2": [
		"Sigue el hilo. Junto a la fregona aparece otra frase: «3. EL RÍO QUE ARRASTRA».",
	],
	"ritual_clue_3": [
		"Cada acierto deja un recado. Junto al váter se enciende: «4. LO FRÍO QUE MOJA».",
	],
	"ritual_clue_4": [
		"Casi. Encima del espejo aparece lo último: «5. OTRA VEZ EL VIENTO».",
	],
	"ritual_solved": [
		"¡Clonc! El dispensador de papel se ha abierto. El ritual funciona. Nadie sabe por qué.",
		"El dispensador de papel se abre de golpe. Tanto ritual para un trozo de papel.",
	],
	"dispenser_closed": [
		"Está cerrado. Cerradísimo. Ni papel ni esperanza.",
		"Dispensador metálico. Con cerradura. Para papel. Claro que sí.",
	],
	"dispenser_note": [
		"Una nota: '_ _ 1 2'. Alguien dejó media contraseña y se fue tan pancho.",
		"La nota dice '_ _ 1 2'. El resto estará en otro sitio. Típico.",
	],
	"mirror_look": [
		"Te miras al espejo. Te devuelve una mirada de 'te lo dije'.",
		"Un espejo sucio. Tú, al otro lado, también.",
		"Te ves bien. Para estar encerrado en un baño, digo.",
	],
	"mirror_fogged": [
		"El espejo está empañado y alguien ha escrito con el dedo: '3 3 _ _'. Qué asco y qué útil.",
	],
	"mirror_reveal": [
		"El vaho revela algo escrito con el dedo: '3 3 _ _'. La higiene, una vez más, al servicio del misterio.",
		"Con el vaho aparece un mensaje en el espejo: '3 3 _ _'. Alguien se aburría mucho aquí.",
	],
	"mirror_after": [
		"El espejo, ya sin vaho. Ponía '3 3 _ _'. Por si se te olvida.",
	],
	"hint_used": [
		"Has pedido ayuda por el grupo. Tu cerveza se calienta de vergüenza.",
		"Pista pedida. Un grado más. La cerveza lo apunta.",
		"Tus amigos te ayudan. A su manera. Y tu cerveza lo paga.",
	],
	"mop": [
		"Lleva aquí desde 2009. Es la que manda.",
	],
	"roll": [
		"Rollo vacío. El clásico.",
		"Solo queda el cartón. Aquí alguien ha vivido una tragedia.",
		"El rollo está vacío. Como la promesa del dueño de 'reponer mañana'.",
	],
	"employees_sign": [
		"'Los empleados deben lavarse las manos.' El camarero no lo ha leído en su vida.",
		"Un cartel muy serio en un baño muy poco serio.",
	],
	"toilet": [
		"Un váter. Mejor no mirar dentro.",
		"Está... limpio. Sospechosamente limpio.",
		"El váter no es la salida. Ni lo pienses.",
	],
	"hot_tap_cold": [
		"Sale fría. Al agua caliente le falta vapor: abre la llave de la tubería roja de la esquina, junto a la puerta.",
		"Agua helada. La tubería roja de vapor de la esquina tiene una llave: ábrela y espera.",
		"El grifo caliente escupe agua fría. El vapor está cortado en la llave de la tubería roja, junto a la puerta.",
	],
	"valve_open": [
		"El vapor entra en las tuberías con un bufido. Algo caliente viene de camino.",
		"Clonc. La tubería roja ruge y empieza a sisear. Agua caliente en camino, con la calma de un lunes.",
	],
	"valve_close": [
		"Cortas el vapor. La caldera suspira, aliviada.",
		"Llave cerrada. El vapor se queda en su cueva.",
	],
	"hot_water_arrives": [
		"Por fin agua caliente. Este baño empieza a parecer una sauna finlandesa de baja categoría.",
		"Sale vapor. El espejo está de acuerdo en ponerse misterioso.",
	],
	"tap_mixed": [
		"Fría y caliente a la vez: tibia. Y la tibia no empaña nada.",
		"Con los dos grifos abiertos sale agua tibia. Tibia, como tu cerveza... pronto.",
	],
	"plug_in": [
		"Pones el tapón. Esto no puede acabar mal.",
		"Tapón puesto. Los fontaneros ya te odian.",
	],
	"plug_out": [
		"Quitas el tapón. Cobarde.",
		"Tapón fuera. Los fontaneros respiran.",
	],
	"overflow_start": [
		"El lavabo está a punto de rebosar. Esto va a salir regular.",
		"El agua empieza a rebosar. Algo se ha roto: tu sentido común.",
	],
	"flood_rising": [
		"El agua ya cubre el suelo. A tus amigos ni se les pasa por la cabeza que estés tramando esto.",
		"Sube el agua. Es un plan. Pésimo, pero un plan.",
	],
	"flood_burst": [
		"¡La puerta cede! El baño vomita agua y a ti detrás.",
		"CRAAAC. La puerta no aguanta y el baño entero sale por ella.",
	],
	"test_object": [
		"Esto es un objeto de prueba. Muy interactivo. Muy de prueba.",
	],
}

## Ending texts shown on the victory screen.
const ENDINGS := {
	"door": {
		"title": "¡LIBRE!",
		"subtitle": "Has escapado del baño. Tu cerveza te esperaba.",
		"name": "Final 1: Tirar, que no empujar",
	},
	"flood": {
		"title": "¡DILUVIO!",
		"subtitle": "Has escapado a lo bruto. El bar es ahora una piscina y tú, el culpable.",
		"name": "Final 2: Que lo limpie el bar",
	},
}

## Beer verdict by temperature range: <8, 8-14, 14-20, >20.
const VERDICTS := {
	"door": [
		"Perfecta. Tus amigos ni se han dado cuenta.",
		"Bebible. Con dignidad justa.",
		"Caldo. Te la bebes por orgullo.",
		"Se la ha bebido Paco. Hace rato.",
	],
	"flood": [
		"Perfecta. Flotaba, pero perfecta.",
		"Bebible. Mojada, pero bebible.",
		"Caldo con espuma de lejía.",
		"Se la ha bebido Paco. A nado.",
	],
}

## Three levels per puzzle: vague, clear, direct solution. [friend, message]
const HINTS := {
	"breaker": [
		["Javi", "¿Sigues ahí? Si está todo oscuro, digo yo que habrá un interruptor, lumbreras."],
		["Lucía", "El cuadro eléctrico. Cada palanca cambia su luz y las de los lados. Queremos las cuatro verdes, no un belén."],
		["Paco", "Dale a la 2, a la 3 y a la 4. De nada. Por cierto, me estoy comiendo tu tapa."],
	],
	"ritual": [
		["Marta", "Ahora que tienes luz negra, lee la pintada del ritual, la de la pared de la puerta. Solo te dice el primer paso. Cada acierto te enseña el siguiente, por la sala."],
		["Javi", "El viento que seca es el secador. Tócalo y saldrá una frase nueva en la pared. Síguela: cada objeto correcto te da la pista del siguiente. La veterana de 2009 es la que lleva ahí desde 2009."],
		["Lucía", "Secador, fregona, cadena, grifo frío y otra vez secador. Si fallas, desde el principio. Como un parroquiano de verdad."],
	],
	"mirror": [
		["Paco", "¿Te has lavado las manos? Con agua caliente. Y que salga caliente, que no es lo mismo."],
		["Marta", "Si el grifo caliente sale frío, es que falta vapor. Mira la tubería roja de la esquina, junto a la puerta: tiene una llave. Y con el grifo frío cerrado, que si no sale tibia."],
		["Javi", "Gira la palanca de la tubería roja de vapor (esquina de la puerta), cierra el grifo frío, abre el caliente y espera unos segundos mirando al espejo. Sale '3 3'. Si cierras el grifo, se borra."],
	],
	"keypad": [
		["Lucía", "Tienes trozos de un código, ¿no? Junta las piezas, que no es un mueble de Ikea."],
		["Paco", "Espejo: las dos primeras cifras. Nota del dispensador: las dos últimas. Hasta yo lo veo, y voy por la cuarta."],
		["Marta", "3312. Teclea 3312 en el teclado de la puerta. Sin miedo."],
	],
	"door": [
		["Javi", "¿El teclado está verde y sigues dentro? Lee el cartel de la puerta, anda."],
		["Lucía", "El cartel lo pone clarito: TIRAR. No empujar. Tirar."],
		["Paco", "Mira la puerta y dale a la E. Tira. Ya. Tu cerveza está llorando."],
		["Marta", "Y si lo tuyo es la salida a lo bruto, el lavabo tiene tapón por algo. Tapón, los dos grifos abiertos y paciencia. Yo no he dicho nada."],
	],
}

static var _last: Dictionary = {}


static func pick(event: String) -> String:
	if not NARRATOR.has(event):
		push_warning("Narrator event without lines: %s" % event)
		return ""
	var options: Array = NARRATOR[event]
	if options.is_empty():
		return ""
	var idx := randi() % options.size()
	var last: int = _last.get(event, -1)
	if options.size() > 1 and idx == last:
		idx = (idx + 1) % options.size()
	_last[event] = idx
	return str(options[idx])
