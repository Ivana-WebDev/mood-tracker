class_name EnemyArt
## Extra enemy portraits (shaded vector, animated). Same coordinate convention as IconDraw.creature:
## c = body centre, s = scale; feet rest at y = +1.0, heads reach to about y = -1.3.

const OUT := Color(0.03, 0.035, 0.06, 0.92)


static func has(kind: String) -> bool:
	return kind in ["moth", "crab", "mushroom", "treant", "bell", "spider", "spider_queen", "mimic", "serpent", "gargoyle", "mirror"]


static func draw(ci: CanvasItem, kind: String, c: Vector2, s: float, col: Color, t: float, facing: float) -> void:
	match kind:
		"moth": _moth(ci, c, s * 1.25, col, t)
		"crab": _crab(ci, c, s, col, t, facing)
		"mushroom": _mushroom(ci, c, s, col, t, facing)
		"treant": _treant(ci, c, s, col, t)
		"bell": _bell(ci, c, s, col, t)
		"spider": _spider(ci, c, s, col, t, false)
		"spider_queen": _spider(ci, c, s, col, t, true)
		"mimic": _mimic(ci, c, s, col, t, facing)
		"serpent": _serpent(ci, c - Vector2(0, 0.05) * s, s * 1.12, col, t, facing)
		"gargoyle": _gargoyle(ci, c, s, col, t)
		"mirror": _mirror(ci, c, s, col, t)


# ---------------------------------------------------------------- helpers

static func _p(c: Vector2, s: float, x: float, y: float) -> Vector2:
	return c + Vector2(x, y) * s


static func _sh(ci: CanvasItem, arr: Array, c: Vector2, s: float, col: Color, shade: bool = true) -> void:
	IconDraw.shape(ci, arr, c, s, col, shade)


static func _mirror_x(arr: Array) -> Array:
	var out: Array = []
	for i in range(arr.size() - 1, -1, -1):
		out.append([-float(arr[i][0]), arr[i][1]])
	return out


## Thick outlined limb through a list of points.
static func _limb(ci: CanvasItem, pts: PackedVector2Array, w: float, col: Color) -> void:
	ci.draw_polyline(pts, OUT, w + 3.0, true)
	ci.draw_polyline(pts, col, w, true)
	ci.draw_polyline(pts, Color(1, 1, 1, 0.12), maxf(1.0, w * 0.3), true)


static func _ow(s: float) -> float:
	return maxf(1.5, s * 0.035)


# ---------------------------------------------------------------- Lantern Moth

static func _moth(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float) -> void:
	var flap := 0.75 + 0.25 * sin(t * 7.0)
	var c2 := c + Vector2(0, -0.25) * s
	for sgn in [-1.0, 1.0]:
		var sg: float = sgn
		var up: Array = [[0.08 * sg, -0.1], [0.55 * sg * flap, -0.85], [1.05 * sg * flap, -0.95], [1.2 * sg * flap, -0.55], [0.95 * sg * flap, -0.15], [0.1 * sg, 0.05]]
		var lo: Array = [[0.08 * sg, 0.05], [0.8 * sg * flap, 0.05], [0.95 * sg * flap, 0.45], [0.6 * sg * flap, 0.75], [0.15 * sg, 0.35]]
		if sg < 0:
			up.reverse()
			lo.reverse()
		_sh(ci, lo, c2, s, col.darkened(0.25))
		_sh(ci, up, c2, s, col)
		# Wing patterns: vein lines + eye spots.
		for k in 3:
			ci.draw_line(_p(c2, s, 0.1 * sg, -0.05), _p(c2, s, (0.55 + k * 0.25) * sg * flap, -0.88 + k * 0.22), Color(col.darkened(0.45), 0.6), maxf(1.0, s * 0.015), true)
		var ep := _p(c2, s, 0.72 * sg * flap, -0.55)
		IconDraw.oval(ci, ep, s * 0.17 * flap, s * 0.15, col.darkened(0.55), 1.5)
		IconDraw.oval(ci, ep, s * 0.1 * flap, s * 0.09, Color("ffe9a8"), 0.0)
		ci.draw_circle(ep, s * 0.045, OUT)
		IconDraw.oval(ci, _p(c2, s, 0.55 * sg * flap, 0.38), s * 0.09 * flap, s * 0.08, Color(col.lightened(0.35), 0.8), 1.0)
		# Feathery antennae.
		var a0 := _p(c2, s, 0.06 * sg, -0.45)
		var a1 := _p(c2, s, 0.38 * sg, -1.0 + sin(t * 3.0 + sg) * 0.03)
		ci.draw_line(a0, a1, OUT, maxf(1.5, s * 0.03), true)
		for k in 5:
			var q := a0.lerp(a1, 0.3 + k * 0.15)
			ci.draw_line(q, q + Vector2(0.08 * sg, -0.04) * s, Color(col.lightened(0.2), 0.9), maxf(1.0, s * 0.015), true)
	# Fuzzy body segments.
	var body: Array = [[0.0, -0.5], [0.0, -0.25], [0.0, 0.05], [0.0, 0.35]]
	for i in body.size():
		var r := s * (0.17 - i * 0.015)
		IconDraw.ball(ci, _p(c2, s, body[i][0], body[i][1]), r, Color("e7d6b0").darkened(i * 0.08), _ow(s))
	# Glowing lantern abdomen.
	var lp := _p(c2, s, 0.0, 0.62)
	IconDraw.glow(ci, lp, s * (0.38 + 0.04 * sin(t * 4.0)), Color("ffcf4a"), 5)
	IconDraw.ball(ci, lp, s * 0.16, Color("ffd97a"), _ow(s))
	ci.draw_circle(lp + Vector2(-0.05, -0.05) * s, s * 0.05, Color(1, 1, 1, 0.8))
	IconDraw.eye(ci, _p(c2, s, -0.07, -0.53), s * 0.07, Vector2(-0.4, 0.2), Color("2a1630"))
	IconDraw.eye(ci, _p(c2, s, 0.07, -0.53), s * 0.07, Vector2(-0.4, 0.2), Color("2a1630"))
	# Drifting dust.
	for i in 5:
		var ph := fmod(t * 0.4 + i * 0.21, 1.0)
		ci.draw_circle(_p(c, s, -0.8 + i * 0.4, 0.6 - ph * 0.9), s * 0.02, Color("ffe9a8", 0.6 * (1.0 - ph)))


