extends Screen
## Choose one of three heroes.

var _selected := "clockwright"
var _panels := {}
var _t := 0.0
var _embark: Button


func _ready() -> void:
	var col := UI.vbox(18)
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(col)
	col.add_child(UI.label("Choose Your Hero", 40, Palette.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var row := UI.hbox(24)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(row)
	for id in CharacterDatabase.ORDER:
		var p := _hero_panel(id)
		row.add_child(p)
		_panels[id] = p
	var foot := UI.hbox(24)
	foot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	foot.add_child(UI.button("Back", func(): GameManager.goto("menu")))
	_embark = UI.accent_button("Embark", _start, Palette.GOLD, Vector2(260, 64))
	foot.add_child(_embark)
	col.add_child(foot)
	_select(_selected)


func _process(delta: float) -> void:
	_t += delta
	for id in _panels:
		_panels[id].get_meta("portrait").queue_redraw()


func _draw() -> void:
	draw_backdrop(Color(CharacterDatabase.get_character(_selected)["color"]))


func _hero_panel(id: String) -> PanelContainer:
	var ch: Dictionary = CharacterDatabase.get_character(id)
	var p := UI.panel()
	p.custom_minimum_size = Vector2(340, 500)
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	p.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and not ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_select(id))
	var v := UI.vbox(8, BoxContainer.ALIGNMENT_BEGIN)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(v)
	var portrait := Portrait.new(self, ch["shape"], Color(ch["color"]))
	v.add_child(portrait)
	p.set_meta("portrait", portrait)
	v.add_child(UI.label(ch["name"], 28, Color(ch["color"]), HORIZONTAL_ALIGNMENT_CENTER))
	v.add_child(UI.label(ch["title"], 15, Palette.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER))
	v.add_child(UI.label("Mechanic: %s" % ch["mechanic_name"], 16, Color(ch["color"]).lightened(0.3), HORIZONTAL_ALIGNMENT_CENTER))
	var d := UI.wrap_label(ch["desc"], 16, Palette.TEXT)
	d.custom_minimum_size = Vector2(290, 0)
	v.add_child(d)
	v.add_child(UI.label("HP %d   ·   Gold %d" % [ch["hp"], ch["gold"]], 17, Palette.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER))
	var rr := UI.hbox(8)
	rr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rr.add_child(RelicIcon.new(ch["relic"], 36))
	var rel: Dictionary = RelicDatabase.get_relic(ch["relic"])
	var rl := UI.wrap_label("%s: %s" % [rel["name"], rel["desc"]], 14, Palette.GOLD, HORIZONTAL_ALIGNMENT_LEFT)
	rl.custom_minimum_size = Vector2(240, 0)
	rr.add_child(rl)
	v.add_child(rr)
	return p


func _select(id: String) -> void:
	_selected = id
	for k in _panels:
		var ch: Dictionary = CharacterDatabase.get_character(k)
		var on: bool = k == id
		var sb := Palette.flat(Palette.PANEL if not on else Color(ch["color"]).darkened(0.75), 18, Color(ch["color"]) if on else Palette.LINE, 4 if on else 2)
		sb.content_margin_left = 20
		sb.content_margin_right = 20
		sb.content_margin_top = 16
		sb.content_margin_bottom = 16
		_panels[k].add_theme_stylebox_override("panel", sb)
		var tw := create_tween()
		tw.tween_property(_panels[k], "modulate", Color.WHITE if on else Color(0.7, 0.7, 0.75), 0.15)
	queue_redraw()


func _start() -> void:
	GameManager.new_run(_selected)


func on_back() -> bool:
	GameManager.goto("menu")
	return true


class Portrait extends Control:
	var owner_screen
	var shape: String
	var color: Color

	func _init(o, s: String, c: Color) -> void:
		owner_screen = o
		shape = s
		color = c
		custom_minimum_size = Vector2(0, 170)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var c := Vector2(size.x / 2.0, 88)
		IconDraw.glow(self, c, 84, color, 6)
		IconDraw.oval(self, c + Vector2(0, 62), 70, 13, color.darkened(0.6), 2.0)
		IconDraw.creature(self, shape, c, 58, color, owner_screen._t, 1.0)
