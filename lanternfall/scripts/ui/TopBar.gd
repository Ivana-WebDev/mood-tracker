class_name TopBar
extends PanelContainer
## Persistent run HUD: hero, HP, gold, act/floor, relics, deck + menu buttons.

const HEIGHT := 60

var _hp: Label
var _gold: Label
var _floor: Label
var _relics: HBoxContainer
var _deck_btn: Button
var _map_btn: Button
var _potions: HBoxContainer
var hp_override := Vector2i(-1, -1)


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	custom_minimum_size = Vector2(0, HEIGHT)
	var sb := Palette.flat(Color(Palette.BG_2, 0.94), 0, Palette.LINE, 0)
	sb.border_width_bottom = 2
	sb.border_color = Palette.LINE
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	add_theme_stylebox_override("panel", sb)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _ready() -> void:
	var row := UI.hbox(18, BoxContainer.ALIGNMENT_BEGIN)
	add_child(row)
	var ch: Dictionary = CharacterDatabase.get_character(GameManager.run.get("character", "clockwright"))
	row.add_child(UI.label(ch.get("name", ""), 20, Color(ch.get("color", "ffffff"))))
	_hp = _stat(row, "heart", Palette.HP)
	_gold = _stat(row, "coin", Palette.GOLD)
	_floor = UI.label("", 18, Palette.TEXT_DIM)
	row.add_child(_floor)
	_potions = UI.hbox(4, BoxContainer.ALIGNMENT_BEGIN)
	row.add_child(_potions)
	_relics = UI.hbox(6, BoxContainer.ALIGNMENT_BEGIN)
	var rs := ScrollContainer.new()
	rs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rs.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rs.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	rs.add_child(_relics)
	row.add_child(rs)
	_map_btn = UI.button("Map", _show_map, Vector2(84, 46), 18)
	row.add_child(_map_btn)
	_deck_btn = UI.button("Deck", _show_deck, Vector2(110, 46), 18)
	row.add_child(_deck_btn)
	row.add_child(UI.button("Menu", _open_menu, Vector2(96, 46), 18))
	GameManager.run_changed.connect(refresh)
	RelicManager.relics_changed.connect(refresh)
	refresh()


func _stat(row: HBoxContainer, icon: String, color: Color) -> Label:
	var ic := IconBadge.new(icon, color)
	row.add_child(ic)
	var l := UI.label("", 20, color)
	row.add_child(l)
	return l


func set_hp(hp: int, max_hp: int) -> void:
	hp_override = Vector2i(hp, max_hp)
	refresh()


func refresh() -> void:
	var run := GameManager.run
	if run.is_empty() or _hp == null:
		return
	if hp_override.x >= 0:
		_hp.text = "%d/%d" % [hp_override.x, hp_override.y]
	else:
		_hp.text = "%d/%d" % [int(run["hp"]), int(run["max_hp"])]
	_gold.text = str(run["gold"])
	_floor.text = "Act %d  ·  Floor %d" % [int(run["act"]), int(run["floor"])]
	_deck_btn.text = "Deck %d" % run["deck"].size()
	for c in _potions.get_children():
		c.queue_free()
	var pots: Array = run.get("potions", [])
	for i in PotionDatabase.MAX_SLOTS:
		_potions.add_child(PotionIcon.new(i, pots[i] if i < pots.size() else "", 40))
	var on_map: bool = get_parent() is Screen and get_parent().screen_name == "map"
	_map_btn.visible = not on_map
	for c in _relics.get_children():
		c.queue_free()
	for id in run["relics"]:
		_relics.add_child(RelicIcon.new(id, 42))


func _process(_d: float) -> void:
	if _hp == null:
		return
	var parts := _hp.text.split("/")
	if parts.size() == 2 and int(parts[1]) > 0 and float(int(parts[0])) / float(int(parts[1])) < LowHPOverlay.THRESHOLD:
		var p := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * 8.0)
		_hp.modulate = Color(1, 1, 1).lerp(Color(1.6, 0.6, 0.6), p)
		_hp.scale = Vector2.ONE * (1.0 + 0.08 * p)
	else:
		_hp.modulate = Color.WHITE
		_hp.scale = Vector2.ONE


func _show_map() -> void:
	Overlay.open(self, MapOverlay.new())


func _show_deck() -> void:
	Overlay.open(self, DeckViewer.new(GameManager.run["deck"], "Your Deck"))


func _open_menu() -> void:
	var m := UI.main(self)
	if m:
		m.open_pause()


class IconBadge extends Control:
	var kind: String
	var color: Color

	func _init(k: String, c: Color) -> void:
		kind = k
		color = c
		custom_minimum_size = Vector2(28, 28)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		IconDraw.icon(self, kind, size / 2.0, 12, color)