# ---------------------------------------------------------------- Shellback Crab

static func _crab(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float, facing: float) -> void:
	var leg_col := col.darkened(0.2)
	for sgn in [-1.0, 1.0]:
		var sg: float = sgn
		for k in 3:
			var wob := sin(t * 4.0 + k + sg) * 0.03
			var base := _p(c, s, 0.45 * sg, 0.35 + k * 0.1)
			var knee := _p(c, s, (0.85 + k * 0.08) * sg, 0.25 + k * 0.12 + wob)
			var foot := _p(c, s, (1.0 + k * 0.05) * sg, 0.98)
			_limb(ci, PackedVector2Array([base, knee, foot]), s * 0.07, leg_col)
	# Claws: the front one is huge.
	var snap := absf(sin(t * 2.2)) * 0.18
	for sgn in [-1.0, 1.0]:
		var sg: float = sgn
		var big := sg == facing
		var sc := 1.25 if big else 0.85
		var arm0 := _p(c, s, 0.5 * sg, 0.0)
		var arm1 := _p(c, s, 0.85 * sg, -0.35)
		_limb(ci, PackedVector2Array([arm0, arm1]), s * 0.11, leg_col)
		var cp := arm1 + Vector2(0.05 * sg, -0.05) * s * sc
		var upper: Array = [[-0.2, 0.1], [-0.05, -0.32], [0.3, -0.38], [0.42, -0.2], [0.15, -0.12], [0.1, 0.05]]
		var lower: Array = [[-0.15, 0.12], [0.1, 0.05 + snap], [0.36, 0.0 + snap], [0.3, 0.2 + snap * 0.5], [0.0, 0.25]]
		if sg < 0:
			upper = _mirror_x(upper)
			lower = _mirror_x(lower)
		_sh(ci, lower, cp, s * sc, col.darkened(0.1))
		_sh(ci, upper, cp, s * sc, col.lightened(0.05))
	# Carapace.
	var shell := PackedVector2Array()
	for i in 25:
		var a := PI + i * PI / 24.0
		shell.append(_p(c, s, cos(a) * 0.8, 0.45 + sin(a) * 0.7))
	shell.append(_p(c, s, 0.6, 0.6))
	shell.append(_p(c, s, -0.6, 0.6))
	IconDraw.fill(ci, shell, col, _ow(s))
	# Ridges, barnacles and moss.
	for k in 3:
		ci.draw_arc(_p(c, s, 0, 0.45), s * (0.25 + k * 0.17), PI * 1.12, PI * 1.88, 18, Color(col.darkened(0.4), 0.7), maxf(1.0, s * 0.025), true)
	for b in [[-0.45, 0.05], [-0.3, -0.12], [0.35, -0.02], [0.15, -0.18]]:
		IconDraw.ball(ci, _p(c, s, b[0], b[1]), s * 0.06, Color("e9e2cf"), 1.0)
		ci.draw_circle(_p(c, s, b[0], b[1]), s * 0.025, OUT)
	for i in 6:
		IconDraw.oval(ci, _p(c, s, -0.5 + i * 0.2, -0.17 + absf(i - 2.5) * 0.06), s * 0.08, s * 0.035, Color("6fbf73", 0.8), 0.0, 0.3 * i)
	# Eye stalks.
	for ex in [-0.18, 0.18]:
		var top := _p(c, s, ex + 0.04 * facing, -0.45 + sin(t * 3.0 + ex * 9.0) * 0.03)
		_limb(ci, PackedVector2Array([_p(c, s, ex, -0.15), top]), s * 0.05, leg_col)
		IconDraw.eye(ci, top, s * 0.09, Vector2(facing * 0.5, 0.1))
	ci.draw_polyline(IconDraw.pts_of([[-0.15, 0.32], [-0.05, 0.36], [0.05, 0.32], [0.15, 0.36]], c, s), OUT, maxf(1.5, s * 0.03))


# ---------------------------------------------------------------- Spore Cap

