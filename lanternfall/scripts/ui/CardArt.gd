class_name CardArt
## One bespoke vector illustration per card, drawn into the card's art window.
## Coordinates below are in "units": u = half the art height; x spans about -1.75..1.75, y -1..1.

const BRASS := Color("d9a24a")
const STEEL := Color("b9c3d6")
const DARK := Color("2a2230")
const IVORY := Color("f5f1ff")
const VIOLET := Color("b18cff")
const TEAL := Color("3fd6b4")
const PINK := Color("ff8fb8")
const GOLDC := Color("f2c96b")
const FIRE := Color("ff8a4f")
const SKY := Color("7ee8ff")


static var _inst: CardArt = null


static func draw(ci: CanvasItem, card: Dictionary, r: Rect2) -> void:
	var c := r.get_center()
	var u := r.size.y * 0.5
	_background(ci, card, r, c, u)
	var fn := "_" + str(card["id"])
	if _inst == null:
		_inst = CardArt.new()
	if _inst.has_method(fn):
		_inst.call(fn, ci, c, u)
	else:
		IconDraw.icon(ci, card["type"], c, u * 0.7, Palette.type_color(card["type"]))


# ------------------------------------------------------------------ helpers

static func P(c: Vector2, u: float, x: float, y: float) -> Vector2:
	return c + Vector2(x, y) * u


static func S(ci: CanvasItem, pts: Array, c: Vector2, u: float, col: Color, shade: bool = true) -> void:
	IconDraw.shape(ci, pts, c, u, col, shade)


static func L(ci: CanvasItem, c: Vector2, u: float, a: Array, b: Array, col: Color, w: float = 0.08) -> void:
	ci.draw_line(P(c, u, a[0], a[1]), P(c, u, b[0], b[1]), col, maxf(1.0, w * u), true)


static func OL(ci: CanvasItem, c: Vector2, u: float, a: Array, b: Array, col: Color, w: float = 0.1) -> void:
	L(ci, c, u, a, b, IconDraw.OUTLINE, w + 0.05)
	L(ci, c, u, a, b, col, w)


static func B(ci: CanvasItem, c: Vector2, u: float, x: float, y: float, r: float, col: Color) -> void:
	IconDraw.ball(ci, P(c, u, x, y), r * u, col, maxf(1.0, u * 0.04))


static func spark(ci: CanvasItem, p: Vector2, r: float, col: Color) -> void:
	ci.draw_line(p + Vector2(-r, 0), p + Vector2(r, 0), col, maxf(1.0, r * 0.25), true)
	ci.draw_line(p + Vector2(0, -r), p + Vector2(0, r), col, maxf(1.0, r * 0.25), true)
	ci.draw_line(p + Vector2(-r, -r) * 0.55, p + Vector2(r, r) * 0.55, col, maxf(1.0, r * 0.15), true)
	ci.draw_line(p + Vector2(r, -r) * 0.55, p + Vector2(-r, r) * 0.55, col, maxf(1.0, r * 0.15), true)


static func arcp(ci: CanvasItem, c: Vector2, u: float, x: float, y: float, rad: float, a0: float, a1: float, col: Color, w: float = 0.07) -> void:
	ci.draw_arc(P(c, u, x, y), rad * u, a0, a1, 24, col, maxf(1.0, w * u), true)


static func note(ci: CanvasItem, p: Vector2, s: float, col: Color) -> void:
	IconDraw.oval(ci, p, s * 0.32, s * 0.24, col, 1.5, -0.4)
	ci.draw_line(p + Vector2(s * 0.28, -s * 0.05), p + Vector2(s * 0.28, -s * 1.0), col, maxf(1.5, s * 0.1), true)
	ci.draw_line(p + Vector2(s * 0.28, -s * 1.0), p + Vector2(s * 0.62, -s * 0.72), col, maxf(1.5, s * 0.1), true)


static func card_rect(ci: CanvasItem, p: Vector2, w: float, h: float, rot: float, col: Color, mark: Color) -> void:
	var pts = PackedVector2Array()
	for v in [Vector2(-w, -h), Vector2(w, -h), Vector2(w, h), Vector2(-w, h)]:
		pts.append(p + (v as Vector2).rotated(rot))
	IconDraw.fill(ci, pts, col, 1.5, true)
	IconDraw._star(ci, p, minf(w, h) * 0.45, mark)


static func coin(ci: CanvasItem, p: Vector2, rx: float, ry: float) -> void:
	IconDraw.oval(ci, p + Vector2(0, ry * 0.25), rx, ry, GOLDC.darkened(0.35), 1.5)
	IconDraw.oval(ci, p, rx, ry, GOLDC, 1.5)
	IconDraw.oval(ci, p, rx * 0.6, ry * 0.6, GOLDC.lightened(0.2), 0.0)


static func chips(ci: CanvasItem, p: Vector2, r: float, n: int, col: Color) -> void:
	for i in n:
		var q = p + Vector2(0, -i * r * 0.32)
		IconDraw.oval(ci, q, r, r * 0.38, col if i % 2 == 0 else IVORY, 1.5)


static func dancer(ci: CanvasItem, c: Vector2, u: float, x: float, y: float, s: float, col: Color, pose: String) -> void:
	var o = P(c, u, x, y)
	var k = u * s
	var skin = Color("e9c9b4")
	match pose:
		"leap":
			ci.draw_line(o, o + Vector2(-0.9, 0.35) * k, IconDraw.OUTLINE, k * 0.16, true)
			ci.draw_line(o, o + Vector2(-0.9, 0.35) * k, skin, k * 0.1, true)
			ci.draw_line(o, o + Vector2(0.95, 0.25) * k, IconDraw.OUTLINE, k * 0.16, true)
			ci.draw_line(o, o + Vector2(0.95, 0.25) * k, skin, k * 0.1, true)
			IconDraw.shape(ci, [[-0.25, 0.1], [0.25, 0.1], [0.12, -0.6], [-0.12, -0.6]], o, k, col)
			ci.draw_line(o + Vector2(0, -0.5) * k, o + Vector2(-0.7, -0.95) * k, skin, k * 0.08, true)
			ci.draw_line(o + Vector2(0, -0.5) * k, o + Vector2(0.75, -0.9) * k, skin, k * 0.08, true)
			IconDraw.ball(ci, o + Vector2(0.05, -0.82) * k, k * 0.18, skin, 1.5)
		"bow":
			IconDraw.shape(ci, [[-0.55, 0.9], [0.55, 0.9], [0.2, 0.0], [-0.2, 0.0]], o, k, col)
			IconDraw.shape(ci, [[-0.15, 0.05], [0.15, 0.05], [0.4, -0.45], [0.15, -0.55]], o, k, col.lightened(0.1))
			IconDraw.ball(ci, o + Vector2(0.45, -0.55) * k, k * 0.17, skin, 1.5)
			ci.draw_line(o + Vector2(0.15, -0.3) * k, o + Vector2(-0.45, 0.15) * k, skin, k * 0.08, true)
		"kick":
			ci.draw_line(o, o + Vector2(-0.25, 0.9) * k, skin, k * 0.11, true)
			ci.draw_line(o, o + Vector2(1.0, -0.35) * k, IconDraw.OUTLINE, k * 0.17, true)
			ci.draw_line(o, o + Vector2(1.0, -0.35) * k, skin, k * 0.11, true)
			IconDraw.shape(ci, [[-0.3, 0.15], [0.25, 0.1], [0.1, -0.6], [-0.2, -0.6]], o, k, col)
			IconDraw.ball(ci, o + Vector2(-0.08, -0.82) * k, k * 0.18, skin, 1.5)
			ci.draw_line(o + Vector2(-0.1, -0.5) * k, o + Vector2(-0.75, -0.75) * k, skin, k * 0.08, true)
		_: # spin / arms up
			IconDraw.shape(ci, [[-0.6, 0.6], [0.6, 0.6], [0.15, -0.35], [-0.15, -0.35]], o, k, col)
			ci.draw_line(o + Vector2(-0.05, 0.6) * k, o + Vector2(-0.05, 1.0) * k, skin, k * 0.09, true)
			ci.draw_line(o + Vector2(0, -0.3) * k, o + Vector2(-0.55, -0.95) * k, skin, k * 0.08, true)
			ci.draw_line(o + Vector2(0, -0.3) * k, o + Vector2(0.55, -0.95) * k, skin, k * 0.08, true)
			IconDraw.ball(ci, o + Vector2(0, -0.6) * k, k * 0.18, skin, 1.5)


