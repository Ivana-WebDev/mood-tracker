class_name EventArt
extends Control
## Animated vector illustrations for events and the merchant's stall.

var scene: String = ""
var _t := 0.0


func _init(scene_id: String = "", min_size: Vector2 = Vector2(560, 190)) -> void:
	scene = scene_id
	custom_minimum_size = min_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(d: float) -> void:
	_t += d
	queue_redraw()


func _draw() -> void:
	if size.x < 8.0 or size.y < 8.0:
		return
	var r := Rect2(Vector2.ZERO, size)
	var accent := Palette.NODE_COLORS["shop"] if scene == "shop" else Palette.NODE_COLORS["event"]
	# framed night backdrop
	Scenery.gradient_rect(self, r, Color("0b0d18"), Palette.BG_2.lerp(accent, 0.18))
	for i in 18:
		var p := Vector2(fmod(i * 97.3, r.size.x), fmod(i * 41.7, r.size.y * 0.55))
		draw_circle(p, 1.0 + i % 2, Color(1, 1, 1, 0.25 + 0.2 * sin(_t * 2.0 + i)))
	var ground := r.size.y * 0.78
	var hills := PackedVector2Array([Vector2(0, r.size.y)])
	var x := 0.0
	while x <= r.size.x + 20:
		hills.append(Vector2(x, ground - 18 - 14 * sin(x * 0.012 + scene.length())))
		x += 20
	hills.append(Vector2(r.size.x, r.size.y))
	draw_colored_polygon(hills, Palette.BG.lerp(accent, 0.12))
	draw_rect(Rect2(0, ground, r.size.x, r.size.y - ground), Palette.BG.darkened(0.2))
	var c := Vector2(r.size.x / 2.0, ground)
	var s := r.size.y * 0.42
	match scene:
		"shrine": _shrine(c, s)
		"smith": _smith(c, s)
		"fountain": _fountain(c, s)
		"duelist": _duelist(c, s)
		"lost_caravan": _caravan(c, s)
		"shop": _shop(r, ground)
	draw_style_box(Palette.flat(Color(0, 0, 0, 0), 12, Color(accent, 0.8), 2), r)


func S(pts: Array, o: Vector2, k: float, col: Color, shade: bool = true) -> void:
	IconDraw.shape(self, pts, o, k, col, shade)


func _shrine(c: Vector2, s: float) -> void:
	var stone := Color("6b6f80")
	S([[-0.9, 0.0], [0.9, 0.0], [0.75, -0.25], [-0.75, -0.25]], c, s, stone.darkened(0.2))
	S([[-0.55, -0.25], [0.55, -0.25], [0.5, -1.15], [0.0, -1.55], [-0.5, -1.15]], c, s, stone)
	IconDraw.glow(self, c + Vector2(0, -0.8) * s, s * 0.55, Color("c38bff"), 5)
	var pulse := 0.5 + 0.5 * sin(_t * 2.0)
	for i in 3:
		var p := c + Vector2(-0.25 + i * 0.25, -0.55 - (i % 2) * 0.2) * s
		draw_string(UI.font(), p - Vector2(8, -6), ["ᚱ", "ᛟ", "ᚾ"][i], HORIZONTAL_ALIGNMENT_CENTER, 16, int(s * 0.22), Color("e2c8ff", 0.5 + 0.5 * pulse))
	IconDraw.ball(self, c + Vector2(0, -0.95) * s, s * 0.14, Color("c0263f"), 1.5)
	for side in [-1.0, 1.0]:
		var cp := c + Vector2(side * 1.15, -0.12) * s
		draw_rect(Rect2(cp - Vector2(4, 0), Vector2(8, s * 0.3)), Color("efe2c0"))
		IconDraw.glow(self, cp + Vector2(0, -6), 18 + 3 * sin(_t * 9.0 + side), Palette.GOLD, 3)
		IconDraw.shape(self, [[-0.05, 0.0], [0.0, -0.16 - 0.03 * sin(_t * 11.0 + side)], [0.05, 0.0]], cp, s, Color("ffcf4a"), false)
	for i in 6:
		var m := fmod(_t * 0.2 + i * 0.17, 1.0)
		draw_circle(c + Vector2(-1.6 + i * 0.65, -0.1 - m * 0.4) * s, s * (0.12 + m * 0.1), Color(0.8, 0.8, 0.9, 0.08 * (1.0 - m)))


