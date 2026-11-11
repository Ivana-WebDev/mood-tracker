class_name CardView
extends Control
## A single card drawn with vector primitives. Emits gesture signals; containers decide behaviour.

signal pressed_at(view: CardView, pos: Vector2)
signal dragged_to(view: CardView, pos: Vector2)
signal released_at(view: CardView, pos: Vector2)
signal tapped(view: CardView)

const CARD_SIZE := Vector2(160, 224)
const TAP_SLOP := 14.0

var inst: Dictionary = {}       # {uid, id, upgraded}
var data: Dictionary = {}       # resolved definition
var ctx = null                  # CombatManager for live numbers
var playable: bool = false
var highlight: bool = false
var selected: bool = false
var show_glow: bool = true
var _press_pos := Vector2.ZERO
var _pressing := false
var _moved := false
var _desc: Label


func _init(card_inst: Dictionary = {}, combat = null) -> void:
	inst = card_inst
	ctx = combat
	custom_minimum_size = CARD_SIZE
	size = CARD_SIZE
	pivot_offset = CARD_SIZE / 2.0
	mouse_filter = Control.MOUSE_FILTER_STOP


func _ready() -> void:
	_desc = Label.new()
	_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_desc.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_desc.add_theme_font_size_override("font_size", 14)
	_desc.add_theme_color_override("font_color", Palette.TEXT)
	_desc.add_theme_constant_override("line_spacing", -2)
	_desc.position = Vector2(10, 131)
	_desc.size = Vector2(CARD_SIZE.x - 20, 82)
	_desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_desc.clip_text = true
	add_child(_desc)
	refresh()


func set_card(card_inst: Dictionary) -> void:
	inst = card_inst
	refresh()


func refresh(target = null) -> void:
	if inst.is_empty():
		return
	data = CardDatabase.resolve(inst["id"], inst.get("upgraded", false))
	if _desc:
		_desc.text = CardDatabase.describe(data, ctx, target)
		var lines := _desc.get_line_count()
		_desc.add_theme_font_size_override("font_size", 14 if lines <= 4 else 12)
	queue_redraw()


static func rounded_pts(r: Rect2, rad: float, seg: int = 5) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var corners := [[r.position + Vector2(rad, rad), PI], [Vector2(r.end.x - rad, r.position.y + rad), PI * 1.5],
		[r.end - Vector2(rad, rad), 0.0], [Vector2(r.position.x + rad, r.end.y - rad), PI * 0.5]]
	for c in corners:
		for i in seg + 1:
			var a: float = c[1] + i * (PI / 2.0) / seg
			pts.append(c[0] + Vector2(cos(a), sin(a)) * rad)
	return pts


func _gradient_poly(pts: PackedVector2Array, top: Color, bottom: Color, y0: float, y1: float) -> void:
	var cols := PackedColorArray()
	for p in pts:
		cols.append(top.lerp(bottom, clampf((p.y - y0) / maxf(1.0, y1 - y0), 0.0, 1.0)))
	draw_polygon(pts, cols)