static func _background(ci: CanvasItem, card: Dictionary, r: Rect2, c: Vector2, u: float) -> void:
	var h = hash(card["id"])
	var tc = Palette.type_color(card.get("type", "skill"))
	match card.get("owner", ""):
		"clockwright":
			# workshop: pipes, rivets and a large faint gear
			IconDraw.gear(ci, r.position + Vector2(r.size.x - 18, 16), 30, 23, 10, Color(BRASS, 0.12), float(h % 9))
			ci.draw_line(r.position + Vector2(0, r.size.y - 14), r.end - Vector2(0, 14), Color(STEEL, 0.12), 6.0)
			ci.draw_line(r.position + Vector2(18, 0), r.position + Vector2(18, r.size.y), Color(STEEL, 0.1), 5.0)
			for i in 5:
				ci.draw_circle(r.position + Vector2(8 + i * 30, r.size.y - 14), 1.6, Color(BRASS, 0.35))
		"fatebinder":
			var pts: Array = []
			for i in 6:
				var px = r.position.x + 8 + float((h >> (i * 3)) % 113) / 113.0 * (r.size.x - 16)
				var py = r.position.y + 6 + float((h >> (i * 2 + 7)) % 59) / 59.0 * (r.size.y - 12)
				pts.append(Vector2(px, py))
			for i in pts.size() - 1:
				ci.draw_line(pts[i], pts[i + 1], Color(VIOLET, 0.16), 1.0, true)
			for p in pts:
				IconDraw._star(ci, p, 3.0, Color(IVORY, 0.45))
		"duskdancer":
			# stage: floor boards, side curtains, little moon
			ci.draw_line(r.position + Vector2(0, r.size.y - 12), r.end - Vector2(0, 12), Color(GOLDC, 0.18), 2.0)
			for i in 3:
				ci.draw_line(r.position + Vector2(4 + i * 5, 0), r.position + Vector2(2 + i * 6, r.size.y - 12), Color(Color("7a2840"), 0.45), 4.0)
				ci.draw_line(Vector2(r.end.x - 4 - i * 5, r.position.y), Vector2(r.end.x - 2 - i * 6, r.end.y - 12), Color(Color("7a2840"), 0.45), 4.0)
			ci.draw_circle(r.position + Vector2(r.size.x * 0.78, 12), 5, Color(GOLDC, 0.35))
		_:
			ci.draw_line(r.position, r.end, Color(Palette.BAD, 0.15), 3.0)
	ci.draw_circle(c, u * 0.95, Color(tc, 0.07))


# ================================================================== CLOCKWRIGHT

static func _c_wrench(ci, c, u):
	arcp(ci, c, u, -0.2, 0.2, 0.9, -2.6, -1.2, Color(1, 1, 1, 0.35), 0.06)
	OL(ci, c, u, [-0.9, 0.7], [0.5, -0.45], STEEL, 0.16)
	S(ci, [[0.35, -0.35], [0.55, -0.85], [0.8, -0.75], [0.72, -0.5], [0.95, -0.35], [0.85, -0.1], [0.6, -0.2]], c, u, STEEL.lightened(0.1))
	B(ci, c, u, -0.9, 0.7, 0.13, BRASS)


static func _c_plating(ci, c, u):
	for i in 3:
		var o = Vector2(-0.55 + i * 0.5, -0.2 + i * 0.18)
		S(ci, [[-0.45, -0.4], [0.45, -0.4], [0.45, 0.4], [-0.45, 0.4]], c + o * u, u, STEEL.darkened(0.15 * (2 - i)))
		for q in [[-0.32, -0.27], [0.32, -0.27], [-0.32, 0.27], [0.32, 0.27]]:
			ci.draw_circle(P(c + o * u, u, q[0], q[1]), u * 0.05, BRASS)


static func _c_tick_turret(ci, c, u):
	IconDraw.icon(ci, "turret", c + Vector2(-0.1, 0.05) * u, u * 0.8, BRASS)
	B(ci, c, u, -0.15, 0.62, 0.22, IVORY)
	L(ci, c, u, [-0.15, 0.62], [-0.15, 0.48], DARK, 0.04)
	L(ci, c, u, [-0.15, 0.62], [-0.04, 0.66], DARK, 0.04)
	spark(ci, P(c, u, 0.95, -0.25), u * 0.25, Palette.ENERGY)


static func _c_overclock(ci, c, u):
	B(ci, c, u, 0, 0.1, 0.8, DARK.lightened(0.15))
	arcp(ci, c, u, 0, 0.1, 0.62, PI * 1.05, PI * 1.6, Palette.GOOD, 0.12)
	arcp(ci, c, u, 0, 0.1, 0.62, PI * 1.6, PI * 1.95, Palette.BAD, 0.12)
	OL(ci, c, u, [0, 0.1], [0.5, -0.35], Palette.BAD, 0.07)
	B(ci, c, u, 0, 0.1, 0.1, BRASS)
	IconDraw.icon(ci, "bolt", P(c, u, 1.15, -0.4), u * 0.35, Palette.ENERGY)
	IconDraw.icon(ci, "bolt", P(c, u, -1.15, 0.35), u * 0.3, Palette.ENERGY)


static func _c_rivet_shot(ci, c, u):
	arcp(ci, c, u, 1.05, 0.0, 0.45, 0, TAU, Palette.BAD, 0.05)
	arcp(ci, c, u, 1.05, 0.0, 0.2, 0, TAU, Palette.BAD, 0.05)
	for i in 3:
		var y = -0.45 + i * 0.45
		L(ci, c, u, [-1.4, y], [-0.2 + i * 0.25, y * 0.5], Color(1, 1, 1, 0.3), 0.05)
		S(ci, [[-0.2 + i * 0.25, y * 0.5 - 0.1], [0.15 + i * 0.25, y * 0.5 - 0.06], [0.22 + i * 0.25, y * 0.5], [0.15 + i * 0.25, y * 0.5 + 0.06], [-0.2 + i * 0.25, y * 0.5 + 0.1]], c, u, STEEL)