static func _mushroom(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float, facing: float) -> void:
	var stem := Color("efe2c8")
	var sway := sin(t * 2.0) * 0.04
	# Stubby feet + stem body.
	IconDraw.oval(ci, _p(c, s, -0.22, 0.92), s * 0.18, s * 0.09, stem.darkened(0.2), _ow(s))
	IconDraw.oval(ci, _p(c, s, 0.22, 0.92), s * 0.18, s * 0.09, stem.darkened(0.2), _ow(s))
	_sh(ci, [[-0.38, -0.05], [0.38, -0.05], [0.45, 0.85], [-0.45, 0.85]], c, s, stem)
	# Arms.
	for sgn in [-1.0, 1.0]:
		var sg: float = sgn
		_limb(ci, PackedVector2Array([_p(c, s, 0.38 * sg, 0.25), _p(c, s, 0.6 * sg, 0.45 + sin(t * 3.0 + sg) * 0.05)]), s * 0.08, stem.darkened(0.1))
	# Face.
	var look := Vector2(facing * 0.5, 0.1)
	IconDraw.eye(ci, _p(c, s, -0.15, 0.3), s * 0.1, look)
	IconDraw.eye(ci, _p(c, s, 0.15, 0.3), s * 0.1, look)
	ci.draw_arc(_p(c, s, 0, 0.55), s * 0.08, 0.2, PI - 0.2, 10, OUT, maxf(1.5, s * 0.03), true)
	ci.draw_circle(_p(c, s, -0.28, 0.45), s * 0.05, Color("ff8fb8", 0.5))
	ci.draw_circle(_p(c, s, 0.28, 0.45), s * 0.05, Color("ff8fb8", 0.5))
	# Gills underneath the cap.
	var cc := c + Vector2(sway, 0) * s
	IconDraw.oval(ci, _p(cc, s, 0, 0.0), s * 0.82, s * 0.16, col.darkened(0.55), _ow(s))
	for i in 11:
		var x := -0.7 + i * 0.14
		ci.draw_line(_p(cc, s, x * 0.6, -0.04), _p(cc, s, x, 0.08), Color(col.darkened(0.7), 0.8), 1.0, true)
	# Domed cap with spots.
	var cap := PackedVector2Array()
	for i in 29:
		var a := PI + i * PI / 28.0
		cap.append(_p(cc, s, cos(a) * 0.95, -0.02 + sin(a) * 0.82))
	IconDraw.fill(ci, cap, col, _ow(s))
	for sp in [[-0.5, -0.35, 0.13], [0.0, -0.62, 0.15], [0.45, -0.3, 0.12], [-0.15, -0.25, 0.08], [0.65, -0.12, 0.06], [-0.75, -0.12, 0.06]]:
		IconDraw.oval(ci, _p(cc, s, sp[0], sp[1]), s * sp[2], s * sp[2] * 0.75, Color("fff4e0"), 1.0)
	IconDraw.oval(ci, _p(cc, s, -0.45, -0.58), s * 0.18, s * 0.06, Color(1, 1, 1, 0.3), 0.0, -0.5)
	# Spores.
	for i in 7:
		var ph := fmod(t * 0.35 + i * 0.143, 1.0)
		var sp2 := _p(c, s, -0.8 + i * 0.27 + sin(ph * 6.0 + i) * 0.08, -0.6 - ph * 0.8)
		ci.draw_circle(sp2, s * (0.025 + (i % 3) * 0.01), Color(col.lightened(0.4), 0.7 * (1.0 - ph)))


# ---------------------------------------------------------------- Bramble Matron

static func _treant(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float) -> void:
	var bark := Color("6b4a35")
	var leaf := col
	# Roots.
	for i in 5:
		var x := -0.5 + i * 0.25
		_limb(ci, PackedVector2Array([_p(c, s, x * 0.6, 0.6), _p(c, s, x, 0.85), _p(c, s, x * 1.5, 1.0)]), s * 0.09, bark.darkened(0.15))
	# Branch arms with thorns.
	for sgn in [-1.0, 1.0]:
		var sg: float = sgn
		var sw := sin(t * 1.4 + sg) * 0.05
		var arm := PackedVector2Array([_p(c, s, 0.35 * sg, -0.3), _p(c, s, 0.75 * sg, -0.45 + sw), _p(c, s, 1.0 * sg, -0.15 + sw), _p(c, s, 1.1 * sg, 0.2 + sw)])
		_limb(ci, arm, s * 0.11, bark)
		for k in 3:
			var q := arm[k].lerp(arm[k + 1], 0.5)
			ci.draw_colored_polygon(PackedVector2Array([q + Vector2(-0.03, 0) * s, q + Vector2(0.04 * sg, -0.13) * s, q + Vector2(0.05, 0.01) * s]), Color("e9dcc0"))
		IconDraw.ball(ci, arm[3] + Vector2(0, 0.05) * s, s * 0.09, Color("d9415e"), 1.0)
	# Trunk.
	_sh(ci, [[-0.42, -0.6], [-0.3, -0.85], [0.3, -0.85], [0.42, -0.6], [0.5, 0.7], [-0.5, 0.7]], c, s, bark)
	for i in 4:
		var x := -0.3 + i * 0.2
		ci.draw_polyline(IconDraw.pts_of([[x, -0.55], [x + 0.04, -0.2], [x - 0.03, 0.2], [x + 0.02, 0.6]], c, s), Color(bark.darkened(0.45), 0.8), maxf(1.0, s * 0.02), true)
	# Hollow face with glowing eyes.
	IconDraw.oval(ci, _p(c, s, 0, -0.25), s * 0.26, s * 0.3, Color("1a120d"), _ow(s))
	var fl := 0.7 + 0.3 * sin(t * 4.0)
	for ex in [-0.1, 0.1]:
		IconDraw.glow(ci, _p(c, s, ex, -0.33), s * 0.1, Color("b8ff5a"), 3)
		ci.draw_circle(_p(c, s, ex, -0.33), s * 0.035 * fl + s * 0.015, Color("eaffb0"))
	ci.draw_arc(_p(c, s, 0, -0.08), s * 0.1, PI + 0.4, TAU - 0.4, 10, Color("b8ff5a", 0.6), maxf(1.0, s * 0.02), true)
	# Leafy crown with roses.
	for i in 9:
		var a := PI + 0.15 + i * (PI - 0.3) / 8.0
		var lp := _p(c, s, cos(a) * 0.6, -0.95 + sin(a) * 0.4)
		IconDraw.oval(ci, lp, s * 0.24, s * 0.15, leaf.darkened(0.1 + (i % 2) * 0.15), _ow(s), a + PI / 2)
	for rp in [[-0.35, -1.2], [0.1, -1.32], [0.42, -1.1]]:
		var rpp := _p(c, s, rp[0], rp[1])
		IconDraw.ball(ci, rpp, s * 0.1, Color("e04866"), 1.5)
		ci.draw_arc(rpp, s * 0.05, 0, PI * 1.5, 10, Color("8a1f36"), 1.5, true)
	# Falling petals.
	for i in 3:
		var ph := fmod(t * 0.25 + i * 0.33, 1.0)
		IconDraw.oval(ci, _p(c, s, -0.6 + i * 0.6 + sin(ph * 5.0) * 0.1, -1.0 + ph * 1.9), s * 0.04, s * 0.02, Color("e04866", 1.0 - ph), 0.0, ph * 6.0)


