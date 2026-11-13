class_name IconDraw
## Procedural vector icons + creature portraits (no texture assets required).

static func poly(ci: CanvasItem, pts: Array, c: Vector2, s: float, color: Color) -> void:
	var out := PackedVector2Array()
	for p in pts:
		out.append(c + Vector2(p[0], p[1]) * s)
	ci.draw_colored_polygon(out, color)


static func line(ci: CanvasItem, a: Array, b: Array, c: Vector2, s: float, color: Color, w: float) -> void:
	ci.draw_line(c + Vector2(a[0], a[1]) * s, c + Vector2(b[0], b[1]) * s, color, maxf(1.0, w * s), true)


## Draws an icon of "kind" centred at c, with half-size s.
static func icon(ci: CanvasItem, kind: String, c: Vector2, s: float, color: Color) -> void:
	match kind:
		"attack", "sword", "blade", "monster":
			poly(ci, [[-0.12, 0.35], [0.12, 0.35], [0.12, -0.75], [0.0, -0.95], [-0.12, -0.75]], c, s, color)
			poly(ci, [[-0.45, 0.35], [0.45, 0.35], [0.45, 0.5], [-0.45, 0.5]], c, s, color)
			poly(ci, [[-0.09, 0.5], [0.09, 0.5], [0.09, 0.9], [-0.09, 0.9]], c, s, color.darkened(0.3))
		"skill", "shield", "defend":
			poly(ci, [[-0.7, -0.7], [0.7, -0.7], [0.7, 0.0], [0.0, 0.85], [-0.7, 0.0]], c, s, color)
			poly(ci, [[-0.45, -0.48], [0.45, -0.48], [0.45, -0.02], [0.0, 0.55], [-0.45, -0.02]], c, s, color.darkened(0.35))
		"power", "star":
			var pts: Array = []
			for i in 10:
				var r := 0.9 if i % 2 == 0 else 0.4
				var a := -PI / 2 + i * PI / 5
				pts.append([cos(a) * r, sin(a) * r])
			poly(ci, pts, c, s, color)
		"heart":
			ci.draw_circle(c + Vector2(-0.33, -0.2) * s, 0.4 * s, color)
			ci.draw_circle(c + Vector2(0.33, -0.2) * s, 0.4 * s, color)
			poly(ci, [[-0.72, -0.05], [0.72, -0.05], [0.0, 0.8]], c, s, color)
		"coin", "gold":
			ci.draw_circle(c, 0.8 * s, color)
			ci.draw_circle(c, 0.55 * s, color.darkened(0.25))
			poly(ci, [[-0.12, -0.35], [0.12, -0.35], [0.12, 0.35], [-0.12, 0.35]], c, s, color)
		"bolt", "energy":
			poly(ci, [[0.2, -0.95], [-0.5, 0.1], [-0.05, 0.1], [-0.25, 0.95], [0.5, -0.15], [0.05, -0.15]], c, s, color)
		"orb":
			ci.draw_circle(c, 0.8 * s, color.darkened(0.3))
			ci.draw_circle(c, 0.55 * s, color)
			ci.draw_circle(c + Vector2(-0.2, -0.2) * s, 0.18 * s, Color(1, 1, 1, 0.7))
		"cloud":
			ci.draw_circle(c + Vector2(-0.35, 0.1) * s, 0.4 * s, color)
			ci.draw_circle(c + Vector2(0.1, -0.15) * s, 0.5 * s, color)
			ci.draw_circle(c + Vector2(0.45, 0.15) * s, 0.35 * s, color)
			poly(ci, [[-0.75, 0.15], [0.8, 0.15], [0.8, 0.5], [-0.75, 0.5]], c, s, color)
		"leaf":
			poly(ci, [[0.0, -0.9], [0.55, -0.3], [0.45, 0.35], [0.0, 0.8], [-0.45, 0.35], [-0.55, -0.3]], c, s, color)
			line(ci, [0, -0.6], [0, 0.95], c, s, color.darkened(0.45), 0.1)
		"ring":
			ci.draw_arc(c, 0.6 * s, 0, TAU, 32, color, maxf(2.0, 0.22 * s), true)
			ci.draw_circle(c + Vector2(0, -0.6) * s, 0.25 * s, color.lightened(0.3))
		"drum":
			poly(ci, [[-0.65, -0.4], [0.65, -0.4], [0.55, 0.6], [-0.55, 0.6]], c, s, color)
			line(ci, [-0.65, -0.4], [0.55, 0.6], c, s, color.darkened(0.4), 0.08)
			line(ci, [0.65, -0.4], [-0.55, 0.6], c, s, color.darkened(0.4), 0.08)
			line(ci, [-0.3, -0.95], [0.1, -0.45], c, s, color.lightened(0.3), 0.1)
		"feather":
			poly(ci, [[0.55, -0.9], [0.3, 0.1], [-0.5, 0.8], [-0.2, -0.1]], c, s, color)
			line(ci, [0.5, -0.8], [-0.6, 0.9], c, s, color.darkened(0.45), 0.08)
		"flag":
			line(ci, [-0.55, -0.9], [-0.55, 0.9], c, s, color.darkened(0.3), 0.12)
			poly(ci, [[-0.5, -0.85], [0.7, -0.6], [-0.5, -0.1]], c, s, color)
		"crown", "boss":
			poly(ci, [[-0.8, 0.5], [-0.8, -0.5], [-0.4, -0.05], [0.0, -0.75], [0.4, -0.05], [0.8, -0.5], [0.8, 0.5]], c, s, color)
			poly(ci, [[-0.8, 0.55], [0.8, 0.55], [0.8, 0.75], [-0.8, 0.75]], c, s, color.darkened(0.25))
		"elite":
			poly(ci, [[-0.6, 0.6], [-0.85, -0.85], [-0.2, -0.25], [0.2, -0.25], [0.85, -0.85], [0.6, 0.6]], c, s, color)
			ci.draw_circle(c + Vector2(-0.25, 0.15) * s, 0.12 * s, Palette.BG)
			ci.draw_circle(c + Vector2(0.25, 0.15) * s, 0.12 * s, Palette.BG)
		"rest", "fire":
			poly(ci, [[0.0, -0.95], [0.5, -0.1], [0.4, 0.5], [0.0, 0.7], [-0.4, 0.5], [-0.5, -0.1]], c, s, color)
			poly(ci, [[0.0, -0.3], [0.25, 0.2], [0.0, 0.55], [-0.25, 0.2]], c, s, color.lightened(0.5))
			line(ci, [-0.7, 0.85], [0.7, 0.65], c, s, color.darkened(0.4), 0.14)
			line(ci, [-0.7, 0.65], [0.7, 0.85], c, s, color.darkened(0.4), 0.14)
		"shop", "bag":
			poly(ci, [[-0.6, -0.35], [0.6, -0.35], [0.75, 0.85], [-0.75, 0.85]], c, s, color)
			ci.draw_arc(c + Vector2(0, -0.35) * s, 0.32 * s, PI, TAU, 16, color.lightened(0.2), maxf(2.0, 0.12 * s), true)
			ci.draw_circle(c + Vector2(0, 0.3) * s, 0.18 * s, color.darkened(0.4))
		"event", "question":
			ci.draw_arc(c + Vector2(0, -0.3) * s, 0.4 * s, PI * 1.05, PI * 2.3, 20, color, maxf(2.0, 0.2 * s), true)
			line(ci, [0.12, 0.05], [0.0, 0.35], c, s, color, 0.2)
			ci.draw_circle(c + Vector2(0, 0.72) * s, 0.13 * s, color)
		"treasure", "chest":
			poly(ci, [[-0.8, -0.2], [0.8, -0.2], [0.8, 0.7], [-0.8, 0.7]], c, s, color.darkened(0.15))
			poly(ci, [[-0.8, -0.25], [-0.6, -0.7], [0.6, -0.7], [0.8, -0.25]], c, s, color)
			poly(ci, [[-0.15, -0.3], [0.15, -0.3], [0.15, 0.15], [-0.15, 0.15]], c, s, Palette.BG)
		"buff", "up":
			poly(ci, [[0.0, -0.85], [0.7, 0.0], [0.25, 0.0], [0.25, 0.8], [-0.25, 0.8], [-0.25, 0.0], [-0.7, 0.0]], c, s, color)
		"debuff", "down":
			ci.draw_arc(c, 0.65 * s, 0, PI * 1.6, 24, color, maxf(2.0, 0.18 * s), true)
			ci.draw_arc(c, 0.3 * s, PI, PI * 2.6, 16, color, maxf(2.0, 0.16 * s), true)
		"deck":
			poly(ci, [[-0.6, -0.8], [0.4, -0.8], [0.4, 0.6], [-0.6, 0.6]], c, s, color.darkened(0.3))
			poly(ci, [[-0.4, -0.6], [0.6, -0.6], [0.6, 0.8], [-0.4, 0.8]], c, s, color)
		"menu":
			for y in [-0.5, 0.0, 0.5]:
				line(ci, [-0.65, y], [0.65, y], c, s, color, 0.16)
		"gear":
			gear(ci, c, s * 0.85, s * 0.62, 8, color, 0.0)
			ci.draw_circle(c, s * 0.25, Palette.BG)
		"die":
			die(ci, c, s * 0.85, 5, color, 0.0)
		"bell":
			poly(ci, [[-0.6, 0.45], [-0.45, -0.3], [-0.2, -0.7], [0.2, -0.7], [0.45, -0.3], [0.6, 0.45]], c, s, color)
			poly(ci, [[-0.75, 0.45], [0.75, 0.45], [0.75, 0.6], [-0.75, 0.6]], c, s, color.darkened(0.2))
			ci.draw_circle(c + Vector2(0, 0.72) * s, 0.16 * s, color.lightened(0.3))
		"ribbon", "flow":
			var pts := PackedVector2Array()
			for i in 24:
				var u := float(i) / 23.0
				pts.append(c + Vector2(-0.85 + u * 1.7, sin(u * TAU * 1.2) * 0.45) * s)
			ci.draw_polyline(pts, color, maxf(2.0, 0.22 * s), true)
		"turret":
			poly(ci, [[-0.6, 0.8], [0.6, 0.8], [0.4, 0.2], [-0.4, 0.2]], c, s, color.darkened(0.3))
			ci.draw_circle(c + Vector2(0, 0.05) * s, 0.42 * s, color)
			poly(ci, [[0.1, -0.15], [0.95, -0.35], [0.95, -0.05], [0.1, 0.15]], c, s, color.lightened(0.2))
		"cannon":
			ci.draw_circle(c + Vector2(-0.35, 0.45) * s, 0.35 * s, color.darkened(0.35))
			poly(ci, [[-0.6, 0.0], [0.9, -0.55], [1.0, -0.2], [-0.5, 0.4]], c, s, color)
			ci.draw_circle(c + Vector2(-0.35, 0.45) * s, 0.14 * s, color.lightened(0.3))
		"potion":
			potion(ci, c, s, color)
		"map":
			poly(ci, [[-0.85, -0.6], [-0.3, -0.8], [0.3, -0.6], [0.85, -0.8], [0.85, 0.6], [0.3, 0.8], [-0.3, 0.6], [-0.85, 0.8]], c, s, color)
			line(ci, [-0.3, -0.8], [-0.3, 0.6], c, s, color.darkened(0.45), 0.08)
			line(ci, [0.3, -0.6], [0.3, 0.8], c, s, color.darkened(0.45), 0.08)
			ci.draw_circle(c + Vector2(0.55, -0.1) * s, 0.14 * s, Palette.BAD)
		"cards":
			for i in 3:
				var off := Vector2((i - 1) * 0.32, absf(i - 1) * 0.08) * s
				var col := color.darkened(0.15 * (2 - i))
				poly(ci, [[-0.32, -0.6], [0.32, -0.6], [0.32, 0.6], [-0.32, 0.6]], c + off, s, col)
		_:
			ci.draw_circle(c, 0.6 * s, color)