func _smith(c: Vector2, s: float) -> void:
	var fire := c + Vector2(1.15, -0.35) * s
	IconDraw.glow(self, fire, s * 0.7, Color("ff8a4f"), 6)
	S([[0.85, 0.0], [1.45, 0.0], [1.4, -0.45], [0.9, -0.45]], c, s, Color("4a3f52"))
	IconDraw.icon(self, "fire", fire + Vector2(0, -0.15) * s, s * (0.32 + 0.03 * sin(_t * 8.0)), Color("ff8a4f"))
	S([[-0.6, 0.0], [0.4, 0.0], [0.25, -0.25], [-0.45, -0.25]], c, s, Color("2a2230"))
	S([[-0.85, -0.25], [0.55, -0.25], [0.7, -0.55], [-0.95, -0.55], [-1.1, -0.42]], c, s, Color("6e6a73"))
	S([[-0.6, -0.6], [0.35, -0.6], [0.35, -0.55], [-0.6, -0.55]], c, s, Color("ff8a4f").lightened(0.2), false)
	var swing := -0.6 + 0.6 * absf(sin(_t * 2.6))
	var pivot := c + Vector2(-0.3, -1.3) * s
	var head := pivot + Vector2(0.0, 0.75).rotated(swing) * s
	draw_line(pivot, head, IconDraw.OUTLINE, s * 0.12, true)
	draw_line(pivot, head, Color("c9a26b"), s * 0.07, true)
	IconDraw.fill(self, PackedVector2Array([head + Vector2(-0.18, -0.1) * s, head + Vector2(0.18, -0.1) * s, head + Vector2(0.18, 0.1) * s, head + Vector2(-0.18, 0.1) * s]), Color("8a93ad"), 1.5, true)
	if absf(sin(_t * 2.6)) < 0.25:
		for i in 7:
			var a := -PI / 2 + (i - 3) * 0.35
			var p := c + Vector2(-0.15, -0.6) * s + Vector2(cos(a), sin(a)) * s * (0.2 + 0.25 * fmod(_t * 3.0, 1.0))
			draw_circle(p, 2.5, Color("ffd34a"))


func _fountain(c: Vector2, s: float) -> void:
	var stone := Color("8a93ad")
	IconDraw.oval(self, c + Vector2(0, -0.1) * s, s * 1.3, s * 0.25, stone.darkened(0.2), 2.0)
	IconDraw.oval(self, c + Vector2(0, -0.2) * s, s * 1.15, s * 0.18, Color("4fa8e8"), 1.5)
	for i in 6:
		var p := c + Vector2(-0.8 + i * 0.32, -0.2 + (i % 2) * 0.05) * s
		draw_circle(p, s * 0.05, Color(Palette.GOLD, 0.5 + 0.5 * sin(_t * 3.0 + i)))
	S([[-0.12, -0.2], [0.12, -0.2], [0.08, -0.85], [-0.08, -0.85]], c, s, stone)
	IconDraw.oval(self, c + Vector2(0, -0.88) * s, s * 0.45, s * 0.1, stone, 1.5)
	for side in [-1.0, 1.0]:
		var pts := PackedVector2Array()
		for k in 12:
			var u := float(k) / 11.0
			pts.append(c + Vector2(side * (0.1 + u * 0.75), -1.0 - sin(u * PI) * 0.45 + u * 0.75) * s)
		draw_polyline(pts, Color("9fd8ff", 0.8), 3.0, true)
		draw_circle(pts[11], 3 + 2 * sin(_t * 10.0 + side), Color("dff4ff", 0.7))
	S([[-0.06, -0.95], [0.06, -0.95], [0.0, -1.2]], c, s, Color("9fd8ff"), false)


