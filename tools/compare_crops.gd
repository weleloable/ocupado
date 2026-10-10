extends SceneTree
## Debug: stacks the same crop of several screenshots, magnified, into one image.
## godot --headless --script res://tools/compare_crops.gd -- out.png x y w h scale in1.png in2.png ...

func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var out := a[0]
	var r := Rect2i(int(a[1]), int(a[2]), int(a[3]), int(a[4]))
	var k := int(a[5])
	var crops: Array[Image] = []
	for i in range(6, a.size()):
		var img := Image.load_from_file(a[i])
		var c := img.get_region(r)
		c.resize(r.size.x * k, r.size.y * k, Image.INTERPOLATE_NEAREST)
		crops.append(c)
	var sheet := Image.create_empty(crops[0].get_width(), crops[0].get_height() * crops.size() + 4 * (crops.size() - 1), false, Image.FORMAT_RGBA8)
	sheet.fill(Color.BLACK)
	for i in crops.size():
		sheet.blit_rect(crops[i], Rect2i(Vector2i.ZERO, crops[i].get_size()), Vector2i(0, i * (crops[i].get_height() + 4)))
	sheet.save_png(out)
	quit()