## A round-bottomed flask with coloured liquid, cork and highlight. s = half height.
static func potion(ci: CanvasItem, c: Vector2, s: float, liquid: Color) -> void:
	var glass := Color(0.85, 0.9, 1.0, 0.28)
	var body_c := c + Vector2(0, 0.28) * s
	var r := 0.6 * s
	ci.draw_circle(body_c, r + 2.0, Color(0.03, 0.035, 0.06, 0.92))
	ci.draw_rect(Rect2(c + Vector2(-0.24, -0.72) * s - Vector2(2, 0), Vector2(0.48 * s + 4, 0.6 * s)), Color(0.03, 0.035, 0.06, 0.92))
	ci.draw_circle(body_c, r, glass)
	ci.draw_rect(Rect2(c + Vector2(-0.22, -0.72) * s, Vector2(0.44 * s, 0.62 * s)), glass)
	# liquid: lower part of the bulb
	var liq := PackedVector2Array()
	for i in 17:
		var a := -0.25 + i * (PI + 0.5) / 16.0
		liq.append(body_c + Vector2(cos(a), sin(a)) * r * 0.9)
	ci.draw_colored_polygon(liq, liquid)
	ci.draw_line(liq[0], liq[liq.size() - 1], liquid.lightened(0.4), maxf(1.0, s * 0.06))
	ci.draw_circle(body_c + Vector2(0.15, 0.25) * s, 0.08 * s, Color(1, 1, 1, 0.35))
	# cork + highlight
	ci.draw_rect(Rect2(c + Vector2(-0.2, -0.95) * s, Vector2(0.4 * s, 0.26 * s)), Color("a07850"))
	ci.draw_line(body_c + Vector2(-0.35, -0.25) * s, body_c + Vector2(-0.3, 0.15) * s, Color(1, 1, 1, 0.55), maxf(1.0, s * 0.08), true)