# ---------------------------------------------------------------- The Tolling Bell (boss)

static func _bell(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float) -> void:
	var swing := sin(t * 1.3) * 0.12
	var pivot := _p(c, s, 0, -1.25)
	# Chains up to the pivot.
	for sgn in [-1.0, 1.0]:
		var sg: float = sgn
		var a := pivot + Vector2(0.45 * sg, -0.25) * s
		for k in 6:
			var q := a.lerp(pivot, float(k) / 6.0)
			ci.draw_arc(q, s * 0.04, 0, TAU, 8, Color("8a8fa3"), maxf(1.0, s * 0.02), true)
	var tr := Transform2D(swing, pivot)
	var bp := func(x: float, y: float) -> Vector2: return tr * (Vector2(x, y + 1.25) * s)
	# Clapper eye glowing inside the mouth.
	var eyep: Vector2 = tr * (Vector2(-swing * 0.6, 1.95) * s)
	IconDraw.glow(ci, eyep, s * 0.5, Color("ff5a7a"), 5)
	# Bell body.
	var outline: Array = [[-0.22, -1.2], [0.22, -1.2], [0.35, -1.0], [0.45, -0.5], [0.55, 0.05], [0.85, 0.5], [0.95, 0.65], [-0.95, 0.65], [-0.85, 0.5], [-0.55, 0.05], [-0.45, -0.5], [-0.35, -1.0]]
	var pts := PackedVector2Array()
	for q in outline:
		pts.append(bp.call(q[0], q[1]))
	pts = IconDraw.safe(pts)
	IconDraw.fill(ci, pts, col, _ow(s))
	var lip := PackedVector2Array([bp.call(-0.95, 0.65), bp.call(0.95, 0.65), bp.call(0.9, 0.78), bp.call(-0.9, 0.78)])
	IconDraw.fill(ci, lip, col.darkened(0.25), _ow(s), false)
	# Rune band + crack.
	ci.draw_line(bp.call(-0.5, -0.2), bp.call(0.5, -0.2), Color(col.darkened(0.45)), s * 0.1, true)
	for i in 6:
		var rx := -0.38 + i * 0.15
		var glow_a := 0.4 + 0.6 * absf(sin(t * 2.0 + i))
		ci.draw_line(bp.call(rx, -0.25), bp.call(rx + 0.05, -0.15), Color("ffcf7a", glow_a), maxf(1.0, s * 0.025), true)
	ci.draw_polyline(PackedVector2Array([bp.call(0.25, -0.75), bp.call(0.18, -0.5), bp.call(0.3, -0.3), bp.call(0.22, 0.05)]), OUT, maxf(1.5, s * 0.03), true)
	ci.draw_line(bp.call(-0.3, -0.95), bp.call(-0.38, 0.4), Color(1, 1, 1, 0.22), s * 0.06, true)
	# Mouth darkness + the eye.
	var mouth := PackedVector2Array()
	for i in 17:
		var a := float(i) / 16.0 * PI
		mouth.append(bp.call(cos(a) * 0.8, 0.72 + sin(a) * 0.18))
	ci.draw_colored_polygon(mouth, Color("140c14"))
	IconDraw.ball(ci, eyep, s * 0.2, Color("fff1e0"), _ow(s))
	ci.draw_circle(eyep + Vector2(-0.03, 0.02) * s, s * 0.11, Color("e0284f"))
	ci.draw_circle(eyep + Vector2(-0.03, 0.02) * s, s * 0.05, OUT)
	ci.draw_circle(eyep + Vector2(-0.07, -0.04) * s, s * 0.03, Color.WHITE)
	# Crown handle.
	IconDraw.ball(ci, bp.call(0, -1.28), s * 0.13, col.darkened(0.15), _ow(s))