func _duelist(c: Vector2, s: float) -> void:
	var o := c + Vector2(-0.5, 0) * s
	S([[-0.25, 0.0], [-0.05, 0.0], [-0.05, -0.55], [-0.2, -0.55]], o, s, Color("2a2230"))
	S([[0.05, 0.0], [0.25, 0.0], [0.2, -0.55], [0.05, -0.55]], o, s, Color("2a2230"))
	S([[-0.4, -0.5], [0.4, -0.5], [0.3, -1.1], [-0.3, -1.1]], o, s, Color("6e3a52"))
	S([[-0.45, -1.1], [-0.65 + 0.05 * sin(_t * 2.0), -0.3], [-0.3, -0.5]], o, s, Color("8a1f3a"))
	IconDraw.ball(self, o + Vector2(0, -1.3) * s, s * 0.2, Color("e9c9b4"), 1.5)
	S([[-0.3, -1.4], [0.3, -1.4], [0.42, -1.33], [-0.42, -1.33]], o, s, Color("2a2230"))
	S([[-0.18, -1.62], [0.18, -1.62], [0.22, -1.4], [-0.22, -1.4]], o, s, Color("2a2230"))
	draw_line(o + Vector2(-0.1, -1.22) * s, o + Vector2(0.15, -1.2) * s, Color("d8d8d8"), 3.0)
	var hand := o + Vector2(0.45, -0.85) * s
	draw_line(o + Vector2(0.25, -1.0) * s, hand, Color("e9c9b4"), s * 0.08, true)
	draw_line(hand, hand + Vector2(1.1, -0.15 + 0.05 * sin(_t * 3.0)) * s, Color("e6ebf5"), 2.5, true)
	draw_circle(hand, s * 0.07, Palette.GOLD)
	var d := c + Vector2(1.0, 0) * s
	draw_line(d, d + Vector2(0, -1.2) * s, Color("8a6440"), s * 0.08)
	IconDraw.oval(self, d + Vector2(0, -0.85) * s, s * 0.22, s * 0.35, Color("c9a26b"), 2.0)
	IconDraw.ball(self, d + Vector2(0, -1.35) * s, s * 0.17, Color("c9a26b"), 1.5)
	draw_arc(d + Vector2(0, -0.85) * s, s * 0.12, 0, TAU, 16, Palette.BAD, 2.0)


func _caravan(c: Vector2, s: float) -> void:
	S([[-1.2, 0.0], [0.4, 0.0], [0.55, -0.7], [-1.1, -0.85]], c, s, Color("8a6440"))
	S([[-1.15, -0.85], [0.55, -0.7], [0.35, -1.35], [-0.95, -1.5]], c, s, Color("e8dcc8").darkened(0.1))
	for k in 3:
		draw_line(c + Vector2(-0.95 + k * 0.45, -0.85 + k * 0.05) * s, c + Vector2(-0.8 + k * 0.4, -1.45 + k * 0.05) * s, Color(0, 0, 0, 0.25), 2.0)
	var wc := c + Vector2(0.95, -0.35) * s
	draw_arc(wc, s * 0.35, 0, TAU, 24, IconDraw.OUTLINE, s * 0.1, true)
	draw_arc(wc, s * 0.35, 0, TAU, 24, Color("6e4a2a"), s * 0.06, true)
	for k in 6:
		var a := k * TAU / 6.0 + _t * 0.3
		draw_line(wc, wc + Vector2(cos(a), sin(a)) * s * 0.33, Color("6e4a2a"), 2.5)
	for i in 3:
		var bp := c + Vector2(1.45 + i * 0.32, -0.15 - (i % 2) * 0.32) * s
		S([[-0.15, 0.15], [0.15, 0.15], [0.15, -0.15], [-0.15, -0.15]], bp, s, Color("a07850"))
	draw_circle(c + Vector2(-1.45, -0.1) * s, s * 0.08, Palette.GOLD)
	draw_circle(c + Vector2(-1.6, -0.05) * s, s * 0.06, Palette.GOLD)
	IconDraw.potion(self, c + Vector2(-1.3, -0.2) * s, s * 0.2, Color("e5484d"))


