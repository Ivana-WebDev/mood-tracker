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
	_desc.position = Vector2(10, 138)
	_desc.size = Vector2(CARD_SIZE.x - 20, 76)
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


func _draw() -> void:
	if data.is_empty():
		return
	var type_col := Palette.type_color(data["type"])
	var rect := Rect2(Vector2.ZERO, CARD_SIZE)
	# Shadow
	draw_style_box(Palette.flat(Color(0, 0, 0, 0.45), 16), Rect2(Vector2(4, 7), CARD_SIZE))
	# Glow for playable / selection
	if (playable and show_glow) or selected or highlight:
		var gcol := Palette.GOLD if (selected or highlight) else Palette.GOOD
		draw_style_box(Palette.flat(Color(gcol, 0.0), 20, Color(gcol, 0.85), 4), rect.grow(5))
	# Body
	var border := type_col
	if data.get("upgraded", false):
		border = Palette.GOOD
	draw_style_box(Palette.flat(Palette.PANEL, 16, border, 3), rect)
	# Name banner
	var banner := Rect2(8, 8, CARD_SIZE.x - 16, 30)
	draw_style_box(Palette.flat(type_col.darkened(0.55), 10), banner)
	var f := UI.font()
	var name_col := Palette.GOOD.lightened(0.3) if data.get("upgraded", false) else Palette.TEXT
	var name_size := 17 if data["name"].length() <= 13 else 14
	draw_string(f, Vector2(8, 30), data["name"], HORIZONTAL_ALIGNMENT_CENTER, CARD_SIZE.x - 16, name_size, name_col)
	# Art panel
	var art := Rect2(14, 44, CARD_SIZE.x - 28, 72)
	draw_style_box(Palette.flat(type_col.darkened(0.72), 10, type_col.darkened(0.35), 1), art)
	for i in 4:
		draw_line(art.position + Vector2(0, 18 * i + 8), art.position + Vector2(art.size.x, 18 * i - 6), Color(type_col, 0.07), 6.0)
	var icon_kind: String = data["type"]
	if data["type"] in ["status", "curse"]:
		icon_kind = "debuff"
	IconDraw.icon(self, icon_kind, art.get_center(), 28, type_col.lightened(0.15))
	# Type line + rarity gem
	var type_txt: String = data["type"].capitalize()
	draw_string(f, Vector2(0, 132), type_txt, HORIZONTAL_ALIGNMENT_CENTER, CARD_SIZE.x, 12, Palette.TEXT_DIM)
	var gem := Vector2(CARD_SIZE.x / 2.0, 118)
	var rc: Color = Palette.RARITY.get(data["rarity"], Palette.LINE)
	draw_colored_polygon(PackedVector2Array([gem + Vector2(0, -5), gem + Vector2(5, 0), gem + Vector2(0, 5), gem + Vector2(-5, 0)]), rc)
	# Cost orb
	if int(data["cost"]) >= 0:
		var oc := Vector2(14, 14)
		var can := playable or ctx == null
		draw_circle(oc, 17, Palette.BG)
		draw_circle(oc, 15, Palette.ENERGY if can else Palette.TEXT_DIM.darkened(0.3))
		draw_string(f, oc + Vector2(-15, 7), str(data["cost"]), HORIZONTAL_ALIGNMENT_CENTER, 30, 20, Palette.BG)


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