# ====================================================================== shaded shape kit

const OUTLINE := Color(0.03, 0.035, 0.06, 0.92)


static func pts_of(arr: Array, c: Vector2, s: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in arr:
		out.append(c + Vector2(p[0], p[1]) * s)
	return out


static func ellipse_pts(center: Vector2, rx: float, ry: float, n: int = 28, rot: float = 0.0) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in n:
		var a := i * TAU / n
		out.append(center + Vector2(cos(a) * rx, sin(a) * ry).rotated(rot))
	return out


static func _bounds(poly: PackedVector2Array) -> Rect2:
	var r := Rect2(poly[0], Vector2.ZERO)
	for p in poly:
		r = r.expand(p)
	return r


## Fills a polygon with cel shading (shadow on the right, rim light on the left) and an outline.
## Animated outlines (flapping wings, swaying skirts) can momentarily cross themselves;
## the renderer can't fill those, so fall back to the convex hull for that frame.
static func safe(poly: PackedVector2Array) -> PackedVector2Array:
	if poly.size() >= 3 and Geometry2D.triangulate_polygon(poly).is_empty():
		var hull := Geometry2D.convex_hull(poly)
		if hull.size() > 1 and hull[0] == hull[hull.size() - 1]:
			hull.remove_at(hull.size() - 1)
		return hull
	return poly


## Shoelace area; clipping can leave sub-pixel slivers that the renderer can't triangulate.
static func _area(p: PackedVector2Array) -> float:
	var a := 0.0
	for i in p.size():
		var j := (i + 1) % p.size()
		a += p[i].x * p[j].y - p[j].x * p[i].y
	return absf(a) * 0.5


static func fill(ci: CanvasItem, poly: PackedVector2Array, col: Color, ow: float = 2.0, shade: bool = true) -> void:
	if poly.size() < 3:
		return
	poly = safe(poly)
	if poly.size() < 3:
		return
	ci.draw_colored_polygon(poly, col)
	if shade:
		var r := _bounds(poly)
		var cut := PackedVector2Array([
			Vector2(r.position.x + r.size.x * 0.62, r.position.y - 4), Vector2(r.end.x + 4, r.position.y - 4),
			Vector2(r.end.x + 4, r.end.y + 4), Vector2(r.position.x + r.size.x * 0.42, r.end.y + 4)])
		for q in Geometry2D.intersect_polygons(poly, cut):
			if _area(q) > 1.0:
				ci.draw_colored_polygon(q, col.darkened(0.24))
		var hl := PackedVector2Array([
			Vector2(r.position.x - 4, r.position.y - 4), Vector2(r.position.x + r.size.x * 0.2, r.position.y - 4),
			Vector2(r.position.x + r.size.x * 0.1, r.end.y + 4), Vector2(r.position.x - 4, r.end.y + 4)])
		for q in Geometry2D.intersect_polygons(poly, hl):
			if _area(q) > 1.0:
				ci.draw_colored_polygon(q, col.lightened(0.16))
	if ow > 0.0:
		var closed := poly.duplicate()
		closed.append(poly[0])
		ci.draw_polyline(closed, OUTLINE, ow, true)


static func shape(ci: CanvasItem, arr: Array, c: Vector2, s: float, col: Color, shade: bool = true) -> void:
	fill(ci, pts_of(arr, c, s), col, maxf(1.5, s * 0.035), shade)


static func ball(ci: CanvasItem, p: Vector2, r: float, col: Color, ow: float = 2.0) -> void:
	fill(ci, ellipse_pts(p, r, r, maxi(12, int(r))), col, ow, true)
	ci.draw_circle(p + Vector2(-r * 0.35, -r * 0.4), r * 0.22, Color(1, 1, 1, 0.28))


static func oval(ci: CanvasItem, p: Vector2, rx: float, ry: float, col: Color, ow: float = 2.0, rot: float = 0.0) -> void:
	fill(ci, ellipse_pts(p, rx, ry, 28, rot), col, ow, true)


static func eye(ci: CanvasItem, p: Vector2, r: float, look: Vector2 = Vector2.ZERO, iris: Color = Color("1b1f2e")) -> void:
	ci.draw_circle(p, r + 1.5, OUTLINE)
	ci.draw_circle(p, r, Color("fff8ea"))
	ci.draw_circle(p + look * r * 0.35, r * 0.55, iris)
	ci.draw_circle(p + look * r * 0.35 + Vector2(-r * 0.2, -r * 0.2), r * 0.18, Color.WHITE)


static func glow(ci: CanvasItem, p: Vector2, r: float, col: Color, layers: int = 5) -> void:
	for i in layers:
		ci.draw_circle(p, r * (1.0 - i / float(layers)), Color(col, 0.07 + i * 0.03))


static func gear(ci: CanvasItem, c: Vector2, r_out: float, r_in: float, teeth: int, col: Color, rot: float) -> void:
	var pts := PackedVector2Array()
	for i in teeth * 4:
		var a := rot + i * TAU / (teeth * 4)
		var r := r_out if (i % 4 == 1 or i % 4 == 2) else r_in
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	fill(ci, pts, col, maxf(1.5, r_out * 0.06), true)
	ci.draw_circle(c, r_in * 0.45, col.darkened(0.45))
	ci.draw_circle(c, r_in * 0.2, col.lightened(0.2))


## A d6 seen face-on with pips.
static func die(ci: CanvasItem, c: Vector2, half: float, value: int, col: Color, rot: float) -> void:
	var reordered := PackedVector2Array([c + Vector2(-0.78, -1).rotated(rot) * half, c + Vector2(0.78, -1).rotated(rot) * half,
		c + Vector2(1, -0.78).rotated(rot) * half, c + Vector2(1, 0.78).rotated(rot) * half,
		c + Vector2(0.78, 1).rotated(rot) * half, c + Vector2(-0.78, 1).rotated(rot) * half,
		c + Vector2(-1, 0.78).rotated(rot) * half, c + Vector2(-1, -0.78).rotated(rot) * half])
	fill(ci, reordered, col, maxf(1.5, half * 0.1), true)
	var pip := Palette.BG
	var spots := {
		1: [Vector2(0, 0)], 2: [Vector2(-0.5, -0.5), Vector2(0.5, 0.5)],
		3: [Vector2(-0.5, -0.5), Vector2(0, 0), Vector2(0.5, 0.5)],
		4: [Vector2(-0.5, -0.5), Vector2(0.5, -0.5), Vector2(-0.5, 0.5), Vector2(0.5, 0.5)],
		5: [Vector2(-0.5, -0.5), Vector2(0.5, -0.5), Vector2(0, 0), Vector2(-0.5, 0.5), Vector2(0.5, 0.5)],
		6: [Vector2(-0.5, -0.55), Vector2(0.5, -0.55), Vector2(-0.5, 0), Vector2(0.5, 0), Vector2(-0.5, 0.55), Vector2(0.5, 0.55)],
	}
	if value >= 1 and value <= 6:
		for sp in spots[value]:
			ci.draw_circle(c + (sp as Vector2).rotated(rot) * half, half * 0.16, pip)
	elif value > 6:
		ci.draw_string(UI.font(), c + Vector2(-half, half * 0.4), str(value), HORIZONTAL_ALIGNMENT_CENTER, half * 2, int(half * 1.2), pip)


static func ribbon(ci: CanvasItem, from: Vector2, dir: Vector2, length: float, width: float, col: Color, t: float, waves: float = 1.5) -> void:
	var n := 22
	var normal := Vector2(-dir.y, dir.x)
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	for i in n:
		var u := float(i) / (n - 1)
		var p := from + dir * length * u + normal * sin(u * TAU * waves - t * 4.0) * length * 0.16 * u
		var w := width * (1.0 - u * 0.7)
		left.append(p + normal * w * 0.5)
		right.append(p - normal * w * 0.5)
	right.reverse()
	var poly := left + right
	if Geometry2D.triangulate_polygon(poly).is_empty():
		ci.draw_polyline(left, col, maxf(1.5, width * 0.6), true)
	else:
		ci.draw_colored_polygon(poly, col)
	ci.draw_polyline(left, col.lightened(0.35), maxf(1.0, width * 0.18), true)


# ====================================================================== creatures

## Draws a hero or monster. c = body centre, feet near c.y + s. facing: 1 = right, -1 = left.
static func creature(ci: CanvasItem, kind: String, c: Vector2, s: float, color: Color, t: float, facing: float = -1.0) -> void:
	var bob := sin(t * 2.2) * 0.035 * s
	# ground shadow
	ci.draw_colored_polygon(ellipse_pts(c + Vector2(0, s * 1.0), s * 0.78, s * 0.13), Color(0, 0, 0, 0.38))
	var cc := c + Vector2(0, bob)
	match kind:
		"clockwright": _clockwright(ci, cc, s, color, t)
		"fatebinder": _fatebinder(ci, cc, s, color, t)
		"duskdancer": _duskdancer(ci, cc, s, color, t)
		"blob": _blob(ci, cc, s, color, t, facing)
		"wisp": _wisp(ci, cc, s, color, t)
		"knight": _knight(ci, cc, s, color, t, facing)
		"golem": _golem(ci, cc, s, color, t)
		"spike": _sprout(ci, cc, s, color, t)
		"eye": _eye_priest(ci, cc, s, color, t, facing)
		"crown": _hollow_king(ci, cc, s, color, t)
		"dragon": _wyrm(ci, cc, s, color, t)
		_:
			if EnemyArt.has(kind):
				EnemyArt.draw(ci, kind, cc, s, color, t, facing)
			else:
				ball(ci, cc, s * 0.7, color)


static func _clockwright(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float) -> void:
	var brass := col
	var coat := Color("5b4a3a")
	var skin := Color("e8c8a8")
	# Backpack gear + chimney
	gear(ci, c + Vector2(-0.42, -0.25) * s, s * 0.5, s * 0.38, 9, brass.darkened(0.1), t * 0.8)
	shape(ci, [[-0.75, -0.95], [-0.6, -0.95], [-0.6, -0.4], [-0.75, -0.4]], c, s, Color("6e6a73"))
	for i in 3:
		var ph := fmod(t * 0.6 + i / 3.0, 1.0)
		ci.draw_circle(c + Vector2(-0.68 - ph * 0.2, -1.0 - ph * 0.6) * s, s * (0.06 + ph * 0.1), Color(0.8, 0.8, 0.85, 0.35 * (1.0 - ph)))
	# Legs + boots
	shape(ci, [[-0.28, 0.35], [-0.06, 0.35], [-0.08, 0.9], [-0.3, 0.9]], c, s, Color("3b3340"))
	shape(ci, [[0.06, 0.35], [0.28, 0.35], [0.3, 0.9], [0.08, 0.9]], c, s, Color("3b3340"))
	shape(ci, [[-0.36, 0.86], [-0.04, 0.86], [-0.02, 1.0], [-0.4, 1.0]], c, s, Color("2a2230"))
	shape(ci, [[0.06, 0.86], [0.38, 0.86], [0.44, 1.0], [0.04, 1.0]], c, s, Color("2a2230"))
	# Coat + apron
	shape(ci, [[-0.38, -0.42], [0.38, -0.42], [0.46, 0.5], [-0.46, 0.5]], c, s, coat)
	shape(ci, [[-0.24, -0.15], [0.24, -0.15], [0.3, 0.48], [-0.3, 0.48]], c, s, Color("a07850"))
	shape(ci, [[-0.18, 0.12], [0.0, 0.12], [0.0, 0.3], [-0.18, 0.3]], c, s, Color("8a6440"))
	# Belt + buckle
	shape(ci, [[-0.42, 0.02], [0.42, 0.02], [0.43, 0.1], [-0.43, 0.1]], c, s, Color("2a2230"), false)
	shape(ci, [[-0.07, -0.01], [0.07, -0.01], [0.07, 0.13], [-0.07, 0.13]], c, s, brass)
	# Arm + big wrench
	var swing := sin(t * 1.6) * 0.06
	var hand := c + Vector2(0.5, 0.05 + swing) * s
	shape(ci, [[0.3, -0.38], [0.46, -0.32], [0.56, 0.05 + swing], [0.42, 0.1 + swing]], c, s, coat.lightened(0.05))
	var w0 := hand + Vector2(-0.05, 0.25) * s
	var w1 := hand + Vector2(0.18, -0.75) * s
	ci.draw_line(w0, w1, OUTLINE, s * 0.14, true)
	ci.draw_line(w0, w1, Color("b9c0cc"), s * 0.09, true)
	var head := w1
	shape(ci, [[-0.16, -0.05], [0.16, -0.05], [0.2, -0.28], [0.08, -0.3], [0.06, -0.14], [-0.06, -0.14], [-0.08, -0.3], [-0.2, -0.28]], head, s, Color("c7ced9"))
	ball(ci, hand, s * 0.09, skin)
	# Head
	ball(ci, c + Vector2(0.02, -0.62) * s, s * 0.27, skin, maxf(1.5, s * 0.035))
	ci.draw_circle(c + Vector2(0.1, -0.5) * s, s * 0.035, Color("b07a62"))
	# Cap
	shape(ci, [[-0.3, -0.72], [-0.26, -0.92], [0.0, -1.0], [0.26, -0.92], [0.3, -0.72]], c, s, Color("4a3f52"))
	shape(ci, [[0.15, -0.76], [0.48, -0.74], [0.46, -0.68], [0.15, -0.68]], c, s, Color("3a3142"))
	# Goggles
	ci.draw_line(c + Vector2(-0.27, -0.68) * s, c + Vector2(0.28, -0.68) * s, OUTLINE, s * 0.07)
	for gx in [-0.1, 0.14]:
		var gp := c + Vector2(gx, -0.68) * s
		ball(ci, gp, s * 0.1, brass)
		ci.draw_circle(gp, s * 0.065, Color("6fe0e8"))
		ci.draw_circle(gp + Vector2(-0.02, -0.02) * s, s * 0.02, Color.WHITE)
	# Moustache
	shape(ci, [[-0.02, -0.5], [0.2, -0.52], [0.24, -0.46], [0.08, -0.44], [-0.04, -0.46]], c, s, Color("6b4a32"), false)
	# Hovering drone
	var dp := c + Vector2(0.75, -0.95 + sin(t * 3.0) * 0.06) * s
	ci.draw_line(dp + Vector2(-0.14, -0.12) * s, dp + Vector2(0.14, -0.12) * s, Color(0.9, 0.9, 1.0, 0.5 + 0.5 * sin(t * 30.0)), s * 0.03)
	ball(ci, dp, s * 0.1, brass.darkened(0.15))
	ci.draw_circle(dp + Vector2(0.03, 0) * s, s * 0.04, Color("ff6b6b"))


static func _fatebinder(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float) -> void:
	var robe := col.darkened(0.35)
	var trim := Color("f2c96b")
	# Robe with flared hem
	var sway := sin(t * 1.5) * 0.03
	shape(ci, [[-0.3, -0.45], [0.3, -0.45], [0.5 + sway, 0.75], [0.58 + sway, 1.0], [-0.58 + sway, 1.0], [-0.5 + sway, 0.75]], c, s, robe)
	ci.draw_polyline(pts_of([[-0.58 + sway, 0.93], [0.58 + sway, 0.93]], c, s), trim, s * 0.05)
	for i in 5:
		var sp := c + Vector2(-0.3 + i * 0.15, 0.2 + (i % 2) * 0.25) * s
		_star(ci, sp, s * 0.05, Color(trim, 0.85))
	# Sash
	shape(ci, [[-0.32, 0.0], [0.32, -0.1], [0.34, 0.02], [-0.3, 0.12]], c, s, col.lightened(0.1), false)
	# Shawl / collar
	shape(ci, [[-0.42, -0.42], [0.42, -0.42], [0.25, -0.12], [0.0, -0.02], [-0.25, -0.12]], c, s, col)
	# Hood + shadowed face
	var hood: Array = [[-0.34, -0.42]]
	for i in 13:
		var a := PI + i * PI / 12.0
		hood.append([cos(a) * 0.34, -0.72 + sin(a) * 0.38 - (0.08 if i == 7 else 0.0)])
	hood.append([0.34, -0.42])
	shape(ci, hood, c, s, col.darkened(0.1))
	ci.draw_colored_polygon(ellipse_pts(c + Vector2(0.04, -0.68) * s, s * 0.2, s * 0.22), Color("141020"))
	# Porcelain half-mask
	shape(ci, [[-0.1, -0.84], [0.2, -0.84], [0.22, -0.66], [0.06, -0.56], [-0.1, -0.64]], c, s, Color("f1ecf7"))
	ci.draw_circle(c + Vector2(0.1, -0.74) * s, s * 0.04, trim)
	ci.draw_circle(c + Vector2(0.1, -0.74) * s, s * 0.02, Color.WHITE)
	# Hands raised
	ball(ci, c + Vector2(-0.45, -0.2) * s, s * 0.08, Color("d8c0e8"))
	ball(ci, c + Vector2(0.48, -0.28) * s, s * 0.08, Color("d8c0e8"))
	# Orbiting dice
	for i in 3:
		var a := t * 1.2 + i * TAU / 3.0
		var dp := c + Vector2(cos(a) * 0.72, -0.35 + sin(a) * 0.22) * s
		die(ci, dp, s * 0.11, [6, 3, 5][i], Color("f5f1ff"), a * 0.6)
	# Floating card
	var cp := c + Vector2(0.62, -0.9 + sin(t * 2.0) * 0.05) * s
	shape(ci, [[-0.1, -0.15], [0.1, -0.15], [0.1, 0.15], [-0.1, 0.15]], cp, s, Color("2a2140"))
	_star(ci, cp, s * 0.05, trim)


static func _duskdancer(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float) -> void:
	var skin := Color("e9c9b4")
	var hair := Color("2b2a4a")
	var dress := col.darkened(0.15)
	# Ribbons from both hands
	ribbon(ci, c + Vector2(-0.4, -0.35) * s, Vector2(-0.6, 0.8).normalized(), s * 1.2, s * 0.12, Color("ff8fb8"), t, 1.4)
	ribbon(ci, c + Vector2(0.45, -0.55) * s, Vector2(0.7, -0.3).normalized(), s * 1.1, s * 0.12, Color(col.lightened(0.3)), t + 1.0, 1.6)
	# Legs (en pointe)
	shape(ci, [[-0.12, 0.4], [-0.02, 0.4], [-0.05, 0.98], [-0.12, 0.98]], c, s, skin)
	shape(ci, [[0.04, 0.4], [0.14, 0.4], [0.24, 0.92], [0.17, 0.95]], c, s, skin)
	# Skirt (swaying)
	var sw := sin(t * 2.0) * 0.06
	var sk: Array = [[-0.18, -0.05]]
	for i in 9:
		var u := float(i) / 8.0
		sk.append([lerpf(0.5, -0.5, u) + sw * sin(u * PI), 0.48 + sin(u * PI * 4.0 + t * 3.0) * 0.04])
	sk.insert(1, [0.18, -0.05])
	shape(ci, sk, c, s, dress)
	# Bodice
	shape(ci, [[-0.16, -0.48], [0.16, -0.48], [0.2, -0.02], [-0.2, -0.02]], c, s, col)
	ci.draw_line(c + Vector2(-0.18, -0.06) * s, c + Vector2(0.18, -0.06) * s, Color("f2c96b"), s * 0.03)
	# Arms
	ci.draw_line(c + Vector2(-0.14, -0.42) * s, c + Vector2(-0.4, -0.35) * s, OUTLINE, s * 0.09, true)
	ci.draw_line(c + Vector2(-0.14, -0.42) * s, c + Vector2(-0.4, -0.35) * s, skin, s * 0.06, true)
	ci.draw_line(c + Vector2(0.14, -0.44) * s, c + Vector2(0.45, -0.55) * s, OUTLINE, s * 0.09, true)
	ci.draw_line(c + Vector2(0.14, -0.44) * s, c + Vector2(0.45, -0.55) * s, skin, s * 0.06, true)
	# Head + long hair
	shape(ci, [[-0.2, -0.75], [0.16, -0.82], [0.2, -0.5], [0.1, -0.2], [-0.26, -0.25], [-0.28, -0.55]], c, s, hair)
	ball(ci, c + Vector2(0.0, -0.66) * s, s * 0.17, skin, maxf(1.5, s * 0.03))
	shape(ci, [[-0.18, -0.7], [-0.1, -0.84], [0.12, -0.86], [0.18, -0.74], [0.0, -0.76]], c, s, hair, false)
	ci.draw_circle(c + Vector2(0.07, -0.66) * s, s * 0.025, OUTLINE)
	ci.draw_circle(c + Vector2(0.07, -0.58) * s, s * 0.025, Color("e07a8a"))
	# Crescent moon headpiece
	var mp := c + Vector2(-0.02, -0.96) * s
	var moon := ellipse_pts(mp, s * 0.15, s * 0.15, 24)
	var bite := ellipse_pts(mp + Vector2(0.07, -0.04) * s, s * 0.13, s * 0.13, 24)
	for q in Geometry2D.clip_polygons(moon, bite):
		fill(ci, q, Color("f6e7a8"), maxf(1.0, s * 0.025), false)
	glow(ci, mp, s * 0.32, Color("f6e7a8"), 4)


static func _star(ci: CanvasItem, p: Vector2, r: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 8:
		var rr := r if i % 2 == 0 else r * 0.4
		var a := -PI / 2 + i * PI / 4
		pts.append(p + Vector2(cos(a), sin(a)) * rr)
	ci.draw_colored_polygon(pts, col)


static func _blob(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float, facing: float) -> void:
	var squash := 1.0 + sin(t * 3.0) * 0.05
	var pts := PackedVector2Array()
	for i in 32:
		var a := PI + i * PI / 31.0
		pts.append(c + Vector2(cos(a) * 0.9 / squash, 0.3 + sin(a) * 1.05 * squash) * s)
	for i in 7:
		var u := float(i) / 6.0
		pts.append(c + Vector2(0.9 / squash - u * 1.8 / squash, 0.95 + (0.06 if i % 2 == 1 else 0.0)) * s)
	pts = safe(pts)
	ci.draw_colored_polygon(pts, Color(col, 0.92))
	fill(ci, pts, Color(col, 0.0), maxf(1.5, s * 0.04), false)
	var r := _bounds(pts)
	for q in Geometry2D.intersect_polygons(pts, PackedVector2Array([Vector2(r.position.x + r.size.x * 0.6, r.position.y), r.end - Vector2(0, r.size.y), r.end, Vector2(r.position.x + r.size.x * 0.45, r.end.y)])):
		if _area(q) > 1.0:
			ci.draw_colored_polygon(q, Color(col.darkened(0.3), 0.6))
	# bubbles + shine
	for i in 4:
		var bp := c + Vector2(-0.4 + i * 0.25, 0.5 - fmod(t * 0.3 + i * 0.27, 1.0) * 0.9) * s
		ci.draw_arc(bp, s * (0.05 + i * 0.01), 0, TAU, 12, Color(1, 1, 1, 0.35), 1.5)
	oval(ci, c + Vector2(-0.45, -0.35) * s, s * 0.16, s * 0.08, Color(1, 1, 1, 0.45), 0.0, -0.6)
	var look := Vector2(facing * 0.6, 0.1)
	eye(ci, c + Vector2(-0.22, -0.05) * s, s * 0.14, look)
	eye(ci, c + Vector2(0.18, -0.08) * s, s * 0.16, look)
	ci.draw_arc(c + Vector2(0, 0.22) * s, s * 0.14, 0.2, PI - 0.2, 12, OUTLINE, maxf(1.5, s * 0.03))


static func _wisp(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float) -> void:
	var flap := sin(t * 9.0) * 0.25
	var wing := col.darkened(0.3)
	for sgn in [-1.0, 1.0]:
		var arr: Array = [[0.3 * sgn, -0.2], [1.05 * sgn, -0.75 + flap], [0.95 * sgn, -0.25 + flap * 0.6], [1.1 * sgn, 0.05 + flap * 0.4], [0.75 * sgn, 0.0 + flap * 0.3], [0.7 * sgn, 0.25], [0.3 * sgn, 0.15]]
		if sgn < 0:
			arr.reverse()
		shape(ci, arr, c, s, wing)
	var body := ellipse_pts(c + Vector2(0, -0.1) * s, s * 0.48, s * 0.52, 30)
	fill(ci, body, col, maxf(1.5, s * 0.04))
	# ears
	shape(ci, [[-0.38, -0.4], [-0.32, -0.9], [-0.1, -0.55]], c, s, col)
	shape(ci, [[0.38, -0.4], [0.32, -0.9], [0.1, -0.55]], c, s, col)
	# tail flame
	shape(ci, [[-0.2, 0.3], [0.0, 0.95 + sin(t * 6.0) * 0.08], [0.2, 0.3]], c, s, col.lightened(0.2))
	eye(ci, c + Vector2(-0.17, -0.2) * s, s * 0.12, Vector2(-0.5, 0.2), Color("c0263f"))
	eye(ci, c + Vector2(0.17, -0.2) * s, s * 0.12, Vector2(-0.5, 0.2), Color("c0263f"))
	shape(ci, [[-0.12, 0.05], [-0.07, 0.18], [-0.02, 0.05]], c, s, Color.WHITE, false)
	shape(ci, [[0.02, 0.05], [0.07, 0.18], [0.12, 0.05]], c, s, Color.WHITE, false)


static func _knight(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float, facing: float) -> void:
	var steel := Color("9aa5bd")
	var f := facing
	# cape
	shape(ci, [[-0.35 * f, -0.45], [0.0, -0.45], [-0.25 * f, 0.95], [-0.6 * f + sin(t * 2.0) * 0.05, 0.9]], c, s, col.darkened(0.35))
	# legs
	shape(ci, [[-0.25, 0.4], [-0.05, 0.4], [-0.06, 0.98], [-0.28, 0.98]], c, s, steel.darkened(0.25))
	shape(ci, [[0.05, 0.4], [0.25, 0.4], [0.28, 0.98], [0.06, 0.98]], c, s, steel.darkened(0.25))
	# torso
	shape(ci, [[-0.42, -0.45], [0.42, -0.45], [0.34, 0.45], [-0.34, 0.45]], c, s, steel)
	shape(ci, [[-0.3, -0.35], [0.3, -0.35], [0.0, 0.2]], c, s, col)
	# helmet + plume
	shape(ci, [[0.0, -1.05], [0.12 * -f, -1.35 + sin(t * 3.0) * 0.03], [0.4 * -f, -1.25], [0.2 * -f, -0.95]], c, s, col.lightened(0.1))
	shape(ci, [[-0.3, -0.45], [-0.32, -0.88], [0.0, -1.05], [0.32, -0.88], [0.3, -0.45]], c, s, steel.lightened(0.05))
	ci.draw_line(c + Vector2(-0.22, -0.72) * s, c + Vector2(0.22, -0.72) * s, OUTLINE, s * 0.08)
	ci.draw_line(c + Vector2(-0.18, -0.72) * s, c + Vector2(0.18, -0.72) * s, Color(col.lightened(0.4), 0.6 + 0.4 * sin(t * 4.0)), s * 0.035)
	# shield (front) + sword (back hand)
	var sp := c + Vector2(0.45 * f, 0.05) * s
	shape(ci, [[-0.28, -0.35], [0.28, -0.35], [0.28, 0.05], [0.0, 0.42], [-0.28, 0.05]], sp, s, col)
	shape(ci, [[-0.18, -0.25], [0.18, -0.25], [0.18, 0.02], [0.0, 0.26], [-0.18, 0.02]], sp, s, col.darkened(0.3), false)
	_star(ci, sp + Vector2(0, -0.02) * s, s * 0.08, Color("f2c96b"))
	var hp := c + Vector2(-0.5 * f, 0.1) * s
	ci.draw_line(hp, hp + Vector2(0.15 * -f, -1.0) * s, OUTLINE, s * 0.11, true)
	ci.draw_line(hp, hp + Vector2(0.15 * -f, -1.0) * s, Color("e6ebf5"), s * 0.07, true)
	ci.draw_line(hp + Vector2(-0.12, -0.02) * s, hp + Vector2(0.12, 0.02) * s, Color("f2c96b"), s * 0.06)


static func _golem(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float) -> void:
	var stone := col
	# legs
	shape(ci, [[-0.5, 0.45], [-0.12, 0.45], [-0.15, 1.0], [-0.55, 1.0]], c, s, stone.darkened(0.2))
	shape(ci, [[0.12, 0.45], [0.5, 0.45], [0.55, 1.0], [0.15, 1.0]], c, s, stone.darkened(0.2))
	# body
	shape(ci, [[-0.7, -0.55], [-0.35, -0.85], [0.35, -0.85], [0.7, -0.55], [0.6, 0.55], [-0.6, 0.55]], c, s, stone)
	# cracks
	ci.draw_polyline(pts_of([[-0.4, -0.6], [-0.25, -0.35], [-0.35, -0.1]], c, s), OUTLINE, maxf(1.0, s * 0.025))
	ci.draw_polyline(pts_of([[0.45, 0.1], [0.3, 0.25], [0.38, 0.45]], c, s), OUTLINE, maxf(1.0, s * 0.025))
	# glowing core
	var pulse := 0.5 + 0.5 * sin(t * 2.5)
	glow(ci, c + Vector2(0, -0.1) * s, s * (0.35 + pulse * 0.06), Color("ffcf4a"))
	shape(ci, [[0.0, -0.32], [0.18, -0.1], [0.0, 0.12], [-0.18, -0.1]], c, s, Color("ffd97a"), false)
	# head
	shape(ci, [[-0.28, -0.85], [-0.25, -1.18], [0.25, -1.18], [0.28, -0.85]], c, s, stone.lightened(0.1))
	ci.draw_line(c + Vector2(-0.18, -1.02) * s, c + Vector2(-0.05, -1.0) * s, Color("ffcf4a"), s * 0.06)
	ci.draw_line(c + Vector2(0.05, -1.0) * s, c + Vector2(0.18, -1.02) * s, Color("ffcf4a"), s * 0.06)
	# fists
	var sw := sin(t * 1.5) * 0.04
	shape(ci, [[-1.0, -0.1 + sw], [-0.68, -0.15 + sw], [-0.62, 0.3 + sw], [-0.98, 0.35 + sw]], c, s, stone.lightened(0.05))
	shape(ci, [[0.68, -0.15 - sw], [1.0, -0.1 - sw], [0.98, 0.35 - sw], [0.62, 0.3 - sw]], c, s, stone.lightened(0.05))


static func _sprout(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float) -> void:
	var leaf := col.darkened(0.25)
	for sgn in [-1.0, 1.0]:
		var sw: float = sin(t * 2.0 + sgn) * 0.05
		var arr: Array = [[0.1 * sgn, 0.85], [0.9 * sgn, 0.55 + sw], [1.05 * sgn, 0.75 + sw], [0.4 * sgn, 0.98]]
		if sgn < 0:
			arr.reverse()
		shape(ci, arr, c, s, leaf)
	var pts: Array = []
	for i in 18:
		var a := PI + i * PI / 17.0
		var r := 0.95 if i % 2 == 0 else 0.7
		pts.append([cos(a) * r * 0.85, sin(a) * r + 0.35])
	pts.append([0.75, 0.95])
	pts.append([-0.75, 0.95])
	shape(ci, pts, c, s, col)
	# thorns
	for i in 5:
		var tp := c + Vector2(-0.45 + i * 0.22, 0.45 - (i % 2) * 0.2) * s
		ci.draw_colored_polygon(PackedVector2Array([tp + Vector2(-0.04, 0) * s, tp + Vector2(0, -0.12) * s, tp + Vector2(0.04, 0) * s]), Color("f6f0d0"))
	# flower bud on top
	var fp := c + Vector2(0, -0.72) * s
	for i in 5:
		var a := t * 0.5 + i * TAU / 5.0
		oval(ci, fp + Vector2(cos(a), sin(a)) * s * 0.14, s * 0.11, s * 0.07, Color("ff7ab0"), 1.5, a)
	ball(ci, fp, s * 0.08, Color("ffd34a"))
	eye(ci, c + Vector2(-0.22, 0.2) * s, s * 0.12, Vector2(-0.5, 0.0))
	eye(ci, c + Vector2(0.2, 0.2) * s, s * 0.12, Vector2(-0.5, 0.0))
	ci.draw_polyline(pts_of([[-0.15, 0.45], [-0.05, 0.4], [0.05, 0.45], [0.15, 0.4]], c, s), OUTLINE, maxf(1.5, s * 0.03))


static func _eye_priest(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float, facing: float) -> void:
	var robe := col.darkened(0.45)
	# robe
	shape(ci, [[-0.32, -0.3], [0.32, -0.3], [0.55, 0.98], [-0.55, 0.98]], c, s, robe)
	ci.draw_polyline(pts_of([[0.0, -0.25], [0.0, 0.95]], c, s), col.darkened(0.1), s * 0.06)
	for i in 3:
		ci.draw_circle(c + Vector2(0, 0.0 + i * 0.28) * s, s * 0.04, Color("f2c96b"))
	# tentacle arms
	for sgn in [-1.0, 1.0]:
		var pts := PackedVector2Array()
		for i in 10:
			var u := float(i) / 9.0
			pts.append(c + Vector2(sgn * (0.3 + u * 0.55), -0.15 + u * 0.4 + sin(u * 5.0 + t * 3.0 + sgn) * 0.08) * s)
		ci.draw_polyline(pts, OUTLINE, s * 0.12, true)
		ci.draw_polyline(pts, col.darkened(0.2), s * 0.08, true)
	# floating eye head
	var hp := c + Vector2(0, -0.68 + sin(t * 2.0) * 0.04) * s
	glow(ci, hp, s * 0.65, col, 4)
	ball(ci, hp, s * 0.42, col.darkened(0.1), maxf(1.5, s * 0.04))
	ci.draw_circle(hp, s * 0.3, Color("fff6e6"))
	for i in 5:
		var a := i * TAU / 5.0 + 0.4
		ci.draw_line(hp + Vector2(cos(a), sin(a)) * s * 0.3, hp + Vector2(cos(a), sin(a)) * s * 0.2, Color("e07a8a"), 1.5)
	var look := Vector2(facing * 0.08 + sin(t * 0.7) * 0.05, 0.02) * s
	ci.draw_circle(hp + look, s * 0.16, col.lightened(0.15))
	ci.draw_circle(hp + look, s * 0.08, Palette.BG)
	ci.draw_circle(hp + look + Vector2(-0.04, -0.04) * s, s * 0.03, Color.WHITE)
	# hood rim
	ci.draw_arc(hp, s * 0.44, PI * 1.1, PI * 1.9, 20, robe, s * 0.1, true)


static func _hollow_king(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float) -> void:
	var cloak := Color("2c2442")
	# cape
	shape(ci, [[-0.4, -0.45], [0.4, -0.45], [0.85, 0.98], [-0.85, 0.98]], c, s, cloak)
	ci.draw_polyline(pts_of([[-0.85, 0.94], [0.85, 0.94]], c, s), col, s * 0.05)
	# chest armour
	shape(ci, [[-0.32, -0.45], [0.32, -0.45], [0.26, 0.3], [-0.26, 0.3]], c, s, Color("4a4166"))
	_star(ci, c + Vector2(0, -0.12) * s, s * 0.12, col)
	# scepter
	var sp := c + Vector2(0.62, 0.3) * s
	ci.draw_line(sp, sp + Vector2(0.05, -1.25) * s, OUTLINE, s * 0.1, true)
	ci.draw_line(sp, sp + Vector2(0.05, -1.25) * s, col.darkened(0.2), s * 0.06, true)
	glow(ci, sp + Vector2(0.05, -1.3) * s, s * 0.3, Color("c38bff"), 4)
	ball(ci, sp + Vector2(0.05, -1.3) * s, s * 0.12, Color("c38bff"))
	ball(ci, sp + Vector2(0, -0.05) * s, s * 0.08, Color("e9d1b5"))
	# head: hollow void with burning eyes
	ball(ci, c + Vector2(0, -0.68) * s, s * 0.3, Color("181425"), maxf(1.5, s * 0.04))
	var fl := 0.6 + 0.4 * sin(t * 5.0)
	for ex in [-0.11, 0.11]:
		glow(ci, c + Vector2(ex, -0.68) * s, s * 0.12, Color("ffcf4a"), 3)
		ci.draw_circle(c + Vector2(ex, -0.68) * s, s * 0.05 * fl + s * 0.02, Color("fff1b0"))
	# crown
	shape(ci, [[-0.36, -0.86], [-0.4, -1.28], [-0.2, -1.05], [0.0, -1.38], [0.2, -1.05], [0.4, -1.28], [0.36, -0.86]], c, s, col)
	for gx in [-0.2, 0.0, 0.2]:
		ci.draw_circle(c + Vector2(gx, -0.95) * s, s * 0.045, Color("ff4f7b"))


static func _wyrm(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float) -> void:
	var scale_col := col.darkened(0.15)
	# wings
	var flap := sin(t * 1.6) * 0.12
	shape(ci, [[0.1, -0.35], [0.95, -1.15 + flap], [1.05, -0.55 + flap], [0.8, -0.6 + flap], [0.85, -0.2 + flap * 0.5], [0.45, -0.1]], c, s, col.darkened(0.4))
	# coiled body (segments from tail to neck)
	var segs: Array = []
	for i in 9:
		var u := float(i) / 8.0
		segs.append(c + Vector2(0.75 - u * 1.2 + sin(u * 4.0 + t) * 0.06, 0.75 - u * 1.25 + cos(u * 3.0) * 0.12) * s)
	for i in segs.size():
		var r := s * (0.2 + 0.18 * sin(float(i) / segs.size() * PI))
		ball(ci, segs[i], r, scale_col, maxf(1.5, s * 0.03))
		ci.draw_circle(segs[i] + Vector2(0, r * 0.4), r * 0.45, Color("f2c96b", 0.55))
	# lantern glow in chest
	var chest: Vector2 = segs[5]
	glow(ci, chest, s * 0.35 * (0.9 + 0.1 * sin(t * 4.0)), Color("ffcf4a"), 5)
	# head
	var hp: Vector2 = segs[8] + Vector2(-0.18, -0.12) * s
	shape(ci, [[0.15, -0.2], [-0.25, -0.22], [-0.55, -0.05], [-0.25, 0.08], [0.15, 0.18]], hp, s, col)
	shape(ci, [[-0.2, 0.05], [-0.5, 0.0 + sin(t * 2.0) * 0.04], [-0.2, 0.18]], hp, s, col.darkened(0.25))
	shape(ci, [[0.02, -0.2], [0.2, -0.55], [0.12, -0.18]], hp, s, Color("f6e7c8"))
	shape(ci, [[-0.1, -0.2], [0.0, -0.48], [-0.02, -0.18]], hp, s, Color("f6e7c8"))
	ci.draw_circle(hp + Vector2(-0.12, -0.1) * s, s * 0.05, Color("ffcf4a"))
	ci.draw_circle(hp + Vector2(-0.12, -0.1) * s, s * 0.02, OUTLINE)
	# smoke from nostril
	var ph := fmod(t * 0.7, 1.0)
	ci.draw_circle(hp + Vector2(-0.6 - ph * 0.3, -0.1 - ph * 0.4) * s, s * (0.04 + ph * 0.08), Color(0.6, 0.6, 0.65, 0.4 * (1.0 - ph)))