static func _c_barrier_node(ci, c, u):
	ci.draw_arc(P(c, u, 0, 0.6), u * 1.1, PI, TAU, 32, Color(Palette.BLOCK, 0.7), u * 0.08, true)
	ci.draw_arc(P(c, u, 0, 0.6), u * 0.95, PI, TAU, 32, Color(Palette.BLOCK, 0.25), u * 0.25, true)
	S(ci, [[-0.25, 0.7], [0.25, 0.7], [0.12, -0.1], [-0.12, -0.1]], c, u, STEEL)
	B(ci, c, u, 0, -0.2, 0.17, Palette.BLOCK)


static func _c_spanner_toss(ci, c, u):
	for i in 2:
		var p = P(c, u, -0.7 + i * 1.2, 0.15 - i * 0.35)
		var rot = 0.6 + i * 1.3
		var a = p + Vector2(-0.45, 0).rotated(rot) * u
		var b = p + Vector2(0.45, 0).rotated(rot) * u
		ci.draw_line(a, b, IconDraw.OUTLINE, u * 0.2, true)
		ci.draw_line(a, b, STEEL, u * 0.13, true)
		ci.draw_arc(b, u * 0.14, rot - 1.2, rot + 1.2, 10, STEEL, u * 0.1, true)
		ci.draw_arc(p, u * 0.65, rot + 2.2, rot + 3.2, 12, Color(1, 1, 1, 0.3), u * 0.04, true)


static func _c_scrap_shield(ci, c, u):
	S(ci, [[-0.75, -0.75], [0.0, -0.8], [0.0, 0.85], [-0.75, 0.0]], c, u, STEEL.darkened(0.1))
	S(ci, [[0.0, -0.8], [0.75, -0.75], [0.75, 0.0], [0.0, 0.85]], c, u, BRASS.darkened(0.1))
	S(ci, [[-0.4, -0.2], [0.35, -0.3], [0.3, 0.2], [-0.35, 0.25]], c, u, Color("8a6440"))
	for q in [[-0.5, -0.55], [0.5, -0.55], [-0.25, 0.4], [0.25, 0.4]]:
		ci.draw_circle(P(c, u, q[0], q[1]), u * 0.05, DARK)


static func _c_tinker(ci, c, u):
	IconDraw.gear(ci, P(c, u, 0.55, 0.2), u * 0.5, u * 0.38, 9, BRASS, 0.2)
	OL(ci, c, u, [-1.0, 0.65], [0.15, -0.35], STEEL, 0.07)
	S(ci, [[-1.25, 0.75], [-0.85, 0.45], [-0.7, 0.62], [-1.1, 0.92]], c, u, Palette.BAD)
	spark(ci, P(c, u, 0.2, -0.45), u * 0.22, GOLDC)


static func _c_steam_vent(ci, c, u):
	S(ci, [[-1.4, 0.3], [-0.2, 0.3], [-0.2, 0.75], [-1.4, 0.75]], c, u, Color("6e6a73"))
	S(ci, [[-0.3, 0.15], [0.1, 0.15], [0.1, 0.9], [-0.3, 0.9]], c, u, BRASS)
	B(ci, c, u, -0.8, 0.15, 0.17, Palette.BAD)
	for i in 4:
		B(ci, c, u, 0.4 + i * 0.32, 0.35 - i * 0.28, 0.2 + i * 0.07, Color(0.92, 0.94, 1.0, 0.75 - i * 0.12))


static func _c_target_lock(ci, c, u):
	IconDraw.eye(ci, P(c, u, 0, 0), u * 0.32, Vector2(0, 0), Color("c0263f"))
	arcp(ci, c, u, 0, 0, 0.62, 0, TAU, Palette.BAD, 0.07)
	for d in [[0, -1], [0, 1], [-1, 0], [1, 0]]:
		L(ci, c, u, [d[0] * 0.45, d[1] * 0.45], [d[0] * 0.95, d[1] * 0.95], Palette.BAD, 0.07)


static func _c_oil_slick(ci, c, u):
	IconDraw.oval(ci, P(c, u, 0.4, 0.7), u * 0.95, u * 0.2, Color("1b1b24"), 1.5)
	IconDraw.oval(ci, P(c, u, 0.25, 0.66), u * 0.4, u * 0.07, Color(Color("8f7bff"), 0.6), 0.0)
	S(ci, [[-1.1, -0.2], [-0.4, -0.55], [-0.15, -0.05], [-0.85, 0.3]], c, u, Palette.BAD.darkened(0.15))
	OL(ci, c, u, [-0.3, -0.35], [0.25, -0.6], STEEL, 0.07)
	for i in 3:
		B(ci, c, u, 0.3 + i * 0.05, -0.35 + i * 0.3, 0.07, Color("1b1b24"))


static func _c_bolt_gun(ci, c, u):
	S(ci, [[-1.1, -0.35], [0.3, -0.35], [0.3, 0.05], [-0.4, 0.05], [-0.5, 0.75], [-0.85, 0.75], [-0.75, 0.05], [-1.1, 0.05]], c, u, BRASS)
	S(ci, [[0.3, -0.25], [0.6, -0.25], [0.6, -0.05], [0.3, -0.05]], c, u, STEEL)
	for i in 2:
		S(ci, [[0.85 + i * 0.4, -0.2], [1.15 + i * 0.4, -0.15], [0.85 + i * 0.4, -0.1]], c, u, STEEL.lightened(0.2), false)


static func _c_tesla_coil(ci, c, u):
	S(ci, [[-0.35, 0.9], [0.35, 0.9], [0.2, 0.55], [-0.2, 0.55]], c, u, DARK.lightened(0.2))
	for i in 5:
		IconDraw.oval(ci, P(c, u, 0, 0.45 - i * 0.18), u * 0.2, u * 0.07, BRASS, 1.2)
	B(ci, c, u, 0, -0.55, 0.25, SKY)
	for side in [-1.0, 1.0]:
		var pts = PackedVector2Array()
		for i in 6:
			pts.append(P(c, u, side * (0.25 + i * 0.22), -0.55 + (0.15 if i % 2 == 0 else -0.15)))
		ci.draw_polyline(pts, SKY, maxf(1.5, u * 0.06), true)


static func _c_repair_drone(ci, c, u):
	L(ci, c, u, [-0.6, -0.65], [0.6, -0.65], Color(1, 1, 1, 0.7), 0.06)
	L(ci, c, u, [0, -0.45], [0, -0.65], STEEL, 0.06)
	S(ci, [[-0.45, -0.45], [0.45, -0.45], [0.35, 0.05], [-0.35, 0.05]], c, u, BRASS)
	ci.draw_circle(P(c, u, 0, -0.2), u * 0.1, Palette.GOOD)
	OL(ci, c, u, [0.3, 0.0], [0.55, 0.45], STEEL, 0.05)
	S(ci, [[1.0, 0.1], [1.2, 0.1], [1.2, 0.3], [1.4, 0.3], [1.4, 0.5], [1.2, 0.5], [1.2, 0.7], [1.0, 0.7], [1.0, 0.5], [0.8, 0.5], [0.8, 0.3], [1.0, 0.3]], c, u, Palette.GOOD)


