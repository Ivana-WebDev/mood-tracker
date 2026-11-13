class_name CardFrame
## Hero-themed card frames. Each hero has its own materials and ornaments:
##   Clockwright - riveted brass, cog cost badge, bolted plates, blueprint grid
##   Fatebinder  - gilded filigree on night velvet, die-shaped cost, scattered stars & constellations
##   Duskdancer  - moonlit silver, crescent cost, flowing ribbon edges, petals
##   curses      - cracked bruised iron with thorns
## Card type stays readable through the banner colour and the type plaque icon;
## rarity changes the trim (iron -> silver-blue -> gold) and the corner gems.

const W := 160.0
const H := 224.0

const THEMES := {
	"clockwright": {"top": Color("3d2a19"), "bot": Color("110c08"), "metal": Color("c98f3c"), "lit": Color("ffd98f"), "panel": Color("1c140d"), "ink": Color("ffcf7a")},
	"fatebinder": {"top": Color("2d1f52"), "bot": Color("0b0919"), "metal": Color("e0bf72"), "lit": Color("fff0b8"), "panel": Color("140e2a"), "ink": Color("c9a6ff")},
	"duskdancer": {"top": Color("16304a"), "bot": Color("070d17"), "metal": Color("c3d3ea"), "lit": Color("ffffff"), "panel": Color("0b1526"), "ink": Color("7ef0ff")},
	"curse": {"top": Color("2e1d31"), "bot": Color("0b070c"), "metal": Color("7a6a8a"), "lit": Color("c9b3dc"), "panel": Color("140d16"), "ink": Color("c77dff")},
}

const RARITY_TRIM := {
	"starter": 0.0, "common": 0.0, "uncommon": 0.45, "rare": 0.85, "special": 0.3,
}


static func theme_for(card: Dictionary) -> Dictionary:
	var owner: String = str(card.get("owner", ""))
	if card.get("type", "") in ["status", "curse"]:
		owner = "curse"
	return THEMES.get(owner, THEMES["clockwright"]).merged({"id": owner if THEMES.has(owner) else "clockwright"})


static func trim_color(theme: Dictionary, rarity: String) -> Color:
	var m: Color = theme["metal"]
	match rarity:
		"uncommon": return m.lerp(Color("8fd8ff"), 0.45)
		"rare": return m.lerp(Color("ffcc4d"), 0.7).lightened(0.08)
	return m


static func _hash(s: String) -> int:
	var h := 7
	for ch in s.to_utf8_buffer():
		h = (h * 31 + ch) & 0x7fffffff
	return h


static func _closed(pts: PackedVector2Array) -> PackedVector2Array:
	var c := pts.duplicate()
	c.append(pts[0])
	return c


static func grad(ci: CanvasItem, pts: PackedVector2Array, top: Color, bottom: Color, y0: float, y1: float) -> void:
	var cols := PackedColorArray()
	for p in pts:
		cols.append(top.lerp(bottom, clampf((p.y - y0) / maxf(1.0, y1 - y0), 0.0, 1.0)))
	ci.draw_polygon(pts, cols)


## Bevelled metal stroke: dark outline, metal body, thin highlight.
static func metal_line(ci: CanvasItem, pts: PackedVector2Array, metal: Color, w: float) -> void:
	ci.draw_polyline(pts, IconDraw.OUTLINE, w + 2.5, true)
	ci.draw_polyline(pts, metal.darkened(0.35), w, true)
	ci.draw_polyline(pts, metal, w * 0.55, true)
	ci.draw_polyline(pts, Color(1, 1, 1, 0.28), maxf(1.0, w * 0.18), true)


static func rivet(ci: CanvasItem, p: Vector2, r: float, metal: Color) -> void:
	ci.draw_circle(p, r + 1.0, IconDraw.OUTLINE)
	ci.draw_circle(p, r, metal.darkened(0.25))
	ci.draw_circle(p + Vector2(-r * 0.3, -r * 0.3), r * 0.5, metal.lightened(0.35))


