# Ocupado

Escape room en el baño de un bar. Tu cerveza se calienta. Tú verás.

Juego de Godot 4.7.2 (renderizador Compatibility), 3D en primera persona, de 10 a 15 minutos, con dos finales.

- **Jugar en el navegador:** <https://weleloable.github.io/ocupado/> (también desde la app Ruta de Bares, pestaña Juegos).
- **En PC:** WASD para moverse, ratón para mirar, E o clic para usar, H para el móvil con pistas, Esc para pausa.
- **En el móvil:** joystick a la izquierda, arrastrar a la derecha para mirar, tocar o pulsar USAR para usar, y los botones Móvil y pausa. Los mandos táctiles solo salen en pantallas táctiles (`scripts/ui/touch_controls.gd`).

## Publicación

Cada push a `master` pasa los autotests y publica la versión web en GitHub Pages (`.github/workflows/publicar-web.yml`). La exportación es de **un solo hilo** (`variant/thread_support=false`), así que no necesita las cabeceras COOP/COEP que GitHub Pages no deja poner.

## Pruebas

```bash
godot --headless --path . -- --autotest          # la partida entera
godot --headless --path . -- --autotest-flood    # el final secreto
godot --headless --path . -- --autotest-tactil   # los mandos del móvil, con toques de verdad
godot --path . -- --tactil                       # jugar en PC con los mandos del móvil
```

## Dentro de la app Ruta de Bares

Al ganar, el juego avisa a la página que lo contiene con `postMessage` (`scripts/core/app_bridge.gd`):
`{ tipo: "ocupado:fin", version: 1, final, segundos, temperatura, pistas }`. La app comprueba que el mensaje viene de `https://weleloable.github.io` y guarda el récord. En la web, `?prueba=ganar` empieza y gana sola a los 2 segundos, para probar ese aviso.

Las plantillas de exportación web se pueden bajar sin el paquete completo de 1,3 GB: `python tools/plantillas_web.py 4.7.2 <carpeta>`.