func _draw() -> void:
	if data.is_empty():
		return
	var type_col := Palette.type_color(data["type"])
	var rare_col: Color = Palette.RARITY.get(data["rarity"], Palette.LINE)
	var rect := Rect2(Vector2.ZERO, CARD_SIZE)
	var f := UI.font()
	# Soft shadow
	for i in 3:
		draw_style_box(Palette.flat(Color(0, 0, 0, 0.16), 18), Rect2(Vector2(2 + i * 2, 5 + i * 2), CARD_SIZE))
	# Glow for playable / selection
	if (playable and show_glow) or selected or highlight:
		var gcol := Palette.GOLD if (selected or highlight) else Palette.GOOD
		for i in 3:
			draw_style_box(Palette.flat(Color(gcol, 0.0), 20 + i * 2, Color(gcol, 0.55 - i * 0.16), 3), rect.grow(3 + i * 3))
	# Body gradient + frame
	var body := rounded_pts(rect, 16)
	_gradient_poly(body, type_col.darkened(0.62), Palette.BG.darkened(0.2), 0.0, CARD_SIZE.y)
	var border := Palette.GOOD if data.get("upgraded", false) else type_col
	draw_style_box(Palette.flat(Color(0, 0, 0, 0), 16, border, 3), rect)
	draw_style_box(Palette.flat(Color(0, 0, 0, 0), 12, Color(rare_col, 0.55), 1), rect.grow(-6))
	# Rivets
	for p in [Vector2(10, 64), Vector2(CARD_SIZE.x - 10, 64), Vector2(10, CARD_SIZE.y - 12), Vector2(CARD_SIZE.x - 10, CARD_SIZE.y - 12)]:
		draw_circle(p, 2.5, Color(rare_col, 0.8))
	# Art window
	var art := Rect2(14, 42, CARD_SIZE.x - 28, 74)
	var art_pts := rounded_pts(art, 9)
	_gradient_poly(art_pts, type_col.darkened(0.25).lerp(Palette.BG, 0.25), Palette.BG.darkened(0.3), art.position.y, art.end.y)
	_draw_art(art)
	var closed := art_pts.duplicate()
	closed.append(art_pts[0])
	draw_polyline(closed, Color(type_col.lightened(0.1), 0.9), 2.0, true)
	# Name ribbon (notched banner across the top of the art)
	var by := 10.0
	var banner := PackedVector2Array([Vector2(4, by + 2), Vector2(CARD_SIZE.x - 4, by + 2), Vector2(CARD_SIZE.x - 12, by + 15),
		Vector2(CARD_SIZE.x - 4, by + 28), Vector2(4, by + 28), Vector2(12, by + 15)])
	_gradient_poly(banner, type_col.darkened(0.15), type_col.darkened(0.55), by, by + 28)
	var bc := banner.duplicate()
	bc.append(banner[0])
	draw_polyline(bc, IconDraw.OUTLINE, 2.0, true)
	var name_col := Color("c9ffd9") if data.get("upgraded", false) else Palette.TEXT
	var name_size := 16 if data["name"].length() <= 12 else (14 if data["name"].length() <= 15 else 12)
	draw_string_outline(f, Vector2(18, by + 21), data["name"], HORIZONTAL_ALIGNMENT_CENTER, CARD_SIZE.x - 36, name_size, 4, Color(0, 0, 0, 0.6))
	draw_string(f, Vector2(18, by + 21), data["name"], HORIZONTAL_ALIGNMENT_CENTER, CARD_SIZE.x - 36, name_size, name_col)
	# Type plate + rarity gem
	var plate := Rect2(CARD_SIZE.x / 2.0 - 34, 110, 68, 18)
	draw_style_box(Palette.flat(Palette.BG_2, 9, Color(type_col, 0.8), 1), plate)
	draw_string(f, Vector2(plate.position.x, plate.position.y + 13), data["type"].capitalize(), HORIZONTAL_ALIGNMENT_CENTER, plate.size.x, 11, Palette.TEXT_DIM)
	var gem := Vector2(CARD_SIZE.x / 2.0, CARD_SIZE.y - 7)
	IconDraw.fill(self, PackedVector2Array([gem + Vector2(0, -6), gem + Vector2(6, 0), gem + Vector2(0, 6), gem + Vector2(-6, 0)]), rare_col, 1.5, true)
	# Cost gem
	if int(data["cost"]) >= 0:
		var oc := Vector2(15, 15)
		var can := playable or ctx == null
		var ec := Palette.ENERGY if can else Palette.TEXT_DIM.darkened(0.3)
		draw_circle(oc, 18, IconDraw.OUTLINE)
		draw_circle(oc, 16, ec.darkened(0.35))
		draw_circle(oc + Vector2(-1.5, -1.5), 13, ec)
		draw_circle(oc + Vector2(-5, -6), 4, Color(1, 1, 1, 0.45))
		draw_string_outline(f, oc + Vector2(-15, 8), str(data["cost"]), HORIZONTAL_ALIGNMENT_CENTER, 30, 21, 3, Color(1, 1, 1, 0.4))
		draw_string(f, oc + Vector2(-15, 8), str(data["cost"]), HORIZONTAL_ALIGNMENT_CENTER, 30, 21, Palette.BG)


