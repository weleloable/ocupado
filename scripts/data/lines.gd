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
		"La fregona te observa. No la toques. Tiene contactos.",
		"Huele a lejía y a decisiones dudosas.",
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
	"test_object": [
		"Esto es un objeto de prueba. Muy interactivo. Muy de prueba.",
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
		["Marta", "Ahora que tienes luz, lee las paredes. En los baños de bar la respuesta siempre está escrita con rotulador."],
		["Javi", "La pintada del ritual: usa esas cosas en ese orden exacto. Si fallas, se empieza de cero. Como mis relaciones."],
		["Lucía", "Secador, cadena, grifo frío y otra vez secador. En ese orden. Como un parroquiano de verdad."],
	],
	"mirror": [
		["Paco", "¿Te has lavado las manos? Con agua caliente. Por higiene y por otras cosas."],
		["Marta", "Abre el grifo caliente y espera un poco mirando al espejo. El vaho cuenta cosas."],
		["Javi", "Grifo caliente abierto unos segundos y en el espejo sale '3 3'. Si lo cierras, se borra."],
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