# ---------------------------------------------------------------- Gloomweaver / Moonless Weaver

static func _spider(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float, queen: bool) -> void:
	var dark := col.darkened(0.45)
	if queen:
		# Web backdrop.
		var wc := _p(c, s, 0, -0.55)
		for i in 8:
			var a := i * TAU / 8.0 + 0.2
			ci.draw_line(wc, wc + Vector2(cos(a), sin(a)) * s * 1.35, Color(0.85, 0.9, 1.0, 0.18), 1.0, true)
		for r in 4:
			var ring := PackedVector2Array()
			for i in 9:
				var a2 := i * TAU / 8.0 + 0.2
				ring.append(wc + Vector2(cos(a2), sin(a2)) * s * (0.4 + r * 0.3))
			ci.draw_polyline(ring, Color(0.85, 0.9, 1.0, 0.14), 1.0, true)
	else:
		ci.draw_line(_p(c, s, 0, -0.2), _p(c, s, 0, -1.6), Color(0.9, 0.9, 1.0, 0.35), 1.0, true)
	# Legs (four each side), jointed.
	for sgn in [-1.0, 1.0]:
		var sg: float = sgn
		for k in 4:
			var wob := sin(t * 3.0 + k * 1.3 + sg) * 0.04
			var base := _p(c, s, 0.2 * sg, 0.15 + k * 0.06)
			var knee := _p(c, s, (0.65 + k * 0.08) * sg, -0.45 + k * 0.22 + wob)
			var foot := _p(c, s, (0.95 + k * 0.12 - (0.25 if k == 3 else 0.0)) * sg, 0.98)
			_limb(ci, PackedVector2Array([base, knee, foot]), s * 0.06, dark)
			ci.draw_circle(knee, s * 0.04, col)
	# Abdomen with markings.
	var ab := _p(c, s, 0, -0.25)
	IconDraw.oval(ci, ab, s * 0.55, s * 0.5, col, _ow(s))
	if queen:
		var mc := ab + Vector2(0, -0.05) * s
		IconDraw.glow(ci, mc, s * 0.35, Color("cfe0ff"), 4)
		ci.draw_circle(mc, s * 0.16, Color("eaf2ff"))
		ci.draw_circle(mc + Vector2(0.07, -0.04) * s, s * 0.14, col)
	else:
		_sh(ci, [[0.0, -0.55], [0.12, -0.35], [0.0, -0.2], [-0.12, -0.35]], c, s, Color("ff5a7a"), false)
		_sh(ci, [[0.0, -0.15], [0.09, 0.0], [0.0, 0.1], [-0.09, 0.0]], c, s, Color("ff5a7a"), false)
	for i in 3:
		ci.draw_arc(ab, s * (0.25 + i * 0.1), PI * 1.15, PI * 1.45, 10, Color(1, 1, 1, 0.12), maxf(1.0, s * 0.02), true)
	# Head with an eye cluster and fangs.
	var hp := _p(c, s, 0, 0.35)
	IconDraw.ball(ci, hp, s * 0.28, col.darkened(0.15), _ow(s))
	var eyes: Array = [[-0.1, -0.06, 0.07], [0.1, -0.06, 0.07], [-0.2, 0.0, 0.045], [0.2, 0.0, 0.045], [-0.05, 0.06, 0.04], [0.05, 0.06, 0.04]]
	var blink := 1.0 if fmod(t, 4.0) > 0.12 else 0.2
	for e in eyes:
		var ep := hp + Vector2(e[0], e[1]) * s
		ci.draw_circle(ep, s * e[2] * blink, Color("ff3355"))
		ci.draw_circle(ep + Vector2(-0.015, -0.015) * s, s * e[2] * 0.35 * blink, Color(1, 1, 1, 0.8))
	for sgn in [-1.0, 1.0]:
		var sg: float = sgn
		_sh(ci, [[0.06 * sg, 0.18], [0.14 * sg, 0.2], [0.08 * sg, 0.38 + sin(t * 5.0) * 0.02]], hp, s, Color("efe6d0"))
	if queen:
		var cr := _p(c, s, 0, -0.78)
		_sh(ci, [[-0.25, 0.0], [-0.3, -0.3], [-0.12, -0.12], [0.0, -0.38], [0.12, -0.12], [0.3, -0.3], [0.25, 0.0]], cr, s, Color("cfd8f0"))
		for gx in [-0.12, 0.0, 0.12]:
			ci.draw_circle(cr + Vector2(gx, -0.06) * s, s * 0.03, Color("7ee8ff"))


# ---------------------------------------------------------------- Gilded Mimic