static func _c_amplifier(ci, c, u):
	S(ci, [[-0.8, -0.75], [0.1, -0.75], [0.1, 0.8], [-0.8, 0.8]], c, u, DARK.lightened(0.15))
	B(ci, c, u, -0.35, 0.15, 0.35, Color("4a4166"))
	B(ci, c, u, -0.35, 0.15, 0.13, DARK)
	B(ci, c, u, -0.35, -0.5, 0.14, Color("4a4166"))
	for i in 3:
		arcp(ci, c, u, 0.1, 0.0, 0.4 + i * 0.3, -0.8, 0.8, Color(BRASS, 0.9 - i * 0.25), 0.07)


static func _c_double_shift(ci, c, u):
	for i in 2:
		var x = -0.55 + i * 1.1
		B(ci, c, u, x, 0.05, 0.42, IVORY)
		L(ci, c, u, [x, 0.05], [x, -0.22], DARK, 0.05)
		L(ci, c, u, [x, 0.05], [x + 0.2 * (1 - i * 2), 0.12], DARK, 0.05)
	arcp(ci, c, u, 0, 0.05, 0.95, PI * 1.15, PI * 1.85, GOLDC, 0.07)
	arcp(ci, c, u, 0, 0.05, 0.95, PI * 0.15, PI * 0.85, GOLDC, 0.07)
	S(ci, [[0.75, -0.75], [0.95, -0.55], [0.7, -0.5]], c, u, GOLDC, false)
	S(ci, [[-0.75, 0.85], [-0.95, 0.65], [-0.7, 0.6]], c, u, GOLDC, false)


static func _c_cog_barrage(ci, c, u):
	for i in 6:
		var x = -1.2 + i * 0.5
		var y = sin(i * 1.7) * 0.45
		IconDraw.gear(ci, P(c, u, x, y), u * (0.2 + (i % 3) * 0.06), u * (0.15 + (i % 3) * 0.045), 7, BRASS.lerp(STEEL, (i % 2) * 0.6), i * 0.7)
		L(ci, c, u, [x - 0.35, y + 0.08], [x - 0.15, y + 0.03], Color(1, 1, 1, 0.3), 0.04)


static func _c_reinforced_frame(ci, c, u):
	for y in [-0.65, 0.65]:
		S(ci, [[-1.3, y - 0.1], [1.3, y - 0.1], [1.3, y + 0.1], [-1.3, y + 0.1]], c, u, Palette.BAD.darkened(0.2))
	for i in 5:
		var x = -1.2 + i * 0.6
		OL(ci, c, u, [x, -0.55], [x + 0.6, 0.55], STEEL, 0.06)
		OL(ci, c, u, [x + 0.6, -0.55], [x, 0.55], STEEL, 0.06)
	for i in 6:
		ci.draw_circle(P(c, u, -1.2 + i * 0.48, -0.65), u * 0.04, GOLDC)


static func _c_spring_trap(ci, c, u):
	var pts = PackedVector2Array()
	for i in 25:
		var t = float(i) / 24.0
		pts.append(P(c, u, sin(t * TAU * 4.0) * 0.45, 0.75 - t * 1.1))
	ci.draw_polyline(pts, IconDraw.OUTLINE, u * 0.14, true)
	ci.draw_polyline(pts, STEEL, u * 0.08, true)
	S(ci, [[-0.75, -0.35], [0.75, -0.35], [0.75, -0.48], [-0.75, -0.48]], c, u, BRASS)
	for i in 5:
		S(ci, [[-0.7 + i * 0.32, -0.48], [-0.58 + i * 0.32, -0.85], [-0.46 + i * 0.32, -0.48]], c, u, IVORY)


static func _c_assembly_line(ci, c, u):
	S(ci, [[-1.5, 0.45], [1.5, 0.45], [1.5, 0.7], [-1.5, 0.7]], c, u, DARK.lightened(0.2))
	for i in 7:
		B(ci, c, u, -1.35 + i * 0.45, 0.58, 0.1, STEEL)
	for i in 3:
		IconDraw.icon(ci, "turret", P(c, u, -0.9 + i * 0.9, 0.12), u * 0.32, BRASS.darkened(0.1 * i))
	L(ci, c, u, [1.0, -0.4], [1.4, -0.4], Color(1, 1, 1, 0.35), 0.05)


static func _c_siege_engine(ci, c, u):
	B(ci, c, u, -0.6, 0.6, 0.28, Color("6e4a2a"))
	B(ci, c, u, 0.2, 0.6, 0.28, Color("6e4a2a"))
	S(ci, [[-0.9, 0.4], [0.6, -0.55], [0.8, -0.25], [-0.75, 0.6]], c, u, Color("6e6a73"))
	IconDraw.glow(ci, P(c, u, 1.05, -0.55), u * 0.5, FIRE, 4)
	B(ci, c, u, 1.3, -0.75, 0.2, DARK)
	spark(ci, P(c, u, 0.85, -0.45), u * 0.3, GOLDC)


static func _c_perpetual(ci, c, u):
	var pts = PackedVector2Array()
	for i in 49:
		var t = i * TAU / 48.0
		pts.append(P(c, u, sin(t) * 1.1, sin(t * 2.0) * 0.5))
	ci.draw_polyline(pts, IconDraw.OUTLINE, u * 0.2, true)
	ci.draw_polyline(pts, GOLDC, u * 0.12, true)
	IconDraw.gear(ci, P(c, u, -0.78, 0.0), u * 0.28, u * 0.2, 8, BRASS, 0.0)
	IconDraw.gear(ci, P(c, u, 0.78, 0.0), u * 0.28, u * 0.2, 8, BRASS, 0.4)


static func _c_mech_suit(ci, c, u):
	S(ci, [[-0.7, -0.5], [0.7, -0.5], [0.55, 0.55], [-0.55, 0.55]], c, u, STEEL.darkened(0.1))
	S(ci, [[-1.15, -0.45], [-0.75, -0.45], [-0.8, 0.35], [-1.1, 0.35]], c, u, BRASS)
	S(ci, [[0.75, -0.45], [1.15, -0.45], [1.1, 0.35], [0.8, 0.35]], c, u, BRASS)
	S(ci, [[-0.25, -0.95], [0.25, -0.95], [0.3, -0.5], [-0.3, -0.5]], c, u, STEEL)
	L(ci, c, u, [-0.15, -0.75], [0.15, -0.75], SKY, 0.07)
	IconDraw.glow(ci, P(c, u, 0, 0.0), u * 0.45, SKY, 4)
	B(ci, c, u, 0, 0.0, 0.16, SKY)


static func _c_chain_reaction(ci, c, u):
	for i in 3:
		var p = P(c, u, -1.0 + i * 1.0, 0.3 - i * 0.3)
		IconDraw.glow(ci, p, u * (0.35 + i * 0.12), FIRE, 4)
		var pts = PackedVector2Array()
		for k in 12:
			var rr = (0.38 if k % 2 == 0 else 0.18) * (0.8 + i * 0.25) * u
			pts.append(p + Vector2(cos(k * TAU / 12.0), sin(k * TAU / 12.0)) * rr)
		IconDraw.fill(ci, pts, GOLDC if i == 2 else FIRE, 1.5, false)
		if i < 2:
			L(ci, c, u, [-1.0 + i * 1.0, 0.3 - i * 0.3], [-0.0 + i * 1.0, 0.0 - i * 0.3], Color(GOLDC, 0.6), 0.05)


