extends SceneTree
## Generates icon.png (256x256) and icon.ico (16..256) for the project and the Windows export.
## Run: godot --headless --path . --script res://tools/make_icon.gd

const SIZE := 64
const LETTERS := {
	"O": ["111", "101", "101", "101", "111"],
	"C": ["111", "100", "100", "100", "111"],
	"U": ["101", "101", "101", "101", "111"],
	"P": ["111", "101", "111", "100", "100"],
	"A": ["010", "101", "111", "101", "101"],
	"D": ["110", "101", "101", "101", "110"],
}

var img: Image


func _init() -> void:
	img = Image.create_empty(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	_draw()
	var big := img.duplicate() as Image
	big.resize(256, 256, Image.INTERPOLATE_NEAREST)
	var png_path := ProjectSettings.globalize_path("res://icon.png")
	var ico_path := ProjectSettings.globalize_path("res://icon.ico")
	print("png: ", big.save_png(png_path), " -> ", png_path)
	_save_ico(ico_path)
	print("ico -> ", ico_path)
	quit()


func _rect(x0: int, y0: int, x1: int, y1: int, c: Color) -> void:
	for y in range(y0, y1):
		for x in range(x0, x1):
			if x >= 0 and y >= 0 and x < SIZE and y < SIZE:
				img.set_pixel(x, y, c)


func _draw() -> void:
	# Hospital-green tiles.
	var tile := Color(0.17, 0.40, 0.34)
	var grout := Color(0.09, 0.24, 0.20)
	_rect(0, 0, SIZE, SIZE, tile)
	for i in range(0, SIZE, 16):
		_rect(i, 0, i + 1, SIZE, grout)
		_rect(0, i, SIZE, i + 1, grout)
	# Door with frame and panels.
	_rect(10, 3, 54, SIZE, Color(0.22, 0.12, 0.07))
	_rect(13, 6, 51, SIZE, Color(0.52, 0.31, 0.17))
	_rect(17, 10, 47, 16, Color(0.40, 0.23, 0.12))
	_rect(17, 44, 47, 60, Color(0.40, 0.23, 0.12))
	# Handle.
	_rect(41, 36, 46, 39, Color(0.95, 0.80, 0.30))
	# "OCUPADO" sign.
	_rect(14, 17, 50, 31, Color(0.12, 0.08, 0.06))
	_rect(15, 18, 49, 30, Color(0.96, 0.94, 0.86))
	var x := 18
	for ch in "OCUPADO":
		var rows: Array = LETTERS[ch]
		for ry in 5:
			for rx in 3:
				if str(rows[ry])[rx] == "1":
					_rect(x + rx, 19 + ry * 2, x + rx + 1, 21 + ry * 2, Color(0.78, 0.07, 0.07))
		x += 4
	# Beer mug (bottom right) with outline, foam and handle.
	var outline := Color(0.10, 0.06, 0.03)
	_rect(35, 38, 53, 62, outline)
	_rect(36, 43, 52, 61, Color(1.0, 0.72, 0.10))
	_rect(36, 49, 52, 52, Color(1.0, 0.84, 0.30))
	_rect(35, 36, 54, 44, outline)
	_rect(36, 37, 53, 43, Color(1.0, 0.98, 0.92))
	_rect(52, 46, 59, 58, outline)
	_rect(54, 48, 57, 56, tile)
	_rect(52, 48, 54, 56, Color(1.0, 0.72, 0.10))


func _save_ico(path: String) -> void:
	var sizes := [256, 128, 64, 48, 32, 16]
	var blobs: Array[PackedByteArray] = []
	for s: int in sizes:
		var copy := img.duplicate() as Image
		if s >= SIZE:
			copy.resize(s, s, Image.INTERPOLATE_NEAREST)
		else:
			copy.resize(s, s, Image.INTERPOLATE_LANCZOS)
		blobs.append(copy.save_png_to_buffer())
	var out := PackedByteArray()
	out.resize(6 + 16 * sizes.size())
	out.encode_u16(0, 0)
	out.encode_u16(2, 1)
	out.encode_u16(4, sizes.size())
	var offset := out.size()
	for i in sizes.size():
		var s: int = sizes[i]
		var base := 6 + 16 * i
		out.encode_u8(base, 0 if s >= 256 else s)
		out.encode_u8(base + 1, 0 if s >= 256 else s)
		out.encode_u8(base + 2, 0)
		out.encode_u8(base + 3, 0)
		out.encode_u16(base + 4, 1)
		out.encode_u16(base + 6, 32)
		out.encode_u32(base + 8, blobs[i].size())
		out.encode_u32(base + 12, offset)
		offset += blobs[i].size()
	for b in blobs:
		out.append_array(b)
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_buffer(out)
	f.close()
