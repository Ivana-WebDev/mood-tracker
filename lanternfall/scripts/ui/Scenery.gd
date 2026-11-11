class_name Scenery
## Layered vector landscapes: gradient sky, stars, mountain ranges, hanging lanterns, fog and embers.

static func _noise(x: float, seed_f: float) -> float:
	return sin(x * 0.0041 + seed_f * 13.1) * 0.55 + sin(x * 0.0113 + seed_f * 7.7) * 0.3 + sin(x * 0.029 + seed_f * 3.3) * 0.15


static func gradient_rect(ci: CanvasItem, r: Rect2, top: Color, bottom: Color) -> void:
	ci.draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]),
		PackedColorArray([top, top, bottom, bottom]))


static func draw(ci: CanvasItem, size: Vector2, accent: Color, t: float, horizon: float = 0.62, lanterns: bool = true, scroll: float = 0.0, moon_x: float = 0.82) -> void:
	var hy := size.y * horizon
	var sky_top := Color("07080f")
	var sky_mid := Palette.BG.lerp(accent, 0.12)
	var sky_low := Palette.BG_2.lerp(accent, 0.3)
	gradient_rect(ci, Rect2(0, 0, size.x, hy * 0.6), sky_top, sky_mid)
	gradient_rect(ci, Rect2(0, hy * 0.6, size.x, hy * 0.4 + 1), sky_mid, sky_low)
	# Stars
	for i in 46:
		var sx := fmod(i * 197.3 + 31.0 - scroll * 0.05, size.x + 20.0)
		var sy := fmod(i * 83.7, hy * 0.75)
		var tw := 0.35 + 0.65 * absf(sin(t * (0.6 + (i % 5) * 0.3) + i))
		ci.draw_circle(Vector2(sx, sy), 0.8 + (i % 3) * 0.5, Color(1, 0.97, 0.88, 0.5 * tw))
	# Great lantern moon
	var mp := Vector2(size.x * moon_x - scroll * 0.03, size.y * 0.16)
	for k in 6:
		ci.draw_circle(mp, 70.0 - k * 9.0, Color(accent.lerp(Palette.GOLD, 0.6), 0.03 + k * 0.012))
	ci.draw_circle(mp, 22, Color("fff1c8", 0.85))
	# Mountain layers (far to near)
	for layer in 3:
		var base := hy - 6.0 + layer * 10.0
		var amp := 90.0 - layer * 22.0
		var col := Palette.BG.lerp(accent, 0.18 - layer * 0.05).darkened(0.15 + layer * 0.2)
		var pts := PackedVector2Array([Vector2(0, size.y)])
		var step := 24.0
		var x := 0.0
		var par := scroll * (0.15 + layer * 0.2)
		while x <= size.x + step:
			var n := _noise(x + par, float(layer) + 1.0)
			pts.append(Vector2(x, base - amp * (0.55 + 0.45 * n)))
			x += step
		pts.append(Vector2(size.x, size.y))
		ci.draw_colored_polygon(pts, col)
		# distant windows / lights on the far layer
		if layer == 1:
			for i in 9:
				var lx := fmod(i * 151.0 + 40.0 - par, size.x)
				var ly := base - amp * (0.55 + 0.45 * _noise(lx + par, 2.0)) + 14.0
				ci.draw_circle(Vector2(lx, ly), 2.0, Color(Palette.GOLD, 0.35 + 0.25 * sin(t * 2.0 + i)))
	# Fog band
	for i in 5:
		var fy := hy - 10.0 + i * 9.0
		ci.draw_rect(Rect2(0, fy, size.x, 10), Color(accent.lerp(Color.WHITE, 0.3), 0.025))
	# Ground
	gradient_rect(ci, Rect2(0, hy, size.x, size.y - hy), Palette.BG_2.lerp(accent, 0.08), Palette.BG.darkened(0.3))
	ci.draw_line(Vector2(0, hy), Vector2(size.x, hy), Color(accent, 0.3), 2.0)
	# Perspective floor lines
	var vp := Vector2(size.x * 0.5, hy - 40.0)
	for i in 15:
		var gx := (i - 7) * size.x * 0.16 + size.x * 0.5
		var a := vp.lerp(Vector2(gx, size.y), (hy - vp.y + 2.0) / (size.y - vp.y))
		ci.draw_line(a, Vector2(gx, size.y), Color(accent, 0.05), 1.0)
	for i in 6:
		var u := pow(float(i + 1) / 6.0, 1.8)
		var ly2 := hy + (size.y - hy) * u
		ci.draw_line(Vector2(0, ly2), Vector2(size.x, ly2), Color(accent, 0.035 + u * 0.03), 1.0)
	# Hanging lanterns
	if lanterns:
		for i in 4:
			var lx2 := size.x * (0.08 + i * 0.29) + 30.0 * (i % 2)
			var llen := 60.0 + (i % 3) * 30.0
			var swing := sin(t * 1.1 + i * 1.7) * 0.06
			var top := Vector2(lx2, 0)
			var lp := top + Vector2(sin(swing) * llen, cos(swing) * llen)
			ci.draw_line(top, lp, Color(Palette.LINE, 0.8), 1.5, true)
			lantern(ci, lp, 11.0, Palette.GOLD, t + i)
	# Embers
	for i in 22:
		var ex := fmod(i * 127.0 + sin(t * 0.7 + i) * 20.0 - scroll * 0.3, size.x)
		var ey := size.y - fmod(i * 61.0 + t * (14.0 + (i % 6) * 5.0), size.y)
		ci.draw_circle(Vector2(ex, ey), 1.2 + (i % 3) * 0.7, Color(Palette.GOLD.lerp(accent, 0.3), 0.18 + 0.12 * sin(t * 3.0 + i)))


static func lantern(ci: CanvasItem, p: Vector2, r: float, col: Color, t: float) -> void:
	var flick := 0.85 + 0.15 * sin(t * 7.0)
	for k in 5:
		ci.draw_circle(p + Vector2(0, r * 0.4), r * (3.4 - k * 0.55) * flick, Color(col, 0.035 + k * 0.02))
	var body := PackedVector2Array([p + Vector2(-r * 0.7, -r * 0.3), p + Vector2(r * 0.7, -r * 0.3), p + Vector2(r * 0.9, r * 0.9), p + Vector2(-r * 0.9, r * 0.9)])
	IconDraw.fill(ci, body, Color("ffd98a"), 1.5, true)
	ci.draw_rect(Rect2(p + Vector2(-r * 0.8, -r * 0.55), Vector2(r * 1.6, r * 0.3)), Color("3a3142"))
	ci.draw_rect(Rect2(p + Vector2(-r, r * 0.85), Vector2(r * 2, r * 0.3)), Color("3a3142"))
	ci.draw_circle(p + Vector2(0, r * 0.35), r * 0.3 * flick, Color("fff6d8"))