# ================================================================== FATEBINDER

static func _f_card_edge(ci, c, u):
	card_rect(ci, P(c, u, 0, 0), u * 0.42, u * 0.68, 0.35, Color("2a2140"), GOLDC)
	L(ci, c, u, [-1.2, 0.7], [1.2, -0.75], Color(1, 1, 1, 0.8), 0.05)


static func _f_veil(ci, c, u):
	for i in 3:
		var pts = PackedVector2Array()
		for k in 16:
			var t = float(k) / 15.0
			pts.append(P(c, u, -1.3 + t * 2.6, -0.7 + i * 0.25 + sin(t * TAU + i) * 0.18))
		for k in 16:
			var t2 = 1.0 - float(k) / 15.0
			pts.append(P(c, u, -1.3 + t2 * 2.6, 0.2 + i * 0.25 + sin(t2 * TAU + i + 1.0) * 0.18))
		ci.draw_colored_polygon(pts, Color(VIOLET.lightened(0.2 * i), 0.3))
	IconDraw._star(ci, P(c, u, 0.6, -0.3), u * 0.15, IVORY)


static func _f_fortune_blade(ci, c, u):
	S(ci, [[-1.1, 0.12], [0.6, 0.12], [0.85, 0.0], [0.6, -0.12], [-1.1, -0.12]], c, u, STEEL)
	S(ci, [[-1.1, -0.35], [-0.95, -0.35], [-0.95, 0.35], [-1.1, 0.35]], c, u, GOLDC)
	IconDraw.die(ci, P(c, u, -1.35, 0), u * 0.22, 6, IVORY, 0.0)


static func _f_second_roll(ci, c, u):
	IconDraw.die(ci, c, u * 0.45, 2, IVORY, 0.3)
	arcp(ci, c, u, 0, 0, 0.85, -0.6, PI * 1.3, GOLDC, 0.08)
	S(ci, [[0.55, -0.85], [0.95, -0.7], [0.65, -0.4]], c, u, GOLDC, false)


static func _f_lucky_strike(ci, c, u):
	for k in 4:
		var a = k * PI / 2.0 + PI / 4.0
		IconDraw.oval(ci, c + Vector2(cos(a), sin(a)) * u * 0.32, u * 0.3, u * 0.22, Palette.GOOD, 1.5, a)
	L(ci, c, u, [0, 0.2], [0.2, 0.9], Palette.GOOD.darkened(0.3), 0.07)
	L(ci, c, u, [-1.3, -0.8], [1.3, 0.75], Color(1, 1, 1, 0.75), 0.05)


static func _f_charm_ward(ci, c, u):
	ci.draw_arc(P(c, u, 0, -0.55), u * 0.55, 0.3, PI - 0.3, 20, GOLDC, u * 0.05, true)
	S(ci, [[0, -0.15], [0.45, 0.3], [0, 0.85], [-0.45, 0.3]], c, u, GOLDC)
	S(ci, [[0, 0.05], [0.25, 0.32], [0, 0.65], [-0.25, 0.32]], c, u, VIOLET)
	IconDraw.glow(ci, P(c, u, 0, 0.35), u * 0.6, VIOLET, 3)


static func _f_gamble(ci, c, u):
	IconDraw.die(ci, P(c, u, -0.5, 0.2), u * 0.38, 1, IVORY, -0.4)
	IconDraw.die(ci, P(c, u, 0.55, -0.15), u * 0.38, 6, Color("ffd2d2"), 0.5)
	for i in 3:
		L(ci, c, u, [-1.25 + i * 0.1, -0.6 + i * 0.3], [-0.95 + i * 0.1, -0.55 + i * 0.3], Color(1, 1, 1, 0.4), 0.04)


static func _f_tilt(ci, c, u):
	OL(ci, c, u, [0, 0.85], [0, -0.55], GOLDC, 0.06)
	OL(ci, c, u, [-1.0, -0.15], [1.0, -0.65], GOLDC, 0.06)
	for side in [[-1.0, -0.15], [1.0, -0.65]]:
		ci.draw_arc(P(c, u, side[0], side[1] + 0.35), u * 0.3, 0, PI, 12, GOLDC, u * 0.05, true)
	IconDraw.die(ci, P(c, u, -1.0, 0.05), u * 0.16, 6, IVORY, 0.0)


static func _f_omen(ci, c, u):
	S(ci, [[-0.9, 0.3], [-0.2, -0.2], [0.3, -0.15], [0.7, -0.45], [0.75, -0.3], [0.45, 0.0], [1.2, 0.2], [0.3, 0.3], [-0.2, 0.55]], c, u, Color("1b1726"))
	ci.draw_circle(P(c, u, 0.55, -0.3), u * 0.06, Palette.BAD)
	IconDraw.eye(ci, P(c, u, -0.9, -0.55), u * 0.2, Vector2(0.5, 0.3), VIOLET)


static func _f_dealers_hand(ci, c, u):
	for i in 3:
		card_rect(ci, P(c, u, -0.45 + i * 0.45, 0.15 + absf(i - 1) * 0.1), u * 0.32, u * 0.5, (i - 1) * 0.35, Color("2a2140").lightened(i * 0.1), [Palette.BAD, GOLDC, VIOLET][i])


static func _f_coin_toss(ci, c, u):
	ci.draw_arc(P(c, u, -0.2, 0.7), u * 0.9, PI * 1.1, PI * 1.7, 18, Color(1, 1, 1, 0.3), u * 0.04, true)
	coin(ci, P(c, u, 0.35, -0.25), u * 0.4, u * 0.16)
	IconDraw.ball(ci, P(c, u, -0.9, 0.65), u * 0.15, Color("e9c9b4"), 1.5)


static func _f_hedge_bet(ci, c, u):
	chips(ci, P(c, u, -0.6, 0.55), u * 0.35, 5, Palette.BAD)
	IconDraw.icon(ci, "shield", P(c, u, 0.55, 0.0), u * 0.6, Palette.BLOCK)


static func _f_high_roller(ci, c, u):
	for i in 3:
		IconDraw.die(ci, P(c, u, -0.9 + i * 0.9, 0.35 - (i % 2) * 0.45), u * 0.28, 6 - i, IVORY, i * 0.4 - 0.4)
	for k in 8:
		var a = k * TAU / 8.0
		L(ci, c, u, [cos(a) * 0.3, sin(a) * 0.3], [cos(a) * 0.55, sin(a) * 0.55], Color(GOLDC, 0.5), 0.04)
	IconDraw.icon(ci, "crown", P(c, u, 0, -0.75), u * 0.25, GOLDC)