static func screw(ci: CanvasItem, p: Vector2, r: float, metal: Color, rot: float) -> void:
	rivet(ci, p, r, metal)
	var d := Vector2(cos(rot), sin(rot)) * r * 0.75
	ci.draw_line(p - d, p + d, IconDraw.OUTLINE, 1.2, true)


static func gem(ci: CanvasItem, p: Vector2, r: float, col: Color) -> void:
	var pts := PackedVector2Array([p + Vector2(0, -r), p + Vector2(r * 0.8, 0), p + Vector2(0, r), p + Vector2(-r * 0.8, 0)])
	ci.draw_colored_polygon(pts, col.darkened(0.2))
	ci.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -r), p + Vector2(r * 0.8, 0), p]), col.lightened(0.25))
	ci.draw_colored_polygon(PackedVector2Array([p + Vector2(0, r), p + Vector2(-r * 0.8, 0), p]), col.darkened(0.45))
	ci.draw_polyline(_closed(pts), IconDraw.OUTLINE, 1.3, true)
	ci.draw_circle(p + Vector2(-r * 0.2, -r * 0.35), r * 0.16, Color(1, 1, 1, 0.8))


static func four_star(ci: CanvasItem, p: Vector2, r: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 8:
		var a := -PI / 2 + i * PI / 4
		var rr := r if i % 2 == 0 else r * 0.28
		pts.append(p + Vector2(cos(a), sin(a)) * rr)
	ci.draw_colored_polygon(pts, col)


# ====================================================================== body

static func draw_body(ci: CanvasItem, card: Dictionary, body: PackedVector2Array) -> void:
	var th := theme_for(card)
	var type_col := Palette.type_color(card["type"])
	grad(ci, body, (th["top"] as Color).lerp(type_col, 0.16), th["bot"], 0.0, H)
	var hsh := _hash(str(card.get("id", "")))
	match th["id"]:
		"clockwright":
			# Blueprint grid and a faint big cog watermark.
			for i in 9:
				var x := 10.0 + i * 17.5
				ci.draw_line(Vector2(x, 120), Vector2(x, H - 10), Color(th["ink"], 0.05), 1.0)
			for j in 6:
				var y := 126.0 + j * 17.5
				ci.draw_line(Vector2(8, y), Vector2(W - 8, y), Color(th["ink"], 0.05), 1.0)
			IconDraw.gear(ci, Vector2(W - 26, H - 40), 38, 29, 12, Color(th["metal"], 0.07), float(hsh % 10) * 0.1)
		"fatebinder":
			# Star dust, with a little constellation in the text area.
			var pts: Array = []
			for i in 26:
				var px := 8.0 + float((hsh / (i + 1) + i * 53) % 144)
				var py := 8.0 + float((hsh / (i + 3) + i * 89) % 208)
				var a := 0.15 + float(i % 4) * 0.08
				ci.draw_circle(Vector2(px, py), 0.6 + (i % 3) * 0.45, Color(1, 0.95, 0.8, a))
				if py > 135 and pts.size() < 5:
					pts.append(Vector2(px, py))
			for i in range(1, pts.size()):
				ci.draw_line(pts[i - 1], pts[i], Color(th["ink"], 0.12), 1.0, true)
		"duskdancer":
			# Big pale moon watermark + drifting petals.
			var mc := Vector2(W * 0.72, 172)
			ci.draw_circle(mc, 38, Color(th["metal"], 0.06))
			ci.draw_circle(mc + Vector2(12, -8), 34, Color(th["bot"], 0.55))
			for i in 6:
				var px := 14.0 + float((hsh / (i + 2) + i * 37) % 132)
				var py := 128.0 + float((hsh / (i + 5) + i * 23) % 84)
				IconDraw.oval(ci, Vector2(px, py), 3.4, 1.7, Color("ffb3cf", 0.16), 0.0, float(i))
		"curse":
			for i in 4:
				var x0 := 20.0 + float((hsh / (i + 1)) % 120)
				var crack := PackedVector2Array([Vector2(x0, 128), Vector2(x0 + 6, 150), Vector2(x0 - 3, 170), Vector2(x0 + 5, 196)])
				ci.draw_polyline(crack, Color(0, 0, 0, 0.35), 1.5, true)


# ====================================================================== text plate

static func draw_text_plate(ci: CanvasItem, card: Dictionary) -> void:
	var th := theme_for(card)
	var trim := trim_color(th, str(card.get("rarity", "common")))
	var r := Rect2(9, 129, W - 18, 84)
	match th["id"]:
		"clockwright":
			var pts := PackedVector2Array([r.position + Vector2(6, 0), Vector2(r.end.x - 6, r.position.y), Vector2(r.end.x, r.position.y + 6),
				Vector2(r.end.x, r.end.y - 6), r.end - Vector2(6, 0), Vector2(r.position.x + 6, r.end.y), Vector2(r.position.x, r.end.y - 6), r.position + Vector2(0, 6)])
			ci.draw_colored_polygon(pts, Color(th["panel"], 0.78))
			ci.draw_polyline(_closed(pts), Color(trim, 0.55), 1.5, true)
			for p in [r.position + Vector2(5, 5), Vector2(r.end.x - 5, r.position.y + 5), r.end - Vector2(5, 5), Vector2(r.position.x + 5, r.end.y - 5)]:
				screw(ci, p, 2.4, trim, 0.7)
		"fatebinder":
			var box := CardView.rounded_pts(r, 10)
			ci.draw_colored_polygon(box, Color(th["panel"], 0.72))
			ci.draw_polyline(_closed(box), Color(trim, 0.5), 1.2, true)
			ci.draw_polyline(_closed(CardView.rounded_pts(r.grow(-3), 8)), Color(trim, 0.2), 1.0, true)
			for p in [Vector2(r.get_center().x, r.position.y), Vector2(r.get_center().x, r.end.y)]:
				four_star(ci, p, 5.0, trim)
		"duskdancer":
			var pts2 := PackedVector2Array()
			var cx := r.get_center().x
			for i in 13:
				var u := float(i) / 12.0
				pts2.append(Vector2(r.position.x + u * r.size.x, r.position.y + 7.0 - sin(u * PI) * 7.0))
			pts2.append(r.end)
			pts2.append(Vector2(r.position.x, r.end.y))
			ci.draw_colored_polygon(pts2, Color(th["panel"], 0.7))
			ci.draw_polyline(_closed(pts2), Color(trim, 0.45), 1.2, true)
			ci.draw_circle(Vector2(cx, r.position.y), 3.0, Color(trim, 0.8))
		_:
			var box2 := CardView.rounded_pts(r, 6)
			ci.draw_colored_polygon(box2, Color(th["panel"], 0.8))
			ci.draw_polyline(_closed(box2), Color(trim, 0.4), 1.2, true)


# ====================================================================== frame

static func draw_frame(ci: CanvasItem, card: Dictionary, rect: Rect2, upgraded: bool) -> void:
	var th := theme_for(card)
	var rarity := str(card.get("rarity", "common"))
	var trim := trim_color(th, rarity)
	var outer := CardView.rounded_pts(rect.grow(-1.5), 15)
	metal_line(ci, _closed(outer), trim, 4.5)
	if upgraded:
		ci.draw_polyline(_closed(CardView.rounded_pts(rect.grow(-6), 11)), Color(Palette.GOOD, 0.7), 1.5, true)
	match th["id"]:
		"clockwright": _frame_clockwright(ci, th, trim)
		"fatebinder": _frame_fatebinder(ci, th, trim)
		"duskdancer": _frame_duskdancer(ci, th, trim)
		_: _frame_curse(ci, th, trim)
	# Rarity corner gems (uncommon = 2, rare = 4).
	var rc: Color = Palette.RARITY.get(rarity, Palette.LINE)
	if rarity == "uncommon" or rarity == "rare":
		gem(ci, Vector2(6, H * 0.5), 4.5, rc)
		gem(ci, Vector2(W - 6, H * 0.5), 4.5, rc)
	if rarity == "rare":
		gem(ci, Vector2(6, H * 0.5 - 16), 3.0, rc)
		gem(ci, Vector2(W - 6, H * 0.5 - 16), 3.0, rc)


static func _frame_clockwright(ci: CanvasItem, th: Dictionary, trim: Color) -> void:
	# Rivet rows down both sides.
	for i in 7:
		var y := 52.0 + i * 24.0
		if absf(y - H * 0.5) < 12.0:
			continue
		rivet(ci, Vector2(4.5, y), 1.8, trim)
		rivet(ci, Vector2(W - 4.5, y), 1.8, trim)
	# Corner brackets.
	for sx in [1.0, -1.0]:
		var x0: float = 0.0 if sx > 0 else W
		var br := PackedVector2Array([Vector2(x0 + sx * 3, H - 30), Vector2(x0 + sx * 3, H - 3), Vector2(x0 + sx * 30, H - 3)])
		metal_line(ci, br, trim.darkened(0.1), 3.0)
	# Half-hidden cogs at the bottom corners.
	IconDraw.gear(ci, Vector2(10, H - 10), 13, 9, 9, trim.darkened(0.15), 0.2)
	ci.draw_circle(Vector2(10, H - 10), 3.5, IconDraw.OUTLINE)
	IconDraw.gear(ci, Vector2(W - 10, H - 10), 11, 7.5, 8, trim.darkened(0.25), 0.5)
	ci.draw_circle(Vector2(W - 10, H - 10), 3.0, IconDraw.OUTLINE)


static func _frame_fatebinder(ci: CanvasItem, th: Dictionary, trim: Color) -> void:
	# Inner filigree line with corner flourishes.
	ci.draw_polyline(_closed(CardView.rounded_pts(Rect2(5, 5, W - 10, H - 10), 12)), Color(trim, 0.45), 1.0, true)
	for p in [Vector2(9, 9), Vector2(W - 9, 9), Vector2(9, H - 9), Vector2(W - 9, H - 9)]:
		var d := Vector2(signf(W * 0.5 - p.x), signf(H * 0.5 - p.y))
		ci.draw_arc(p + d * 7.0, 7.0, 0, TAU, 14, Color(trim, 0.5), 1.0, true)
		four_star(ci, p, 6.0, trim)
	# Side swirls.
	for sx in [1.0, -1.0]:
		var x0: float = 4.0 if sx > 0 else W - 4.0
		for k in 2:
			var cy := 70.0 + k * 108.0
			var sw := PackedVector2Array()
			for i in 12:
				var a := float(i) / 11.0 * PI * 1.6
				sw.append(Vector2(x0 + sx * (3.0 + sin(a) * 2.5), cy + float(i) * 2.2))
			ci.draw_polyline(sw, Color(trim, 0.7), 1.2, true)
	# Die pips at the bottom corners.
	for p in [Vector2(24, H - 7), Vector2(W - 24, H - 7)]:
		ci.draw_circle(p, 2.0, Color(trim, 0.8))
		ci.draw_circle(p + Vector2(6, 0), 1.4, Color(trim, 0.5))
		ci.draw_circle(p - Vector2(6, 0), 1.4, Color(trim, 0.5))


static func _frame_duskdancer(ci: CanvasItem, th: Dictionary, trim: Color) -> void:
	# Ribbon waves flowing down each side.
	for sx in [1.0, -1.0]:
		var x0: float = 5.0 if sx > 0 else W - 5.0
		var wave := PackedVector2Array()
		for i in 40:
			var y := 44.0 + i * 4.3
			wave.append(Vector2(x0 + sx * (1.5 + sin(i * 0.45) * 2.2), y))
		ci.draw_polyline(wave, Color(th["ink"], 0.45), 1.4, true)
	# Crescent moons at the bottom corners, petals at the top.
	for p in [Vector2(12, H - 12), Vector2(W - 12, H - 12)]:
		ci.draw_circle(p, 7.5, IconDraw.OUTLINE)
		ci.draw_circle(p, 6.5, trim)
		ci.draw_circle(p + Vector2(2.8 * signf(W * 0.5 - p.x), -2.2), 5.6, Color(th["bot"]).lerp(Color(th["top"]), 0.3))
	for i in 3:
		var a := -0.6 + i * 0.6
		IconDraw.oval(ci, Vector2(W * 0.5, H - 4) + Vector2(sin(a), -cos(a)) * 6.0, 3.8, 1.8, Color("ffb3cf", 0.75), 1.0, a + PI / 2)


static func _frame_curse(ci: CanvasItem, th: Dictionary, trim: Color) -> void:
	# Thorns poking inward along the edges.
	for i in 9:
		var y := 40.0 + i * 20.0
		ci.draw_colored_polygon(PackedVector2Array([Vector2(3, y - 4), Vector2(11, y), Vector2(3, y + 4)]), trim.darkened(0.2))
		ci.draw_colored_polygon(PackedVector2Array([Vector2(W - 3, y - 4), Vector2(W - 11, y), Vector2(W - 3, y + 4)]), trim.darkened(0.2))


# ====================================================================== banner + plaque + cost

static func draw_banner(ci: CanvasItem, card: Dictionary) -> void:
	var th := theme_for(card)
	var trim := trim_color(th, str(card.get("rarity", "common")))
	var type_col := Palette.type_color(card["type"])
	var y0 := 11.0
	var y1 := 38.0
	var pts := PackedVector2Array()
	match th["id"]:
		"clockwright":
			pts = PackedVector2Array([Vector2(8, y0), Vector2(W - 8, y0), Vector2(W - 3, y0 + 6), Vector2(W - 3, y1 - 6), Vector2(W - 8, y1),
				Vector2(8, y1), Vector2(3, y1 - 6), Vector2(3, y0 + 6)])
		"fatebinder":
			# Scroll ribbon with folded tails.
			for sx in [1.0, -1.0]:
				var x0: float = 2.0 if sx > 0 else W - 2.0
				var tail := PackedVector2Array([Vector2(x0, y0 + 6), Vector2(x0 + sx * 14, y0 + 6), Vector2(x0 + sx * 14, y1 + 4), Vector2(x0, y1 + 4), Vector2(x0 + sx * 6, y0 + 19)])
				ci.draw_colored_polygon(tail, type_col.darkened(0.6))
				ci.draw_polyline(_closed(tail), IconDraw.OUTLINE, 1.5, true)
			pts = PackedVector2Array([Vector2(10, y0), Vector2(W - 10, y0), Vector2(W - 10, y1), Vector2(10, y1)])
		"duskdancer":
			for i in 17:
				var u := float(i) / 16.0
				pts.append(Vector2(4 + u * (W - 8), y0 + 3.0 - sin(u * PI) * 4.0))
			pts.append(Vector2(W - 4, y1 - 2))
			for i in 17:
				var u2 := 1.0 - float(i) / 16.0
				pts.append(Vector2(4 + u2 * (W - 8), y1 + 1.0 - sin(u2 * PI) * 3.0))
			pts.append(Vector2(4, y1 - 2))
		_:
			pts = PackedVector2Array([Vector2(4, y0 + 2), Vector2(W - 4, y0 + 2), Vector2(W - 12, y0 + 15), Vector2(W - 4, y1), Vector2(4, y1), Vector2(12, y0 + 15)])
	grad(ci, pts, type_col.darkened(0.1), type_col.darkened(0.6), y0, y1)
	ci.draw_polyline(PackedVector2Array([pts[0], pts[1]]), Color(1, 1, 1, 0.25), 1.5, true)
	ci.draw_polyline(_closed(pts), IconDraw.OUTLINE, 2.0, true)
	ci.draw_polyline(_closed(pts), Color(trim, 0.6), 1.0, true)
	if th["id"] == "clockwright":
		rivet(ci, Vector2(W - 12, y0 + 13.5), 1.8, trim)


static func draw_plaque(ci: CanvasItem, card: Dictionary, f: Font) -> void:
	var th := theme_for(card)
	var trim := trim_color(th, str(card.get("rarity", "common")))
	var type_col := Palette.type_color(card["type"])
	var plate := Rect2(W / 2.0 - 38, 109, 76, 19)
	var pts := PackedVector2Array([plate.position + Vector2(8, 0), Vector2(plate.end.x - 8, plate.position.y), Vector2(plate.end.x, plate.get_center().y),
		Vector2(plate.end.x - 8, plate.end.y), Vector2(plate.position.x + 8, plate.end.y), Vector2(plate.position.x, plate.get_center().y)])
	ci.draw_colored_polygon(pts, Color(th["panel"]).lerp(type_col, 0.18))
	ci.draw_polyline(_closed(pts), IconDraw.OUTLINE, 2.0, true)
	ci.draw_polyline(_closed(pts), Color(trim, 0.85), 1.0, true)
	var icon_kind: String = card["type"] if card["type"] in ["attack", "skill", "power"] else "debuff"
	IconDraw.icon(ci, icon_kind, plate.position + Vector2(14, 9.5), 6.5, type_col.lightened(0.2))
	ci.draw_string(f, Vector2(plate.position.x + 18, plate.position.y + 14), str(card["type"]).capitalize(), HORIZONTAL_ALIGNMENT_CENTER, plate.size.x - 22, 11, Palette.TEXT)


static func draw_cost(ci: CanvasItem, card: Dictionary, can: bool, f: Font) -> void:
	if int(card["cost"]) < 0:
		return
	var th := theme_for(card)
	var trim := trim_color(th, str(card.get("rarity", "common")))
	var oc := Vector2(16, 16)
	var ec: Color = Palette.ENERGY if can else Palette.TEXT_DIM.darkened(0.3)
	var txt_col := Palette.BG
	match th["id"]:
		"clockwright":
			IconDraw.gear(ci, oc, 20, 16, 10, trim.darkened(0.1), 0.15)
			ci.draw_circle(oc, 14, IconDraw.OUTLINE)
			ci.draw_circle(oc, 12.5, ec.darkened(0.3))
			ci.draw_circle(oc + Vector2(-1, -1), 10.5, ec)
			ci.draw_circle(oc + Vector2(-4, -5), 3, Color(1, 1, 1, 0.45))
		"fatebinder":
			var d := PackedVector2Array([oc + Vector2(0, -20), oc + Vector2(20, 0), oc + Vector2(0, 20), oc + Vector2(-20, 0)])
			ci.draw_colored_polygon(d, IconDraw.OUTLINE)
			var d2 := PackedVector2Array([oc + Vector2(0, -17), oc + Vector2(17, 0), oc + Vector2(0, 17), oc + Vector2(-17, 0)])
			ci.draw_colored_polygon(d2, trim)
			var d3 := PackedVector2Array([oc + Vector2(0, -14), oc + Vector2(14, 0), oc + Vector2(0, 14), oc + Vector2(-14, 0)])
			grad(ci, d3, ec.lightened(0.2), ec.darkened(0.3), oc.y - 14, oc.y + 14)
			for p in [oc + Vector2(0, -11), oc + Vector2(11, 0), oc + Vector2(0, 11), oc + Vector2(-11, 0)]:
				ci.draw_circle(p, 1.2, Color(1, 1, 1, 0.55))
		"duskdancer":
			ci.draw_circle(oc, 18, IconDraw.OUTLINE)
			ci.draw_circle(oc, 16.5, trim)
			ci.draw_circle(oc, 13.5, ec.darkened(0.25))
			ci.draw_circle(oc + Vector2(-2, -1), 11.5, ec)
			ci.draw_arc(oc, 15, -PI * 0.15, PI * 0.65, 14, Color(th["ink"], 0.9), 2.0, true)
		_:
			ci.draw_circle(oc, 18, IconDraw.OUTLINE)
			ci.draw_circle(oc, 16, ec.darkened(0.35))
			ci.draw_circle(oc + Vector2(-1.5, -1.5), 13, ec)
	draw_num(ci, f, oc, str(card["cost"]), txt_col)


static func draw_num(ci: CanvasItem, f: Font, oc: Vector2, s: String, col: Color) -> void:
	ci.draw_string_outline(f, oc + Vector2(-15, 8), s, HORIZONTAL_ALIGNMENT_CENTER, 30, 21, 3, Color(1, 1, 1, 0.45))
	ci.draw_string(f, oc + Vector2(-15, 8), s, HORIZONTAL_ALIGNMENT_CENTER, 30, 21, col)
