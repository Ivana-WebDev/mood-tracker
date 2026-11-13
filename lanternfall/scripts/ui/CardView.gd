class_name CardView
extends Control
## A single card drawn with vector primitives. Emits gesture signals; containers decide behaviour.

signal pressed_at(view: CardView, pos: Vector2)
signal dragged_to(view: CardView, pos: Vector2)
signal released_at(view: CardView, pos: Vector2)
signal tapped(view: CardView)
signal hover_changed(view: CardView, on: bool)

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
var _rim: Control


func _init(card_inst: Dictionary = {}, combat = null) -> void:
	inst = card_inst
	ctx = combat
	custom_minimum_size = CARD_SIZE
	size = CARD_SIZE
	pivot_offset = CARD_SIZE / 2.0
	mouse_filter = Control.MOUSE_FILTER_STOP


func _ready() -> void:
	mouse_entered.connect(func(): hover_changed.emit(self, true))
	mouse_exited.connect(func(): hover_changed.emit(self, false))
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
	_rim = CardRim.new(self)
	add_child(_rim)
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
		_desc.add_theme_font_size_override("font_size", 14 if lines <= 4 else (12 if lines <= 5 else 11))
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
	if selected or highlight:
		var gcol := Palette.GOLD
		for i in 3:
			draw_style_box(Palette.flat(Color(gcol, 0.0), 20 + i * 2, Color(gcol, 0.55 - i * 0.16), 3), rect.grow(3 + i * 3))
	# Hero-themed body, text plate and frame (see CardFrame.gd)
	var body := rounded_pts(rect, 16)
	CardFrame.draw_body(self, data, body)
	CardFrame.draw_text_plate(self, data)
	# Art window
	var art := Rect2(14, 42, CARD_SIZE.x - 28, 72)
	var art_pts := rounded_pts(art, 9)
	_gradient_poly(art_pts, type_col.darkened(0.25).lerp(Palette.BG, 0.25), Palette.BG.darkened(0.3), art.position.y, art.end.y)
	_draw_art(art)
	# Inner vignette + bevelled art frame
	var closed := art_pts.duplicate()
	closed.append(art_pts[0])
	draw_polyline(closed, Color(0, 0, 0, 0.35), 5.0, true)
	var th := CardFrame.theme_for(data)
	var trim := CardFrame.trim_color(th, str(data.get("rarity", "common")))
	draw_polyline(closed, IconDraw.OUTLINE, 3.5, true)
	draw_polyline(closed, trim.darkened(0.15), 2.0, true)
	draw_line(art.position + Vector2(9, 1), Vector2(art.end.x - 9, art.position.y + 1), Color(1, 1, 1, 0.25), 1.0, true)
	CardFrame.draw_frame(self, data, rect, data.get("upgraded", false))
	CardFrame.draw_banner(self, data)
	var name_col := Color("c9ffd9") if data.get("upgraded", false) else Palette.TEXT
	var by := 10.0
	var name_size := 16 if data["name"].length() <= 11 else (14 if data["name"].length() <= 14 else 12)
	draw_string_outline(f, Vector2(32, by + 20), data["name"], HORIZONTAL_ALIGNMENT_CENTER, CARD_SIZE.x - 42, name_size, 4, Color(0, 0, 0, 0.7))
	draw_string(f, Vector2(32, by + 20), data["name"], HORIZONTAL_ALIGNMENT_CENTER, CARD_SIZE.x - 42, name_size, name_col)
	CardFrame.draw_plaque(self, data, f)
	# Rarity gem at the foot of the card
	var gem := Vector2(CARD_SIZE.x / 2.0, CARD_SIZE.y - 7)
	if th["id"] != "duskdancer":
		CardFrame.gem(self, gem, 5.5, rare_col)
	CardFrame.draw_cost(self, data, playable or ctx == null, f)


## Every card has its own illustration (see CardArt.gd).
func _draw_art(r: Rect2) -> void:
	CardArt.draw(self, data, r)


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
			"die_damage", "die_block", "reroll", "add_die", "bump", "set_low", "set_all", "double_high", "dice_sum", "dice_sum_block": return "dice"
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


## Animated glow around playable cards: a pulsing rim with a spark tracing the edge.
## A separate child so the (expensive) card face does not have to redraw every frame.
class CardRim:
	extends Control
	var card: CardView
	var _t := 0.0

	func _init(cv: CardView) -> void:
		card = cv
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = CARD_SIZE
		_t = randf() * 5.0

	func _process(d: float) -> void:
		var on := card.playable and card.show_glow and not card.selected and not card.highlight
		visible = on
		if on:
			_t += d
			queue_redraw()

	func _draw() -> void:
		var rect := Rect2(Vector2.ZERO, CARD_SIZE)
		var pulse := 0.5 + 0.5 * sin(_t * 3.0)
		var g := Palette.GOOD
		for i in 3:
			draw_style_box(Palette.flat(Color(g, 0.0), 20 + i * 2, Color(g, (0.45 - i * 0.13) * (0.6 + 0.4 * pulse)), 3), rect.grow(3 + i * 3))
		# Spark running around the perimeter.
		var per := 2.0 * (CARD_SIZE.x + CARD_SIZE.y)
		for k in 2:
			var dist := fmod(_t * 170.0 + k * per * 0.5, per)
			var p := _perimeter(dist).lerp(CARD_SIZE / 2.0, -0.02)
			for j in 5:
				var q := _perimeter(fmod(dist - j * 7.0 + per, per))
				draw_circle(q, 3.2 - j * 0.5, Color(Color("d8ffe0"), 0.75 - j * 0.14))
			draw_circle(p, 8.0, Color(g, 0.18))

	func _perimeter(dist: float) -> Vector2:
		var w := CARD_SIZE.x + 3.0
		var h := CARD_SIZE.y + 3.0
		var o := Vector2(-1.5, -1.5)
		if dist < w:
			return o + Vector2(dist, 0)
		dist -= w
		if dist < h:
			return o + Vector2(w, dist)
		dist -= h
		if dist < w:
			return o + Vector2(w - dist, h)
		dist -= w
		return o + Vector2(0, h - minf(dist, h))
