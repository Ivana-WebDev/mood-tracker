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
	# Moon craters + soft light shafts falling across the sky.
	ci.draw_circle(mp + Vector2(-7, -5), 5.0, Color("e6d3a3", 0.55))
	ci.draw_circle(mp + Vector2(6, 6), 3.5, Color("e6d3a3", 0.5))
	ci.draw_circle(mp + Vector2(8, -8), 2.2, Color("e6d3a3", 0.45))
	for k in 4:
		var sway := sin(t * 0.25 + k * 1.7) * 0.06
		var ang := PI * 0.5 + (k - 1.5) * 0.22 + sway
		var d1 := Vector2(cos(ang - 0.05), sin(ang - 0.05))
		var d2 := Vector2(cos(ang + 0.05), sin(ang + 0.05))
		var ln := hy * 1.1
		ci.draw_polygon(PackedVector2Array([mp + d1 * 24.0, mp + d1 * ln, mp + d2 * ln, mp + d2 * 24.0]),
			PackedColorArray([Color(accent.lerp(Palette.GOLD, 0.6), 0.05), Color(accent, 0.0), Color(accent, 0.0), Color(accent.lerp(Palette.GOLD, 0.6), 0.05)]))
	# Drifting clouds.
	for i in 5:
		var cw := 160.0 + (i % 3) * 70.0
		var cx := fmod(i * 331.0 + t * (4.0 + i * 1.5) - scroll * 0.06, size.x + cw * 2.0) - cw
		var cy := hy * (0.12 + 0.13 * i)
		cloud(ci, Vector2(cx, cy), cw, Color(accent.lerp(Color("c8cde8"), 0.5), 0.045 + (i % 2) * 0.02))
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
		if layer == 2:
			_ridge_props(ci, size, base, amp, par, col, accent, t)
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
	# Fireflies drifting above the ground.
	for i in 14:
		var fx := fmod(i * 173.0 + sin(t * 0.4 + i * 2.1) * 60.0 - scroll * 0.4, size.x)
		var fy := hy - 30.0 + fmod(i * 47.0, maxf(40.0, (size.y - hy) * 0.8)) + sin(t * 0.9 + i) * 14.0
		var blink := maxf(0.0, sin(t * (1.3 + (i % 4) * 0.4) + i * 1.9))
		if blink > 0.05:
			ci.draw_circle(Vector2(fx, fy), 7.0, Color(Color("d8ff8a").lerp(accent, 0.25), 0.06 * blink))
			ci.draw_circle(Vector2(fx, fy), 1.8, Color(Color("f2ffc8"), 0.85 * blink))
	# Embers
	for i in 22:
		var ex := fmod(i * 127.0 + sin(t * 0.7 + i) * 20.0 - scroll * 0.3, size.x)
		var ey := size.y - fmod(i * 61.0 + t * (14.0 + (i % 6) * 5.0), size.y)
		ci.draw_circle(Vector2(ex, ey), 1.2 + (i % 3) * 0.7, Color(Palette.GOLD.lerp(accent, 0.3), 0.18 + 0.12 * sin(t * 3.0 + i)))

	vignette(ci, size)


## Darkens the screen edges for a cinematic frame.
static func vignette(ci: CanvasItem, size: Vector2) -> void:
	var k := Color(0, 0, 0, 0.42)
	var z := Color(0, 0, 0, 0.0)
	var e := minf(size.x, size.y) * 0.22
	ci.draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0), Vector2(size.x, e * 0.6), Vector2(0, e * 0.6)]), PackedColorArray([k, k, z, z]))
	ci.draw_polygon(PackedVector2Array([Vector2(0, size.y - e), Vector2(size.x, size.y - e), Vector2(size.x, size.y), Vector2(0, size.y)]), PackedColorArray([z, z, k, k]))
	ci.draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(e, 0), Vector2(e, size.y), Vector2(0, size.y)]), PackedColorArray([k, z, z, k]))
	ci.draw_polygon(PackedVector2Array([Vector2(size.x - e, 0), Vector2(size.x, 0), Vector2(size.x, size.y), Vector2(size.x - e, size.y)]), PackedColorArray([z, k, k, z]))


static func cloud(ci: CanvasItem, p: Vector2, w: float, col: Color) -> void:
	for j in 5:
		var u := float(j) / 4.0
		var r := w * (0.16 + 0.1 * sin(u * PI))
		ci.draw_colored_polygon(IconDraw.ellipse_pts(p + Vector2((u - 0.5) * w * 0.8, -sin(u * PI) * w * 0.06), r * 1.3, r * 0.5, 18), col)