static func _f_card_trick(ci, c, u):
	S(ci, [[-0.55, 0.85], [0.55, 0.85], [0.45, 0.2], [-0.45, 0.2]], c, u, Color("1b1726"))
	S(ci, [[-0.7, 0.2], [0.7, 0.2], [0.7, 0.05], [-0.7, 0.05]], c, u, Color("1b1726"))
	for i in 3:
		card_rect(ci, P(c, u, -0.5 + i * 0.5, -0.35 - (1 - absf(i - 1)) * 0.2), u * 0.22, u * 0.32, (i - 1) * 0.5, IVORY, Palette.BAD if i != 1 else VIOLET)
	spark(ci, P(c, u, 1.0, -0.6), u * 0.18, GOLDC)


static func _f_jackpot(ci, c, u):
	S(ci, [[-1.1, -0.75], [1.1, -0.75], [1.1, 0.75], [-1.1, 0.75]], c, u, Palette.BAD.darkened(0.25))
	for i in 3:
		var r = Rect2(P(c, u, -0.95 + i * 0.65, -0.45), Vector2(0.55, 0.9) * u)
		ci.draw_rect(r, IVORY)
		ci.draw_string(UI.font(), r.position + Vector2(0, r.size.y * 0.78), "7", HORIZONTAL_ALIGNMENT_CENTER, r.size.x, int(u * 0.8), Palette.BAD)
	OL(ci, c, u, [1.2, -0.2], [1.45, -0.6], STEEL, 0.05)
	B(ci, c, u, 1.45, -0.65, 0.1, Palette.BAD)


static func _f_destiny(ci, c, u):
	var six = [[-0.35, -0.6], [0.35, -0.6], [-0.35, 0.0], [0.35, 0.0], [-0.35, 0.6], [0.35, 0.6]]
	for i in six.size():
		IconDraw._star(ci, P(c, u, six[i][0], six[i][1]), u * 0.14, IVORY)
	for pair in [[0, 2], [2, 4], [1, 3], [3, 5]]:
		L(ci, c, u, six[pair[0]], six[pair[1]], Color(VIOLET, 0.7), 0.035)
	IconDraw.glow(ci, c, u * 0.9, VIOLET, 3)


static func _f_loaded(ci, c, u):
	IconDraw.die(ci, P(c, u, -0.25, 0.1), u * 0.5, 6, IVORY, 0.15)
	B(ci, c, u, 0.7, 0.45, 0.28, Color("6e6a73"))
	ci.draw_string(UI.font(), P(c, u, 0.42, 0.55), "Pb", HORIZONTAL_ALIGNMENT_CENTER, u * 0.56, int(u * 0.3), IVORY)
	L(ci, c, u, [0.25, 0.3], [0.45, 0.4], STEEL, 0.04)


static func _f_fourth_die(ci, c, u):
	var vals = [3, 5, 6, 4]
	var pos = [[-0.95, 0.0], [0.0, -0.5], [0.95, 0.0], [0.0, 0.5]]
	for i in 4:
		IconDraw.die(ci, P(c, u, pos[i][0], pos[i][1]), u * 0.27, vals[i], GOLDC.lightened(0.5) if i == 3 else IVORY, i * 0.3)


static func _f_double_down(ci, c, u):
	IconDraw.die(ci, P(c, u, -0.45, 0.05), u * 0.45, 3, IVORY, -0.1)
	ci.draw_string(UI.font(), P(c, u, 0.15, 0.4), "x2", HORIZONTAL_ALIGNMENT_LEFT, -1, int(u * 0.9), GOLDC)
	S(ci, [[1.15, -0.2], [1.35, -0.55], [1.55, -0.2]], c, u, GOLDC, false)


static func _f_fortune_shield(ci, c, u):
	IconDraw.icon(ci, "shield", c, u * 0.85, VIOLET.darkened(0.15))
	IconDraw.die(ci, P(c, u, 0, -0.05), u * 0.3, 5, IVORY, 0.0)


static func _f_critical_fate(ci, c, u):
	for k in 10:
		var a = k * TAU / 10.0
		L(ci, c, u, [cos(a) * 0.45, sin(a) * 0.45], [cos(a) * 0.95, sin(a) * 0.95], Color(GOLDC, 0.6), 0.05)
	IconDraw.die(ci, c, u * 0.42, 6, Color("ffe29a"), 0.2)
	IconDraw.icon(ci, "bolt", P(c, u, 0.85, -0.55), u * 0.28, Palette.ENERGY)


static func _f_all_in(ci, c, u):
	for i in 4:
		chips(ci, P(c, u, -1.0 + i * 0.65, 0.65), u * 0.3, 3 + i, [Palette.BAD, Palette.SKILL, Palette.GOOD, GOLDC][i])
	for side in [-1.0, 1.0]:
		S(ci, [[side * 1.55, 0.2], [side * 1.2, 0.0], [side * 1.2, 0.5]], c, u, Color("e9c9b4"))


static func _f_rewrite(ci, c, u):
	S(ci, [[-1.1, -0.55], [0.6, -0.55], [0.6, 0.65], [-1.1, 0.65]], c, u, Color("efe2c0"))
	for i in 3:
		L(ci, c, u, [-0.9, -0.3 + i * 0.25], [0.1, -0.3 + i * 0.25], Color(DARK, 0.5), 0.03)
	ci.draw_string(UI.font(), P(c, u, -0.95, 0.6), "6", HORIZONTAL_ALIGNMENT_LEFT, -1, int(u * 0.6), Palette.BAD)
	S(ci, [[0.3, 0.45], [1.3, -0.75], [1.4, -0.6], [0.4, 0.55]], c, u, IVORY)
	L(ci, c, u, [0.3, 0.45], [0.2, 0.6], DARK, 0.04)


static func _f_twist_of_fate(ci, c, u):
	var pts = PackedVector2Array()
	for i in 40:
		var t = float(i) / 39.0
		var a = t * TAU * 2.2
		pts.append(c + Vector2(cos(a), sin(a)) * u * (0.15 + t * 0.75))
	ci.draw_polyline(pts, IconDraw.OUTLINE, u * 0.1, true)
	ci.draw_polyline(pts, GOLDC, u * 0.06, true)
	IconDraw.die(ci, c, u * 0.2, 6, IVORY, 0.6)


static func _f_house_edge(ci, c, u):
	var rad = u * 0.85
	for k in 12:
		var a0 = k * TAU / 12.0
		var pts = PackedVector2Array([c])
		for j in 4:
			var a = a0 + j * (TAU / 12.0) / 3.0
			pts.append(c + Vector2(cos(a), sin(a)) * rad)
		ci.draw_colored_polygon(pts, Palette.BAD.darkened(0.2) if k % 2 == 0 else Color("1b1726"))
	ci.draw_arc(c, rad, 0, TAU, 36, GOLDC, u * 0.07, true)
	B(ci, c, u, 0, 0, 0.22, GOLDC)
	B(ci, c, u, 0.55, -0.45, 0.08, IVORY)


# ================================================================== DUSKDANCER

static func _d_lash(ci, c, u):
	IconDraw.ribbon(ci, P(c, u, -1.3, 0.6), Vector2(1, -0.55).normalized(), u * 2.6, u * 0.22, PINK, 0.5, 1.2)
	spark(ci, P(c, u, 1.15, -0.7), u * 0.25, IVORY)