static func _mimic(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float, facing: float) -> void:
	var wood := Color("7a4a2c")
	var chomp := absf(sin(t * 1.8))
	var lid_a := -0.35 - chomp * 0.3
	# Tongue lolling out.
	var tongue := PackedVector2Array()
	for i in 10:
		var u := float(i) / 9.0
		tongue.append(_p(c, s, facing * (0.1 + u * 0.75), 0.05 + u * 0.55 + sin(u * 4.0 + t * 3.0) * 0.06))
	_limb(ci, tongue, s * 0.14, Color("d9536b"))
	# Box.
	_sh(ci, [[-0.8, -0.05], [0.8, -0.05], [0.75, 0.95], [-0.75, 0.95]], c, s, wood)
	for x in [-0.8, 0.8]:
		_sh(ci, [[x - 0.08, -0.05], [x + 0.08, -0.05], [x * 0.94 + 0.08, 0.95], [x * 0.94 - 0.08, 0.95]], c, s, col)
	_sh(ci, [[-0.8, 0.4], [0.8, 0.4], [0.78, 0.52], [-0.78, 0.52]], c, s, col)
	for i in 4:
		ci.draw_line(_p(c, s, -0.6 + i * 0.4, 0.0), _p(c, s, -0.6 + i * 0.4, 0.38), Color(wood.darkened(0.4), 0.6), 1.0)
	# Lower teeth.
	for i in 8:
		var x := -0.65 + i * 0.185
		_sh(ci, [[x - 0.07, -0.05], [x, -0.22], [x + 0.07, -0.05]], c, s, Color("f4ecd8"), false)
	# Dark maw + eye.
	var hinge := _p(c, s, -0.8 * facing, -0.05)
	var tr := Transform2D(lid_a * facing, hinge)
	var lid_local: Array = [[0.0, 0.0], [1.6, 0.0], [1.6, -0.35], [1.4, -0.55], [0.2, -0.55], [0.0, -0.35]]
	var lid := PackedVector2Array()
	for q in lid_local:
		lid.append(tr * (Vector2(q[0] * facing, q[1]) * s))
	var maw := PackedVector2Array([_p(c, s, -0.75, -0.05), _p(c, s, 0.75, -0.05), lid[1], lid[0]])
	maw = IconDraw.safe(maw)
	ci.draw_colored_polygon(maw, Color("1a0d12"))
	var ep := _p(c, s, 0.0, -0.3 - chomp * 0.15)
	IconDraw.glow(ci, ep, s * 0.22, Color("ffcf4a"), 3)
	IconDraw.eye(ci, ep, s * 0.12, Vector2(facing * 0.6, 0.2), Color("c0263f"))
	# Lid with upper teeth.
	IconDraw.fill(ci, IconDraw.safe(lid), wood.lightened(0.05), _ow(s))
	for i in 8:
		var u := 0.08 + i * 0.12
		var a := tr * (Vector2(u * 1.6 * facing - 0.06, 0.0) * s)
		var b := tr * (Vector2(u * 1.6 * facing, 0.17) * s)
		var d := tr * (Vector2(u * 1.6 * facing + 0.06, 0.0) * s)
		ci.draw_colored_polygon(PackedVector2Array([a, b, d]) if facing > 0 else PackedVector2Array([d, b, a]), Color("f4ecd8"))
	var band0 := tr * (Vector2(0.75 * facing, 0.0) * s)
	var band1 := tr * (Vector2(0.75 * facing, -0.55) * s)
	ci.draw_line(band0, band1, OUT, s * 0.16, true)
	ci.draw_line(band0, band1, col, s * 0.11, true)
	IconDraw.ball(ci, (band0 + band1) * 0.5, s * 0.07, col.lightened(0.3), 1.5)
	# Spilled coins.
	for i in 4:
		var cp := _p(c, s, -0.9 + i * 0.12 * (1 if i % 2 == 0 else 1.3), 0.95 - (i % 2) * 0.05)
		IconDraw.oval(ci, cp, s * 0.08, s * 0.035, Color("ffd34a"), 1.0)


# ---------------------------------------------------------------- Ash Serpent

static func _serpent(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float, facing: float) -> void:
	var f := facing
	# Coiled body: tail at the back, rising to the hooded head.
	var segs: Array = []
	for i in 14:
		var u := float(i) / 13.0
		var x := -f * (0.75 - u * 0.75) + sin(u * 6.5 + t * 1.5) * 0.32 * (1.0 - u * 0.7)
		var y := 0.8 - u * 1.65 + sin(u * 3.3) * 0.18
		segs.append(_p(c, s, x, y))
	for i in segs.size():
		var r := s * (0.15 + 0.14 * sin(float(i) / segs.size() * PI * 0.85 + 0.25))
		var cc := col if i % 2 == 0 else col.darkened(0.25)
		IconDraw.ball(ci, segs[i], r, cc, _ow(s))
		ci.draw_circle(segs[i] + Vector2(f * r * 0.35, r * 0.2), r * 0.45, Color("f2c96b", 0.5))
	# Hood.
	var hp: Vector2 = segs[13]
	var hood: Array = [[0.0, -0.35], [0.35, -0.15], [0.42, 0.2], [0.15, 0.32], [-0.15, 0.32], [-0.42, 0.2], [-0.35, -0.15]]
	_sh(ci, hood, hp, s, col.darkened(0.15))
	for sgn in [-1.0, 1.0]:
		IconDraw.oval(ci, hp + Vector2(0.22 * sgn, 0.05) * s, s * 0.07, s * 0.1, Color("f2c96b"), 1.0)
		ci.draw_circle(hp + Vector2(0.22 * sgn, 0.05) * s, s * 0.035, OUT)
	# Head + ember eyes + tongue.
	var head := hp + Vector2(f * 0.08, -0.05) * s
	_sh(ci, [[-0.18, -0.15], [0.18, -0.15], [0.25, 0.05], [0.0, 0.18], [-0.25, 0.05]], head, s, col.lightened(0.05))
	for ex in [-0.08, 0.08]:
		IconDraw.glow(ci, head + Vector2(ex, -0.05) * s, s * 0.07, Color("ff8a4f"), 2)
		ci.draw_circle(head + Vector2(ex, -0.05) * s, s * 0.035, Color("ffe08a"))
		ci.draw_line(head + Vector2(ex, -0.08) * s, head + Vector2(ex, -0.02) * s, OUT, 1.2)
	if fmod(t, 2.0) < 0.6:
		var tp := head + Vector2(f * 0.22, 0.15) * s
		ci.draw_polyline(PackedVector2Array([head + Vector2(f * 0.1, 0.13) * s, tp, tp + Vector2(f * 0.08, -0.05) * s]), Color("e04866"), maxf(1.5, s * 0.025), true)
		ci.draw_line(tp, tp + Vector2(f * 0.08, 0.05) * s, Color("e04866"), maxf(1.5, s * 0.025), true)
	# Ash flecks rising.
	for i in 5:
		var ph := fmod(t * 0.3 + i * 0.2, 1.0)
		ci.draw_circle(_p(c, s, -0.5 + i * 0.25, 0.8 - ph * 1.6), s * 0.02, Color(0.75, 0.7, 0.7, 0.6 * (1.0 - ph)))
		if i % 2 == 0:
			ci.draw_circle(_p(c, s, -0.4 + i * 0.2, 0.6 - ph * 1.2), s * 0.015, Color("ff8a4f", 0.8 * (1.0 - ph)))


