class_name UISkin
## Procedurally generated, game-style UI skins: chamfered metal plates for buttons and
## framed panels with corner gems. Textures are built once and cached.

const SIZE := 48
const CHAMFER := 9
static var _cache: Dictionary = {}


static func _inset(x: int, y: int, w: int, h: int, c: int) -> float:
	# Distance from (x, y) to the edge of a chamfered rectangle (negative = outside).
	var d := float(mini(mini(x, y), mini(w - 1 - x, h - 1 - y)))
	var k := 0.7071
	d = minf(d, (x + y - c) * k)
	d = minf(d, ((w - 1 - x) + y - c) * k)
	d = minf(d, (x + (h - 1 - y) - c) * k)
	d = minf(d, ((w - 1 - x) + (h - 1 - y) - c) * k)
	return d


## state: normal | hover | pressed | disabled
static func plate(face: Color, rim: Color, state: String) -> Texture2D:
	var key := "plate|%s|%s|%s" % [face.to_html(), rim.to_html(), state]
	if _cache.has(key):
		return _cache[key]
	var w := SIZE
	var h := SIZE
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var outline := Color(0.03, 0.035, 0.06, 1.0)
	var top := face.lightened(0.22)
	var bottom := face.darkened(0.3)
	if state == "pressed":
		var tmp := top
		top = bottom
		bottom = tmp.darkened(0.1)
	if state == "hover":
		top = top.lightened(0.08)
	if state == "disabled":
		top = Color(top.get_luminance(), top.get_luminance(), top.get_luminance()).darkened(0.35)
		bottom = Color(bottom.get_luminance(), bottom.get_luminance(), bottom.get_luminance()).darkened(0.35)
		rim = Color(0.35, 0.37, 0.45)
	var lip := 0 if state == "pressed" else 5
	for y in h:
		for x in w:
			var d := _inset(x, y, w, h, CHAMFER)
			if d < 0.0:
				continue
			var col: Color
			if d < 1.6:
				col = outline
			elif d < 3.6:
				# metallic rim: brighter on top-left, darker bottom-right
				var shade := 0.25 * (float(x + y) / float(w + h) - 0.5)
				col = rim.darkened(shade) if shade > 0 else rim.lightened(-shade)
			elif d < 4.6:
				col = outline.lerp(face, 0.3)
			else:
				var t := float(y) / float(h - 1)
				col = top.lerp(bottom, t)
				if h - 1 - y < lip + 4 and d >= 4.6:
					col = col.darkened(0.35)           # 3D bottom lip
				if y <= 6 and d < 6.5:
					col = col.lightened(0.28)          # top glint
				# faint brushed-metal streaks
				col = col.lightened(0.03 * sin(float(y) * 1.7 + float(x) * 0.15))
			img.set_pixel(x, y, col)
	var tex := ImageTexture.create_from_image(img)
	_cache[key] = tex
	return tex


static func button_box(face: Color, rim: Color, state: String) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = plate(face, rim, state)
	sb.set_texture_margin_all(CHAMFER + 5)
	sb.texture_margin_bottom = CHAMFER + 8
	sb.content_margin_left = 20
	sb.content_margin_right = 20
	sb.content_margin_top = 10 + (3 if state == "pressed" else 0)
	sb.content_margin_bottom = 12 - (3 if state == "pressed" else 0)
	return sb


static func style_button(b: Button, face: Color, rim: Color, hover_rim: Color = Palette.GOLD, text: Color = Palette.TEXT) -> void:
	b.add_theme_stylebox_override("normal", button_box(face, rim, "normal"))
	b.add_theme_stylebox_override("hover", button_box(face, hover_rim, "hover"))
	b.add_theme_stylebox_override("pressed", button_box(face, hover_rim, "pressed"))
	b.add_theme_stylebox_override("disabled", button_box(face, rim, "disabled"))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_color_override("font_color", text)
	b.add_theme_color_override("font_hover_color", text.lightened(0.25))
	b.add_theme_color_override("font_pressed_color", hover_rim.lightened(0.3))
	b.add_theme_color_override("font_disabled_color", Color(0.55, 0.57, 0.65))
	b.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.75))
	b.add_theme_constant_override("outline_size", 5)


## Framed panel: dark inner field, double border and small diamond gems in the corners.
static func frame(bg: Color, border: Color) -> Texture2D:
	var key := "frame|%s|%s" % [bg.to_html(), border.to_html()]
	if _cache.has(key):
		return _cache[key]
	var w := 64
	var h := 64
	var c := 12
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var outline := Color(0.03, 0.035, 0.06, 1.0)
	for y in h:
		for x in w:
			var d := _inset(x, y, w, h, c)
			if d < 0.0:
				continue
			var col: Color
			if d < 1.5:
				col = outline
			elif d < 3.5:
				col = border
			elif d < 5.0:
				col = outline.lerp(bg, 0.4)
			elif d < 6.0:
				col = border.darkened(0.35)
			else:
				col = bg.lerp(bg.darkened(0.25), float(y) / h)
			img.set_pixel(x, y, col)
	# corner gems
	for corner in [Vector2i(9, 9), Vector2i(w - 10, 9), Vector2i(9, h - 10), Vector2i(w - 10, h - 10)]:
		for dy in range(-3, 4):
			for dx in range(-3, 4):
				if absi(dx) + absi(dy) <= 3:
					img.set_pixel(corner.x + dx, corner.y + dy, border.lightened(0.35) if absi(dx) + absi(dy) <= 1 else border)
	var tex := ImageTexture.create_from_image(img)
	_cache[key] = tex
	return tex


static func panel_box(bg: Color, border: Color, margin: int = 22) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = frame(bg, border)
	sb.set_texture_margin_all(16)
	sb.content_margin_left = margin + 4
	sb.content_margin_right = margin + 4
	sb.content_margin_top = margin
	sb.content_margin_bottom = margin
	return sb