static func _d_pirouette(ci, c, u):
	for i in 3:
		IconDraw.oval(ci, P(c, u, 0, 0.55 - i * 0.12), u * (1.1 - i * 0.2), u * 0.2, Color(TEAL, 0.0), 0.0)
		ci.draw_arc(P(c, u, 0, 0.55 - i * 0.12), u * (1.1 - i * 0.25), 0.2, PI - 0.2, 20, Color(TEAL, 0.6 - i * 0.15), u * 0.05, true)
	dancer(ci, c, u, 0, -0.05, 0.75, TEAL, "spin")


static func _d_crescendo(ci, c, u):
	for i in 4:
		note(ci, P(c, u, -1.2 + i * 0.75, 0.75 - i * 0.35), u * (0.35 + i * 0.12), GOLDC.lerp(PINK, i / 3.0))
	L(ci, c, u, [-1.4, 0.85], [1.4, -0.35], Color(1, 1, 1, 0.2), 0.03)
	L(ci, c, u, [-1.4, 0.95], [1.4, 0.95], Color(1, 1, 1, 0.2), 0.03)


static func _d_light_step(ci, c, u):
	for i in 3:
		var x = -1.0 + i * 0.85
		var y = 0.45 - i * 0.35 + (0.15 if i % 2 == 0 else 0.0)
		IconDraw.oval(ci, P(c, u, x, y), u * 0.17, u * 0.28, Color(TEAL, 0.85), 1.5, 0.3)
		ci.draw_circle(P(c, u, x + 0.05, y - 0.4), u * 0.09, Color(TEAL, 0.85))
	spark(ci, P(c, u, 1.2, -0.65), u * 0.2, IVORY)


static func _d_fan_kick(ci, c, u):
	var o = P(c, u, 0, 0.65)
	for k in 9:
		var a = PI + 0.15 + k * (PI - 0.3) / 8.0
		ci.draw_line(o, o + Vector2(cos(a), sin(a)) * u * 1.25, Color(PINK.darkened(0.2), 0.95), u * 0.05, true)
	var pts = PackedVector2Array([o])
	for k in 17:
		var a2 = PI + 0.15 + k * (PI - 0.3) / 16.0
		pts.append(o + Vector2(cos(a2), sin(a2)) * u * 1.25)
	ci.draw_colored_polygon(pts, Color(PINK, 0.55))
	B(ci, c, u, 0, 0.65, 0.12, GOLDC)


static func _d_twirl(ci, c, u):
	var pts = PackedVector2Array()
	for i in 50:
		var t = float(i) / 49.0
		var a = t * TAU * 2.6
		pts.append(c + Vector2(cos(a) * 1.4, sin(a) * 0.85) * u * (0.1 + t * 0.9))
	ci.draw_polyline(pts, IconDraw.OUTLINE, u * 0.16, true)
	ci.draw_polyline(pts, TEAL, u * 0.1, true)


static func _d_flourish(ci, c, u):
	for k in 6:
		var a = k * TAU / 6.0
		IconDraw.oval(ci, c + Vector2(cos(a), sin(a)) * u * 0.38, u * 0.3, u * 0.17, PINK.lerp(Palette.BAD, 0.3), 1.5, a)
	B(ci, c, u, 0, 0, 0.2, GOLDC)
	for k in 4:
		spark(ci, P(c, u, cos(k * 1.7) * 1.2, sin(k * 1.7) * 0.75), u * 0.13, IVORY)


static func _d_tempo(ci, c, u):
	S(ci, [[-0.5, 0.85], [0.5, 0.85], [0.18, -0.85], [-0.18, -0.85]], c, u, Color("6e4a2a"))
	S(ci, [[-0.32, 0.4], [0.32, 0.4], [0.28, 0.6], [-0.28, 0.6]], c, u, IVORY, false)
	OL(ci, c, u, [0, 0.5], [0.5, -0.65], GOLDC, 0.05)
	B(ci, c, u, 0.38, -0.35, 0.09, GOLDC)
	ci.draw_arc(P(c, u, 0, 0.5), u * 1.25, PI * 1.3, PI * 1.7, 14, Color(1, 1, 1, 0.3), u * 0.04, true)


static func _d_downbeat(ci, c, u):
	IconDraw.oval(ci, P(c, u, 0, 0.45), u * 0.85, u * 0.28, Palette.BAD.darkened(0.2), 1.5)
	S(ci, [[-0.85, 0.45], [0.85, 0.45], [0.85, 0.05], [-0.85, 0.05]], c, u, Palette.BAD.darkened(0.2))
	IconDraw.oval(ci, P(c, u, 0, 0.05), u * 0.85, u * 0.28, IVORY, 1.5)
	OL(ci, c, u, [0.9, -0.8], [0.15, -0.05], Color("c9a26b"), 0.06)
	for i in 3:
		arcp(ci, c, u, 0.1, 0.0, 0.3 + i * 0.18, PI * 1.15, PI * 1.85, Color(1, 1, 1, 0.5 - i * 0.12), 0.04)


static func _d_veil_dance(ci, c, u):
	for side in [-1.0, 1.0]:
		var pts = PackedVector2Array()
		for k in 14:
			var t = float(k) / 13.0
			pts.append(P(c, u, side * (0.1 + t * 1.3), -0.7 + t * 1.4 + sin(t * 6.0) * 0.15))
		pts.append(P(c, u, side * 0.1, 0.8))
		ci.draw_colored_polygon(pts, Color(TEAL if side < 0 else PINK, 0.45))
	dancer(ci, c, u, 0, 0.0, 0.6, Color("4a4166"), "spin")


static func _d_leap(ci, c, u):
	ci.draw_arc(P(c, u, 0, 1.1), u * 1.3, PI * 1.15, PI * 1.85, 24, Color(1, 1, 1, 0.3), u * 0.04, true)
	dancer(ci, c, u, 0, -0.15, 0.75, TEAL, "leap")


static func _d_spin_kick(ci, c, u):
	ci.draw_arc(P(c, u, -0.2, 0.0), u * 0.95, -1.4, 0.4, 20, Color(1, 1, 1, 0.45), u * 0.07, true)
	dancer(ci, c, u, -0.35, 0.05, 0.7, TEAL, "kick")
	spark(ci, P(c, u, 0.95, -0.35), u * 0.3, GOLDC)


static func _d_curtsy(ci, c, u):
	dancer(ci, c, u, -0.2, -0.05, 0.85, PINK.darkened(0.1), "bow")
	IconDraw._star(ci, P(c, u, 0.95, -0.55), u * 0.15, GOLDC)


static func _d_grace(ci, c, u):
	S(ci, [[0.9, -0.85], [0.55, 0.0], [-0.6, 0.75], [-0.1, -0.1]], c, u, IVORY)
	L(ci, c, u, [0.85, -0.8], [-0.85, 0.95], STEEL.darkened(0.3), 0.04)
	for i in 4:
		L(ci, c, u, [0.6 - i * 0.35, -0.5 + i * 0.35], [0.95 - i * 0.35, -0.25 + i * 0.35], Color(STEEL, 0.5), 0.025)


static func _d_rhythm(ci, c, u):
	var hs = [0.4, 0.8, 1.3, 0.9, 1.5, 0.7, 1.1, 0.5]
	for i in hs.size():
		var x = -1.3 + i * 0.37
		S(ci, [[x - 0.12, 0.8], [x + 0.12, 0.8], [x + 0.12, 0.8 - hs[i]], [x - 0.12, 0.8 - hs[i]]], c, u, TEAL.lerp(GOLDC, i / 7.0), false)