## Picks an illustration motif from the card's signature effect.
func _draw_art(r: Rect2) -> void:
	var c := r.get_center()
	var type_col := Palette.type_color(data["type"])
	var h := hash(data["id"])
	# Background flecks unique per card
	for i in 7:
		var px := r.position.x + 8 + float((h >> (i * 3)) % 97) / 97.0 * (r.size.x - 16)
		var py := r.position.y + 6 + float((h >> (i * 2 + 5)) % 61) / 61.0 * (r.size.y - 12)
		draw_circle(Vector2(px, py), 1.2 + i % 2, Color(1, 1, 1, 0.12))
	var motif := _motif()
	var accent := type_col.lightened(0.2)
	match motif:
		"gadget":
			var kind: String = _first_effect("gadget").get("kind", "turret")
			var gd: Dictionary = CardDatabase.GADGETS[kind]
			IconDraw.gear(self, c + Vector2(-34, 12), 22, 17, 9, Color("6e6a73"), float(h % 7))
			IconDraw.gear(self, c + Vector2(36, -16), 14, 11, 7, Color("8a7a5a"), float(h % 5))
			IconDraw.glow(self, c, 30, Color(gd["color"]), 4)
			IconDraw.icon(self, gd["icon"], c, 26, Color(gd["color"]))
		"overclock":
			IconDraw.gear(self, c, 30, 23, 10, Color("c9a050"), 0.3)
			IconDraw.icon(self, "bolt", c + Vector2(26, -14), 16, Palette.ENERGY)
			IconDraw.icon(self, "bolt", c + Vector2(-28, 16), 12, Palette.ENERGY)
		"dice":
			IconDraw.glow(self, c, 34, Color("b18cff"), 4)
			IconDraw.die(self, c + Vector2(-22, 6), 17, 1 + h % 6, Color("f5f1ff"), -0.3)
			IconDraw.die(self, c + Vector2(20, -6), 17, 1 + (h >> 4) % 6, Color("ffe29a"), 0.25)
		"flow":
			IconDraw.ribbon(self, c + Vector2(-50, 18), Vector2(1, -0.3).normalized(), 104, 12, Color("3fd6b4"), float(h % 10), 1.3)
			IconDraw.ribbon(self, c + Vector2(-50, -10), Vector2(1, 0.25).normalized(), 100, 9, Color("ff8fb8"), float(h % 13), 1.6)
		"multi":
			for k in 3:
				var o := Vector2((k - 1) * 18, (k - 1) * 6)
				draw_line(c + o + Vector2(-26, -22), c + o + Vector2(22, 24), Color(1, 1, 1, 0.85 - k * 0.2), 4.0 - k, true)
			IconDraw.icon(self, "attack", c + Vector2(0, 2), 22, accent)
		"aoe":
			for k in 3:
				draw_arc(c + Vector2(-46, 0), 30 + k * 18, -0.8, 0.8, 18, Color(accent, 0.9 - k * 0.25), 4.0, true)
			IconDraw.icon(self, "attack", c + Vector2(-38, 0), 18, accent)
		"strike":
			draw_line(c + Vector2(-44, 24), c + Vector2(44, -26), Color(1, 1, 1, 0.75), 3.0, true)
			IconDraw.glow(self, c, 22, accent, 3)
			IconDraw.icon(self, "attack", c, 28, accent)
		"block":
			IconDraw.glow(self, c, 34, Palette.BLOCK, 4)
			IconDraw.icon(self, "shield", c, 28, Palette.BLOCK.lightened(0.1))
		"debuff":
			IconDraw.glow(self, c, 30, Palette.DEBUFF, 4)
			IconDraw.oval(self, c, 30, 16, Color("fff6e6"), 2.0)
			draw_circle(c, 11, Palette.DEBUFF)
			draw_circle(c, 5, Palette.BG)
		"draw":
			IconDraw.icon(self, "cards", c, 26, Color("dfe6f5"))
		"energy":
			IconDraw.glow(self, c, 32, Palette.ENERGY, 4)
			IconDraw.icon(self, "bolt", c, 28, Palette.ENERGY)
		"heal":
			IconDraw.glow(self, c, 30, Palette.GOOD, 4)
			IconDraw.icon(self, "heart", c, 26, Palette.GOOD.lightened(0.2))
		"power":
			for k in 12:
				var a := k * TAU / 12.0
				draw_line(c + Vector2(cos(a), sin(a)) * 16, c + Vector2(cos(a), sin(a)) * 36, Color(Palette.POWER, 0.35), 2.0)
			IconDraw.icon(self, "star", c, 26, Palette.POWER)
		"curse":
			IconDraw.icon(self, "debuff", c, 26, Palette.CURSE.lightened(0.3))
			draw_line(c + Vector2(-30, -20), c + Vector2(30, 22), Color(Palette.BAD, 0.6), 3.0)
		_:
			IconDraw.icon(self, data["type"], c, 26, accent)


func _first_effect(t: String) -> Dictionary:
	for e in data.get("effects", []):
		if e["type"] == t:
			return e
	return {}


func _motif() -> String:
	if data["type"] in ["status", "curse"]:
		return "curse"
	var effs: Array = data.get("effects", [])
	for e in effs:
		match e["type"]:
			"gadget": return "gadget"
			"overclock", "wind", "tune": return "overclock"
			"die_damage", "die_block", "reroll", "add_die", "bump", "set_low", "set_all", "double_high", "dice_sum": return "dice"
			"burst": return "flow"
	for e in effs:
		if e["type"] == "apply" and e["status"] in ["flow", "grace", "rhythm", "spotlight"]:
			return "flow"
	if data["type"] == "power":
		return "power"
	var first: Dictionary = effs[0] if not effs.is_empty() else {}
	match first.get("type", ""):
		"damage", "damage_per":
			if first.get("target", "") == "all":
				return "aoe"
			if int(first.get("times", 1)) > 1:
				return "multi"
			return "strike"
		"block", "block_per", "double_block": return "block"
		"apply": return "debuff"
		"draw": return "draw"
		"energy": return "energy"
		"heal": return "heal"
	return ""


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_pressing = true
			_moved = false
			_press_pos = event.global_position
			pressed_at.emit(self, event.global_position)
		elif _pressing:
			_pressing = false
			released_at.emit(self, event.global_position)
			if not _moved:
				tapped.emit(self)
	elif event is InputEventMouseMotion and _pressing:
		if event.global_position.distance_to(_press_pos) > TAP_SLOP:
			_moved = true
		if _moved:
			dragged_to.emit(self, event.global_position)
