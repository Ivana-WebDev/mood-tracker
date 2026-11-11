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
		_:
			ci.draw_circle(c, 0.6 * s, color)


## Draws a stylised creature / hero. `t` is a time value for idle bobbing.
static func creature(ci: CanvasItem, shape: String, c: Vector2, s: float, color: Color, t: float, facing: float = -1.0) -> void:
	var bob := sin(t * 2.2) * 0.04
	var body := color
	var dark := color.darkened(0.45)
	var eye := Color("fff6e0")
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# shadow
	var sh := PackedVector2Array()
	for i in 24:
		var a := i * TAU / 24.0
		sh.append(c + Vector2(cos(a) * 0.75, 1.0 + sin(a) * 0.12) * s)
	ci.draw_colored_polygon(sh, Color(0, 0, 0, 0.35))
	var cc := c + Vector2(0, bob) * s
	match shape:
		"blob":
			var pts: Array = []
			for i in 28:
				var a := PI + i * PI / 27.0
				pts.append([cos(a) * 0.85, sin(a) * (0.95 + sin(t * 3.0) * 0.05) + 0.25])
			pts.append([0.85, 0.95]); pts.append([-0.85, 0.95])
			poly(ci, pts, cc, s, body)
			ci.draw_circle(cc + Vector2(-0.3 * -facing, -0.1) * s, 0.16 * s, eye)
			ci.draw_circle(cc + Vector2(0.15 * -facing, -0.1) * s, 0.16 * s, eye)
			ci.draw_circle(cc + Vector2(-0.33 * -facing + facing * 0.05, -0.08) * s, 0.07 * s, Palette.BG)
			ci.draw_circle(cc + Vector2(0.12 * -facing + facing * 0.05, -0.08) * s, 0.07 * s, Palette.BG)
		"wisp":
			var pts2: Array = []
			for i in 30:
				var a := i * TAU / 30.0
				var r := 0.6 + (0.15 * sin(a * 3.0 + t * 4.0) if sin(a) > 0.2 else 0.0)
				pts2.append([cos(a) * r, sin(a) * r * 1.1 - 0.1])
			poly(ci, pts2, cc + Vector2(0, -0.15) * s, s, body)
			poly(ci, [[-0.6, -0.4], [-1.1, -0.9 + sin(t * 6) * 0.15], [-0.5, -0.05]], cc, s, dark)
			poly(ci, [[0.6, -0.4], [1.1, -0.9 + sin(t * 6) * 0.15], [0.5, -0.05]], cc, s, dark)
			ci.draw_circle(cc + Vector2(-0.2, -0.3) * s, 0.13 * s, eye)
			ci.draw_circle(cc + Vector2(0.2, -0.3) * s, 0.13 * s, eye)
		"knight":
			poly(ci, [[-0.55, 0.95], [-0.6, -0.2], [0.6, -0.2], [0.55, 0.95]], cc, s, dark)
			poly(ci, [[-0.45, -0.25], [-0.45, -0.85], [0.0, -1.1], [0.45, -0.85], [0.45, -0.25]], cc, s, body)
			poly(ci, [[-0.32, -0.6], [0.32, -0.6], [0.32, -0.5], [-0.32, -0.5]], cc, s, Palette.BG)
			poly(ci, [[0.7 * -facing, -0.9], [0.8 * -facing, -0.9], [0.8 * -facing, 0.7], [0.7 * -facing, 0.7]], cc, s, Color("dfe6f5"))
			ci.draw_circle(cc + Vector2(-0.12, -0.55) * s, 0.05 * s, eye)
			ci.draw_circle(cc + Vector2(0.12, -0.55) * s, 0.05 * s, eye)
		"golem":
			poly(ci, [[-0.8, 0.95], [-0.95, -0.3], [-0.5, -0.8], [0.5, -0.8], [0.95, -0.3], [0.8, 0.95]], cc, s, body)
			poly(ci, [[-0.5, -0.8], [0.5, -0.8], [0.35, -1.15], [-0.35, -1.15]], cc, s, body.lightened(0.15))
			poly(ci, [[-0.3, -0.1], [0.3, -0.1], [0.4, 0.5], [-0.4, 0.5]], cc, s, dark)
			ci.draw_circle(cc + Vector2(-0.18, -0.92) * s, 0.08 * s, Color("ffcf4a"))
			ci.draw_circle(cc + Vector2(0.18, -0.92) * s, 0.08 * s, Color("ffcf4a"))
		"spike":
			var pts3: Array = []
			for i in 14:
				var a := PI + i * PI / 13.0
				var r := 0.95 if i % 2 == 0 else 0.55
				pts3.append([cos(a) * r, sin(a) * r * 1.1 + 0.4])
			pts3.append([0.8, 0.95]); pts3.append([-0.8, 0.95])
			poly(ci, pts3, cc, s, body)
			ci.draw_circle(cc + Vector2(-0.22, 0.1) * s, 0.12 * s, eye)
			ci.draw_circle(cc + Vector2(0.22, 0.1) * s, 0.12 * s, eye)
			ci.draw_circle(cc + Vector2(-0.22, 0.12) * s, 0.05 * s, Palette.BG)
			ci.draw_circle(cc + Vector2(0.22, 0.12) * s, 0.05 * s, Palette.BG)
		"eye":
			poly(ci, [[-0.6, 0.95], [-0.35, -0.3], [0.35, -0.3], [0.6, 0.95]], cc, s, dark)
			ci.draw_circle(cc + Vector2(0, -0.55) * s, 0.55 * s, body)
			ci.draw_circle(cc + Vector2(0, -0.55) * s, 0.3 * s, eye)
			ci.draw_circle(cc + Vector2(0.08 * facing + sin(t) * 0.05, -0.55) * s, 0.14 * s, Palette.BG)
		"crown":
			poly(ci, [[-0.8, 0.95], [-0.7, -0.3], [0.7, -0.3], [0.8, 0.95]], cc, s, Color("3a2f55"))
			ci.draw_circle(cc + Vector2(0, -0.5) * s, 0.42 * s, Color("2a2440"))
			icon(ci, "crown", cc + Vector2(0, -1.05) * s, 0.42 * s, body)
			ci.draw_circle(cc + Vector2(-0.15, -0.5) * s, 0.08 * s, body)
			ci.draw_circle(cc + Vector2(0.15, -0.5) * s, 0.08 * s, body)
			poly(ci, [[-0.95, -0.25], [-0.75, -0.3], [-0.85, 0.6], [-1.05, 0.55]], cc, s, Color("3a2f55").lightened(0.1))
		"dragon":
			poly(ci, [[-0.9, 0.95], [-0.6, -0.1], [0.2, -0.3], [0.7, 0.2], [0.9, 0.95]], cc, s, dark)
			poly(ci, [[0.1, -0.2], [-0.2, -0.75], [-0.55, -1.0], [-1.0, -0.85], [-0.75, -0.6], [-0.35, -0.5], [-0.25, -0.15]], cc, s, body)
			poly(ci, [[-0.3, -0.85], [-0.15, -1.25], [-0.45, -0.95]], cc, s, body.lightened(0.2))
			poly(ci, [[0.2, -0.2], [0.95, -0.95 + sin(t * 2.0) * 0.1], [0.7, 0.1]], cc, s, body.darkened(0.15))
			ci.draw_circle(cc + Vector2(-0.6, -0.82) * s, 0.07 * s, Color("ffcf4a"))
			for i in 4:
				ci.draw_circle(cc + Vector2(-0.4 + i * 0.3, 0.45) * s, 0.06 * s, Color("ffcf4a", 0.6))
		"warden":
			poly(ci, [[-0.5, 0.95], [-0.55, -0.25], [0.55, -0.25], [0.5, 0.95]], cc, s, dark)
			ci.draw_circle(cc + Vector2(0, -0.6) * s, 0.34 * s, Color("e9d1b5"))
			poly(ci, [[-0.38, -0.65], [-0.36, -0.95], [0.0, -1.1], [0.36, -0.95], [0.38, -0.65]], cc, s, Color("aeb9d6"))
			icon(ci, "shield", cc + Vector2(0.55, 0.25) * s, 0.5 * s, body)
			ci.draw_circle(cc + Vector2(0.12, -0.55) * s, 0.05 * s, Palette.BG)
		"shade":
			poly(ci, [[-0.55, 0.95], [-0.35, -0.2], [0.35, -0.2], [0.55, 0.95]], cc, s, dark)
			poly(ci, [[-0.42, -0.25], [-0.35, -0.85], [0.0, -1.15], [0.35, -0.85], [0.42, -0.25]], cc, s, body)
			poly(ci, [[-0.22, -0.65], [0.22, -0.65], [0.18, -0.4], [-0.18, -0.4]], cc, s, Palette.BG)
			ci.draw_circle(cc + Vector2(0.1, -0.55) * s, 0.05 * s, Color("7ee0e8"))
			poly(ci, [[0.55, 0.0], [1.0, -0.45], [0.62, 0.12]], cc, s, Color("dfe6f5"))
		"arcanist":
			poly(ci, [[-0.6, 0.95], [-0.3, -0.25], [0.3, -0.25], [0.6, 0.95]], cc, s, dark)
			ci.draw_circle(cc + Vector2(0, -0.55) * s, 0.3 * s, Color("e9d1b5"))
			poly(ci, [[-0.5, -0.7], [0.5, -0.7], [0.05, -1.4]], cc, s, body)
			line(ci, [0.7, -0.8], [0.7, 0.95], cc, s, Color("c9a26b"), 0.08)
			ci.draw_circle(cc + Vector2(0.7, -0.85) * s, (0.17 + sin(t * 4) * 0.03) * s, Color("bff4ff"))
			ci.draw_circle(cc + Vector2(0.1, -0.52) * s, 0.05 * s, Palette.BG)
		_:
			ci.draw_circle(cc, 0.7 * s, body)