# ---------------------------------------------------------------- Gargoyle

static func _gargoyle(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float) -> void:
	var stone := col
	var flap := sin(t * 1.8) * 0.06
	# Pedestal.
	_sh(ci, [[-0.65, 0.72], [0.65, 0.72], [0.72, 1.0], [-0.72, 1.0]], c, s, stone.darkened(0.35))
	ci.draw_line(_p(c, s, -0.68, 0.85), _p(c, s, 0.68, 0.85), Color(stone.darkened(0.6), 0.7), maxf(1.0, s * 0.02))
	# Bat wings.
	for sgn in [-1.0, 1.0]:
		var sg: float = sgn
		var w: Array = [[0.3 * sg, -0.35], [0.85 * sg, -1.0 + flap], [1.15 * sg, -0.75 + flap], [1.05 * sg, -0.35 + flap], [0.95 * sg, -0.05], [0.75 * sg, -0.2], [0.6 * sg, 0.05], [0.4 * sg, -0.05]]
		if sg < 0:
			w.reverse()
		_sh(ci, w, c, s, stone.darkened(0.25))
		for k in 3:
			ci.draw_line(_p(c, s, 0.35 * sg, -0.3), _p(c, s, (0.85 + k * 0.1) * sg, -0.95 + k * 0.32 + flap), Color(stone.darkened(0.55), 0.8), maxf(1.0, s * 0.02), true)
	# Crouched body and haunches.
	_sh(ci, [[-0.4, -0.45], [0.4, -0.45], [0.55, 0.35], [0.3, 0.72], [-0.3, 0.72], [-0.55, 0.35]], c, s, stone)
	IconDraw.oval(ci, _p(c, s, -0.38, 0.45), s * 0.22, s * 0.28, stone.darkened(0.1), _ow(s))
	IconDraw.oval(ci, _p(c, s, 0.38, 0.45), s * 0.22, s * 0.28, stone.darkened(0.1), _ow(s))
	# Claws on the pedestal edge.
	for x in [-0.32, -0.22, 0.22, 0.32]:
		ci.draw_colored_polygon(PackedVector2Array([_p(c, s, x - 0.04, 0.7), _p(c, s, x, 0.82), _p(c, s, x + 0.04, 0.7)]), Color("e9e2cf"))
	# Cracks + moss.
	ci.draw_polyline(IconDraw.pts_of([[0.1, -0.35], [0.2, -0.1], [0.12, 0.1], [0.25, 0.3]], c, s), OUT, maxf(1.0, s * 0.02), true)
	IconDraw.oval(ci, _p(c, s, -0.3, -0.38), s * 0.12, s * 0.04, Color("7fae6b", 0.8), 0.0, 0.2)
	# Head: horns, brow, glowing eyes, fangs.
	var hp := _p(c, s, 0, -0.65)
	_sh(ci, [[-0.18, -0.15], [-0.42, -0.55], [-0.08, -0.25]], hp, s, Color("e9e2cf"))
	_sh(ci, [[0.08, -0.25], [0.42, -0.55], [0.18, -0.15]], hp, s, Color("e9e2cf"))
	IconDraw.ball(ci, hp, s * 0.28, stone.lightened(0.05), _ow(s))
	_sh(ci, [[-0.24, -0.08], [0.24, -0.08], [0.2, 0.0], [-0.2, 0.0]], hp, s, stone.darkened(0.3), false)
	var glow_a := 0.6 + 0.4 * sin(t * 3.0)
	for ex in [-0.1, 0.1]:
		IconDraw.glow(ci, hp + Vector2(ex, 0.04) * s, s * 0.09, Color("7ee8ff"), 3)
		ci.draw_circle(hp + Vector2(ex, 0.04) * s, s * 0.035, Color(0.9, 1.0, 1.0, glow_a))
	ci.draw_line(hp + Vector2(-0.12, 0.16) * s, hp + Vector2(0.12, 0.16) * s, OUT, maxf(1.5, s * 0.03))
	for fx in [-0.07, 0.07]:
		ci.draw_colored_polygon(PackedVector2Array([hp + Vector2(fx - 0.03, 0.16) * s, hp + Vector2(fx, 0.25) * s, hp + Vector2(fx + 0.03, 0.16) * s]), Color("f4ecd8"))


