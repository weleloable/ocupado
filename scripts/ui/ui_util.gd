class_name UiUtil
extends RefCounted
## Helpers to build 2D UI by code (viewport is 640 x 360).

const VIEW := Vector2(640, 360)


static func label(parent: Node, text: String, pos: Vector2, size: Vector2, font_size: int = 13,
		color: Color = Color.WHITE, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT,
		outline: int = 4) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.size = size
	l.horizontal_alignment = align
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ls := LabelSettings.new()
	ls.font_size = font_size
	ls.font_color = color
	ls.outline_size = outline
	ls.outline_color = Color(0, 0, 0, 0.9)
	l.label_settings = ls
	parent.add_child(l)
	return l


static func rect(parent: Node, color: Color, pos: Vector2, size: Vector2) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.position = pos
	r.size = size
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)
	return r


static func button(parent: Node, text: String, pos: Vector2, size: Vector2, font_size: int = 14) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = size
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", font_size)
	parent.add_child(b)
	return b


static func full_rect_control(parent: Node) -> Control:
	var c := Control.new()
	c.position = Vector2.ZERO
	c.size = VIEW
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(c)
	return c
