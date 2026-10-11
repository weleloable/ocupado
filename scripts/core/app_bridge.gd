class_name AppBridge
extends RefCounted
## Avisa a la app que contiene el juego (Ruta de Bares, que lo carga en un
## iframe o lo abre en otra pestana) de como ha ido la partida. Solo en web: en
## escritorio no hace nada.
##
## Va por `postMessage` a la ventana padre (iframe) y a la que lo abrio
## (`window.opener`, pestana nueva). El destino es '*' porque no hay nada
## secreto (final, tiempo, temperatura, pistas) y es la APP la que comprueba de
## que origen le llega el mensaje. El formato es un contrato con la app
## (`src/features/minijuegos/juegos/ocupado/mensaje.ts` en ruta-de-bares): si se
## cambia, se sube `version`.

const VERSION := 1


static func avisar(datos: Dictionary) -> void:
	if not OS.has_feature("web"):
		return
	var js := "(function (m) { try {" \
			+ " if (window.parent && window.parent !== window) window.parent.postMessage(m, '*');" \
			+ " if (window.opener) window.opener.postMessage(m, '*');" \
			+ " } catch (e) {} })(%s);" % JSON.stringify(datos)
	JavaScriptBridge.eval(js, true)


## Al ganar: el final y como se gano.
static func fin() -> void:
	avisar({
		"tipo": "ocupado:fin",
		"version": VERSION,
		"final": GameState.ending,
		"segundos": snappedf(GameState.final_time, 0.1),
		"temperatura": snappedf(GameState.final_temp, 0.1),
		"pistas": GameState.hints_used,
	})