# ---------------------------------------------------------------- Mirror Fiend (elite)

static func _mirror(ci: CanvasItem, c: Vector2, s: float, col: Color, t: float) -> void:
	var gold := Color("e0bf72")
	var mc := _p(c, s, 0, -0.25 + sin(t * 1.6) * 0.04)
	# Orbiting shards.
	for i in 6:
		var a := t * 0.7 + i * TAU / 6.0
		var sp := mc + Vector2(cos(a) * 1.05, sin(a) * 0.45) * s
		if sin(a) < 0.0:
			_shard(ci, sp, s * 0.12, a * 2.0, col)
	IconDraw.glow(ci, mc, s * 0.95, col, 5)
	# Ornate frame.
	var frame := IconDraw.ellipse_pts(mc, s * 0.62, s * 0.85, 36)
	IconDraw.fill(ci, frame, gold, _ow(s))
	for i in 12:
		var a2 := i * TAU / 12.0
		IconDraw.ball(ci, mc + Vector2(cos(a2) * 0.62, sin(a2) * 0.85) * s, s * 0.055, gold.lightened(0.15), 1.0)
	_sh(ci, [[-0.2, -0.8], [0.0, -1.12], [0.2, -0.8]], mc, s, gold)
	IconDraw.ball(ci, mc + Vector2(0, -0.98) * s, s * 0.07, Color("ff5a7a"), 1.0)
	# Glass with a dark reflection.
	var glass := IconDraw.ellipse_pts(mc, s * 0.5, s * 0.72, 32)
	var cols := PackedColorArray()
	for p in glass:
		var v := clampf((p.y - mc.y) / (s * 1.44) + 0.5, 0.0, 1.0)
		cols.append(col.darkened(0.55).lerp(Color("0b0814"), v))
	ci.draw_polygon(glass, cols)
	# The fiend inside: shifting silhouette, eyes and grin.
	var shift := sin(t * 2.2) * 0.04
	var sil := IconDraw.ellipse_pts(mc + Vector2(shift, 0.15) * s, s * 0.3, s * 0.42, 20)
	ci.draw_colored_polygon(sil, Color("05030a", 0.85))
	for ex in [-0.12, 0.12]:
		var ep := mc + Vector2(ex + shift, -0.02) * s
		IconDraw.glow(ci, ep, s * 0.08, Color("ff4f7b"), 2)
		ci.draw_colored_polygon(PackedVector2Array([ep + Vector2(-0.07, 0.0) * s, ep + Vector2(0.0, -0.04) * s, ep + Vector2(0.07, 0.0) * s, ep + Vector2(0.0, 0.025) * s]), Color("ffd0dc"))
	var grin := PackedVector2Array()
	for i in 13:
		var u := float(i) / 12.0
		grin.append(mc + Vector2(-0.18 + u * 0.36 + shift, 0.18 + sin(u * PI) * 0.08 + (0.025 if i % 2 == 0 else 0.0)) * s)
	ci.draw_polyline(grin, Color("ffd0dc"), maxf(1.5, s * 0.025), true)
	# Glare streaks + a crack.
	ci.draw_line(mc + Vector2(-0.32, -0.45) * s, mc + Vector2(-0.1, -0.62) * s, Color(1, 1, 1, 0.35), s * 0.05, true)
	ci.draw_line(mc + Vector2(-0.38, -0.3) * s, mc + Vector2(-0.25, -0.4) * s, Color(1, 1, 1, 0.25), s * 0.03, true)
	ci.draw_polyline(PackedVector2Array([mc + Vector2(0.15, -0.68) * s, mc + Vector2(0.25, -0.45) * s, mc + Vector2(0.18, -0.3) * s, mc + Vector2(0.32, -0.15) * s]), Color(1, 1, 1, 0.5), maxf(1.0, s * 0.015), true)
	# Stand / wisps below.
	for i in 3:
		var ph := fmod(t * 0.6 + i * 0.33, 1.0)
		ci.draw_arc(_p(c, s, 0, 0.85), s * (0.15 + ph * 0.45), PI * 1.15, PI * 1.85, 16, Color(col, 0.4 * (1.0 - ph)), maxf(1.0, s * 0.025), true)
	for i in 6:
		var a3 := t * 0.7 + i * TAU / 6.0
		var sp2 := mc + Vector2(cos(a3) * 1.05, sin(a3) * 0.45) * s
		if sin(a3) >= 0.0:
			_shard(ci, sp2, s * 0.12, a3 * 2.0, col)


static func _shard(ci: CanvasItem, p: Vector2, r: float, rot: float, col: Color) -> void:
	var pts := PackedVector2Array([p + Vector2(0, -r).rotated(rot), p + Vector2(r * 0.45, r * 0.2).rotated(rot), p + Vector2(-r * 0.1, r * 0.8).rotated(rot), p + Vector2(-r * 0.4, 0.1 * r).rotated(rot)])
	ci.draw_colored_polygon(pts, Color(col.lightened(0.5), 0.85))
	ci.draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), OUT, 1.2, true)
	ci.draw_line(pts[0], pts[2], Color(1, 1, 1, 0.5), 1.0, true)
