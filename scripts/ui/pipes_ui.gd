class_name PipesUi
extends CanvasLayer
## 2D boiler pipes puzzle: click a piece to rotate it (right click rotates back). The steam enters
## on the left and must reach the boiler on the right; pieces reached by the steam light up.

signal closed

const TILE := 56
const ORIGIN := Vector2(180, 92)

var rotations: Array = []
var _tiles: Array[PipeTile] = []
var _status: Label
var _outlet: Label
var _locked: bool = false


## One clickable piece of the grid.
class PipeTile extends Control:
	signal clicked(index: int, direction: int)
	var index: int = 0
	var mask: int = 0
	var wet: bool = false

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			var b := event as InputEventMouseButton
			if b.button_index == MOUSE_BUTTON_LEFT:
				clicked.emit(index, 1)
			elif b.button_index == MOUSE_BUTTON_RIGHT:
				clicked.emit(index, -1)

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.11, 0.13, 0.17))
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.3, 0.33, 0.4), false, 1.0)
		var c := size * 0.5
		var col := Color(0.35, 0.85, 1.0) if wet else Color(0.55, 0.57, 0.62)
		var w := 12.0
		if mask & PipeGrid.N:
			draw_line(c, Vector2(c.x, 0), col, w)
		if mask & PipeGrid.E:
			draw_line(c, Vector2(size.x, c.y), col, w)
		if mask & PipeGrid.S:
			draw_line(c, Vector2(c.x, size.y), col, w)
		if mask & PipeGrid.W:
			draw_line(c, Vector2(0, c.y), col, w)
		if mask != 0:
			draw_circle(c, w * 0.5 + 1.0, col)


func _ready() -> void:
	layer = 5
	visible = false
	rotations = PipeGrid.start_state()
	var root := UiUtil.full_rect_control(self)
	UiUtil.rect(root, Color(0, 0, 0, 0.5), Vector2.ZERO, UiUtil.VIEW)
	var panel := UiUtil.rect(root, Color(0.16, 0.19, 0.2), Vector2(70, 18), Vector2(500, 324))
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	UiUtil.label(root, "CUADRO DE LA CALDERA", Vector2(0, 26), Vector2(640, 20), 16, Color(0.95, 0.9, 0.7), HORIZONTAL_ALIGNMENT_CENTER, 0)
	UiUtil.label(root, "Gira las tuberías para que el vapor llegue a la caldera.", Vector2(0, 50), Vector2(640, 16), 11,
			Color(0.8, 0.85, 0.85), HORIZONTAL_ALIGNMENT_CENTER, 0)
	UiUtil.label(root, "VAPOR >", Vector2(96, ORIGIN.y + TILE * PipeGrid.SOURCE_ROW + 20), Vector2(80, 16), 12,
			Color(0.35, 0.85, 1.0), HORIZONTAL_ALIGNMENT_RIGHT, 0)
	_outlet = UiUtil.label(root, "> CALDERA", Vector2(ORIGIN.x + TILE * PipeGrid.COLS + 4, ORIGIN.y + TILE * PipeGrid.OUTLET_ROW + 20),
			Vector2(90, 16), 12, Color(0.6, 0.6, 0.65), HORIZONTAL_ALIGNMENT_LEFT, 0)
	for i in PipeGrid.COLS * PipeGrid.ROWS:
		var tile := PipeTile.new()
		tile.index = i
		tile.position = ORIGIN + Vector2((i % PipeGrid.COLS) * TILE, (i / PipeGrid.COLS) * TILE)
		tile.size = Vector2(TILE, TILE)
		tile.mouse_filter = Control.MOUSE_FILTER_STOP
		tile.clicked.connect(_on_tile_clicked)
		root.add_child(tile)
		_tiles.append(tile)
	_status = UiUtil.label(root, "", Vector2(0, 306), Vector2(640, 16), 12, Color(1.0, 0.9, 0.5), HORIZONTAL_ALIGNMENT_CENTER, 0)
	UiUtil.label(root, "[Clic] girar  ·  [Clic derecho] girar al revés  ·  [Esc] cerrar", Vector2(0, 324), Vector2(640, 14), 10,
			Color(0.7, 0.75, 0.75), HORIZONTAL_ALIGNMENT_CENTER, 0)
	_refresh()


func open() -> void:
	visible = true
	_refresh()


func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


func _on_tile_clicked(index: int, direction: int) -> void:
	if _locked:
		return
	rotations[index] = posmod(rotations[index] + direction, 4)
	Sfx.play("click", -4.0, 0.8 + 0.1 * (index % 4))
	_refresh()
	if PipeGrid.is_solved(rotations):
		_solve()


## Used by the debug autotest: puts the pieces in the known solution.
func solve_for_test() -> void:
	rotations = PipeGrid.solved_state()
	_refresh()
	if PipeGrid.is_solved(rotations):
		_solve()


func _refresh() -> void:
	var wet := PipeGrid.wet_cells(rotations)
	for i in _tiles.size():
		_tiles[i].mask = PipeGrid.openings(i, rotations)
		_tiles[i].wet = wet.has(i)
		_tiles[i].queue_redraw()
	if not _locked:
		_status.text = "El vapor llega a %d piezas." % wet.size()


func _solve() -> void:
	_locked = true
	_status.text = "Presión estable. La caldera se enciende."
	_outlet.label_settings.font_color = Color(0.3, 1.0, 0.4)
	Sfx.play("success")
	GameState.solve_pipes()
	var t := create_tween()
	t.tween_interval(1.8)
	t.tween_callback(close)