func _shop(r: Rect2, ground: float) -> void:
	# striped awning with scalloped edge
	var stripes := 16
	var w := r.size.x / stripes
	for i in stripes:
		var col := Color("8a1f3a") if i % 2 == 0 else Color("efe2c0")
		var x0 := i * w
		draw_rect(Rect2(x0, 0, w + 1, 22), col)
		draw_circle(Vector2(x0 + w / 2.0, 22), w / 2.0, col)
	draw_line(Vector2(0, 2), Vector2(r.size.x, 2), IconDraw.OUTLINE, 3.0)
	# shelves with potions and scrolls on the right
	for row in 2:
		var y := 78.0 + row * 42.0
		draw_rect(Rect2(r.size.x * 0.5, y, r.size.x * 0.46, 6), Color("6e4a2a"))
		for i in 8:
			var px := r.size.x * 0.53 + i * r.size.x * 0.053
			if (i + row) % 3 == 0:
				draw_rect(Rect2(px - 6, y - 22, 12, 20), Color("efe2c0"))
				draw_line(Vector2(px - 6, y - 12), Vector2(px + 6, y - 12), Palette.BAD, 2.0)
			else:
				IconDraw.potion(self, Vector2(px, y - 13), 13, [Color("e5484d"), Color("4f9be8"), Color("7ee0a1"), Color("c38bff"), Color("ffcf4a")][(i + row * 2) % 5])
	# merchant: hooded figure with a lantern and friendly glowing eyes
	var k := 40.0
	var m := Vector2(r.size.x * 0.22, ground - 6)
	S([[-0.7, 0.2], [0.7, 0.2], [0.45, -0.8], [-0.45, -0.8]], m, k, Color("3a5a4a"))
	var hood: Array = [[-0.46, -0.72]]
	for i in 11:
		var a := PI + i * PI / 10.0
		hood.append([cos(a) * 0.44, -1.08 + sin(a) * 0.48])
	hood.append([0.46, -0.72])
	S(hood, m, k, Color("2e4a3c"))
	draw_colored_polygon(IconDraw.ellipse_pts(m + Vector2(0, -1.02) * k, k * 0.27, k * 0.23), Color("10141a"))
	for ex in [-0.11, 0.11]:
		draw_circle(m + Vector2(ex, -1.05) * k, 2.6, Color("ffe29a", 0.75 + 0.25 * sin(_t * 1.3)))
	draw_arc(m + Vector2(0, -0.95) * k, k * 0.09, 0.3, PI - 0.3, 8, Color("ffe29a", 0.6), 2.0)
	IconDraw.ball(self, m + Vector2(-0.55, -0.45) * k, k * 0.12, Color("c9a26b"), 1.5)
	var lp := m + Vector2(0.85, -0.85 + 0.04 * sin(_t * 2.0)) * k
	draw_line(m + Vector2(0.5, -0.5) * k, lp + Vector2(0, -12), Color("6e6a73"), 3.0)
	Scenery.lantern(self, lp, 10.0, Palette.GOLD, _t)
	# counter in front of the merchant, with wares
	var top_y := ground - 22.0
	var cx0 := r.size.x * 0.06
	var cx1 := r.size.x * 0.44
	IconDraw.fill(self, PackedVector2Array([Vector2(cx0, top_y), Vector2(cx1, top_y), Vector2(cx1, r.size.y - 2), Vector2(cx0, r.size.y - 2)]), Color("8a6440"), 2.0, true)
	draw_rect(Rect2(cx0, top_y, cx1 - cx0, 5), Color("a07850"))
	for i in 3:
		IconDraw.die(self, Vector2(r.size.x * 0.33 + i * 20, top_y - 9), 8, [6, 3, 5][i], Palette.TEXT, i * 0.4)
	IconDraw.gear(self, Vector2(r.size.x * 0.1, top_y - 12), 12, 9, 8, Color("d9a24a"), _t * 0.5)
	IconDraw.potion(self, Vector2(r.size.x * 0.15, top_y - 12), 12, Color("7ee8ff"))
	coin_stack(Vector2(r.size.x * 0.41, top_y - 4))


func coin_stack(p: Vector2) -> void:
	for i in 4:
		IconDraw.oval(self, p + Vector2(0, -i * 4), 9, 4, Palette.GOLD.darkened(0.1 * (i % 2)), 1.2)