## Silhouettes along the nearest ridge: pines and bare trees in Act 1, ruined spires and crystals in Act 2.
static func _ridge_props(ci: CanvasItem, size: Vector2, base: float, amp: float, par: float, col: Color, accent: Color, t: float) -> void:
	var act := 1
	if GameManager.run.size() > 0:
		act = int(GameManager.run.get("act", 1))
	var dark := col.darkened(0.25)
	var x := -fmod(par, 90.0)
	var idx := int(floor(par / 90.0))
	while x < size.x + 90.0:
		var h := absi((idx * 7919) % 97)
		if h % 3 != 0:
			var gx := x + float(h % 40)
			var gy := base - amp * (0.55 + 0.45 * _noise(gx + par, 3.0)) + 4.0
			var ht := 26.0 + float(h % 30)
			if act == 1:
				if h % 2 == 0:
					for k in 3:
						var w := ht * (0.32 - k * 0.07)
						var yy := gy - ht * (0.25 + k * 0.25)
						ci.draw_colored_polygon(PackedVector2Array([Vector2(gx - w, yy + ht * 0.3), Vector2(gx, yy - ht * 0.22), Vector2(gx + w, yy + ht * 0.3)]), dark)
					ci.draw_line(Vector2(gx, gy + 4), Vector2(gx, gy - ht * 0.2), dark, 3.0)
				else:
					ci.draw_line(Vector2(gx, gy + 4), Vector2(gx + 2, gy - ht), dark, 3.0, true)
					for k in 4:
						var by := gy - ht * (0.35 + k * 0.15)
						var sg := 1.0 if k % 2 == 0 else -1.0
						ci.draw_line(Vector2(gx + 1, by), Vector2(gx + sg * ht * 0.3, by - ht * 0.18), dark, 1.6, true)
			else:
				if h % 2 == 0:
					var tw := 7.0 + float(h % 5)
					ci.draw_colored_polygon(PackedVector2Array([Vector2(gx - tw, gy + 4), Vector2(gx - tw * 0.8, gy - ht * 1.3), Vector2(gx, gy - ht * 1.75),
						Vector2(gx + tw * 0.8, gy - ht * 1.3), Vector2(gx + tw, gy + 4)]), dark)
					ci.draw_circle(Vector2(gx, gy - ht), 1.6, Color(Palette.GOLD, 0.4 + 0.3 * sin(t * 1.5 + h)))
				else:
					for k in 3:
						var a := -0.5 + k * 0.5
						var cl := ht * (0.6 + 0.25 * (1 - absi(k - 1)))
						var tip := Vector2(gx, gy) + Vector2(sin(a), -cos(a)) * cl
						var nrm := Vector2(cos(a), sin(a)) * 5.0
						ci.draw_colored_polygon(PackedVector2Array([Vector2(gx, gy + 3) - nrm, tip, Vector2(gx, gy + 3) + nrm]), Color(accent.lerp(Color("7ee8ff"), 0.5).darkened(0.35), 0.75))
					ci.draw_circle(Vector2(gx, gy - ht * 0.3), ht * 0.5, Color(Color("7ee8ff"), 0.04))
		x += 90.0
		idx += 1


static func lantern(ci: CanvasItem, p: Vector2, r: float, col: Color, t: float) -> void:
	var flick := 0.85 + 0.15 * sin(t * 7.0)
	for k in 5:
		ci.draw_circle(p + Vector2(0, r * 0.4), r * (3.4 - k * 0.55) * flick, Color(col, 0.035 + k * 0.02))
	var body := PackedVector2Array([p + Vector2(-r * 0.7, -r * 0.3), p + Vector2(r * 0.7, -r * 0.3), p + Vector2(r * 0.9, r * 0.9), p + Vector2(-r * 0.9, r * 0.9)])
	IconDraw.fill(ci, body, Color("ffd98a"), 1.5, true)
	ci.draw_rect(Rect2(p + Vector2(-r * 0.8, -r * 0.55), Vector2(r * 1.6, r * 0.3)), Color("3a3142"))
	ci.draw_rect(Rect2(p + Vector2(-r, r * 0.85), Vector2(r * 2, r * 0.3)), Color("3a3142"))
	ci.draw_circle(p + Vector2(0, r * 0.35), r * 0.3 * flick, Color("fff6d8"))