static func _d_finale(ci, c, u):
	var spots = [[-0.9, -0.3, PINK], [0.2, -0.55, GOLDC], [1.0, 0.0, TEAL]]
	for sp in spots:
		for k in 12:
			var a = k * TAU / 12.0
			L(ci, c, u, [sp[0] + cos(a) * 0.1, sp[1] + sin(a) * 0.1], [sp[0] + cos(a) * 0.45, sp[1] + sin(a) * 0.45], sp[2], 0.04)
	L(ci, c, u, [-0.9, -0.3], [-0.8, 0.9], Color(1, 1, 1, 0.25), 0.03)


static func _d_encore(ci, c, u):
	for side in [-1.0, 1.0]:
		S(ci, [[side * 1.55, -0.95], [side * 0.45, -0.95], [side * 0.75, 0.95], [side * 1.55, 0.95]], c, u, Color("8a1f3a"))
	for i in 3:
		var p = P(c, u, -0.3 + i * 0.3, 0.65 - (i % 2) * 0.15)
		IconDraw.ball(ci, p, u * 0.11, Palette.BAD, 1.2)
		ci.draw_line(p, p + Vector2(0.1, 0.25) * u, Palette.GOOD, u * 0.04)


static func _d_sway(ci, c, u):
	for i in 4:
		var pts = PackedVector2Array()
		for k in 20:
			var t = float(k) / 19.0
			pts.append(P(c, u, -1.4 + t * 2.8, -0.55 + i * 0.36 + sin(t * TAU * 1.2 + i * 0.8) * 0.15))
		ci.draw_polyline(pts, Color(TEAL.lerp(PINK, i / 3.0), 0.85), u * 0.07, true)


static func _d_ribbon_storm(ci, c, u):
	for i in 4:
		var a = i * TAU / 4.0
		IconDraw.ribbon(ci, c + Vector2(cos(a), sin(a)) * u * 0.15, Vector2(cos(a + 0.6), sin(a + 0.6)), u * 1.0, u * 0.14, [PINK, TEAL, GOLDC, VIOLET][i], float(i), 1.3)


static func _d_tango(ci, c, u):
	OL(ci, c, u, [-1.2, 0.7], [0.4, -0.2], Palette.GOOD.darkened(0.2), 0.06)
	S(ci, [[-0.4, 0.25], [-0.1, 0.1], [-0.25, 0.4]], c, u, Palette.GOOD, false)
	for k in 5:
		var a = k * TAU / 5.0
		IconDraw.oval(ci, P(c, u, 0.55, -0.3) + Vector2(cos(a), sin(a)) * u * 0.2, u * 0.22, u * 0.15, Palette.BAD, 1.5, a)
	B(ci, c, u, 0.55, -0.3, 0.14, Palette.BAD.darkened(0.3))


static func _d_spotlight(ci, c, u):
	var pts = PackedVector2Array([P(c, u, -0.2, -1.0), P(c, u, 0.2, -1.0), P(c, u, 1.0, 0.9), P(c, u, -1.0, 0.9)])
	ci.draw_polygon(pts, PackedColorArray([Color(GOLDC, 0.75), Color(GOLDC, 0.75), Color(GOLDC, 0.05), Color(GOLDC, 0.05)]))
	IconDraw.oval(ci, P(c, u, 0, 0.82), u * 1.0, u * 0.14, Color(GOLDC, 0.4), 0.0)
	dancer(ci, c, u, 0, 0.15, 0.6, TEAL, "spin")


static func _d_grand_jete(ci, c, u):
	B(ci, c, u, 1.0, -0.45, 0.4, Color("f6e7a8"))
	dancer(ci, c, u, -0.25, 0.0, 0.85, TEAL.darkened(0.2), "leap")
	IconDraw.ribbon(ci, P(c, u, -0.8, 0.1), Vector2(-1, 0.3).normalized(), u * 0.8, u * 0.12, PINK, 1.0, 1.0)


static func _d_ovation(ci, c, u):
	for side in [-1.0, 1.0]:
		S(ci, [[side * 0.15, 0.8], [side * 0.65, 0.75], [side * 0.6, -0.35], [side * 0.45, -0.55], [side * 0.15, -0.3]], c, u, Color("e9c9b4"))
	for k in 6:
		var a = -PI / 2 + (k - 2.5) * 0.45
		L(ci, c, u, [cos(a) * 0.8, sin(a) * 0.8 - 0.1], [cos(a) * 1.1, sin(a) * 1.1 - 0.1], GOLDC, 0.05)
	IconDraw._star(ci, P(c, u, -1.2, -0.5), u * 0.17, GOLDC)
	IconDraw._star(ci, P(c, u, 1.2, -0.55), u * 0.14, GOLDC)


static func _d_masquerade(ci, c, u):
	var pts: Array = [[-1.25, -0.35], [-0.6, -0.6], [0.0, -0.35], [0.6, -0.6], [1.25, -0.35], [1.0, 0.35], [0.3, 0.4], [0.0, 0.1], [-0.3, 0.4], [-1.0, 0.35]]
	S(ci, pts, c, u, Color("4a4166"))
	IconDraw.oval(ci, P(c, u, -0.55, -0.05), u * 0.28, u * 0.15, Color("141020"), 1.2)
	IconDraw.oval(ci, P(c, u, 0.55, -0.05), u * 0.28, u * 0.15, Color("141020"), 1.2)
	for k in 3:
		IconDraw.oval(ci, P(c, u, 1.15 + k * 0.12, -0.75 + k * 0.08), u * 0.08, u * 0.32, [PINK, TEAL, GOLDC][k], 1.0, 0.4 + k * 0.2)


static func _d_pas_de_deux(ci, c, u):
	IconDraw.ribbon(ci, P(c, u, -1.3, 0.5), Vector2(1, -0.4).normalized(), u * 2.5, u * 0.16, PINK, 0.0, 1.0)
	IconDraw.ribbon(ci, P(c, u, -1.3, -0.4), Vector2(1, 0.35).normalized(), u * 2.5, u * 0.16, TEAL, 2.0, 1.0)
	IconDraw.icon(ci, "heart", c, u * 0.3, Palette.BAD)


# ================================================================== CURSES

static func _x_wound(ci, c, u):
	S(ci, [[-1.0, -0.35], [1.0, 0.15], [0.9, 0.5], [-1.1, 0.0]], c, u, Color("e8dcc8"))
	var pts = PackedVector2Array([P(c, u, -0.2, -0.6), P(c, u, 0.05, -0.15), P(c, u, -0.1, 0.15), P(c, u, 0.15, 0.7)])
	ci.draw_polyline(pts, Palette.BAD, u * 0.08, true)


static func _x_doubt(ci, c, u):
	for i in 4:
		B(ci, c, u, -0.6 + i * 0.4, 0.15 + (i % 2) * 0.12, 0.38, Color("4a4560"))
	ci.draw_string(UI.font(), P(c, u, -0.4, 0.45), "?", HORIZONTAL_ALIGNMENT_CENTER, u * 0.8, int(u * 1.1), Palette.DEBUFF)
