class_name UI
## Small factory helpers for code-built UI.

static func font() -> Font:
	return ThemeDB.fallback_font


static func label(text: String, size: int = 20, color: Color = Palette.TEXT, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func wrap_label(text: String, size: int = 18, color: Color = Palette.TEXT_DIM, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := label(text, size, color, align)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


static func button(text: String, callback: Callable, min_size: Vector2 = Vector2(220, 64), font_size: int = 22) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = min_size
	b.add_theme_font_size_override("font_size", font_size)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(func(): AudioManager.play("click", -6.0))
	b.pressed.connect(callback)
	return b


static func accent_button(text: String, callback: Callable, color: Color = Palette.GOLD, min_size: Vector2 = Vector2(220, 64)) -> Button:
	var b := button(text, callback, min_size)
	UISkin.style_button(b, color.darkened(0.5), color, color.lightened(0.35), color.lightened(0.6))
	return b


static func panel(bg: Color = Palette.PANEL, _radius: int = 18, border: Color = Palette.LINE) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UISkin.panel_box(bg, border, 20))
	return p


static func vbox(sep: int = 12, align: BoxContainer.AlignmentMode = BoxContainer.ALIGNMENT_CENTER) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", sep)
	v.alignment = align
	return v


static func hbox(sep: int = 12, align: BoxContainer.AlignmentMode = BoxContainer.ALIGNMENT_CENTER) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", sep)
	h.alignment = align
	return h


static func dim_layer(alpha: float = 0.78) -> ColorRect:
	var r := ColorRect.new()
	r.color = Color(0.03, 0.035, 0.06, alpha)
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_STOP
	return r


static func center(node: Control) -> CenterContainer:
	var c := CenterContainer.new()
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(node)
	return c


static func main(node: Node) -> Node:
	return node.get_tree().root.get_node_or_null("Main")


static func tooltip(from: Node, title: String, body: String, at: Vector2) -> void:
	var m := main(from)
	if m != null and m.has_method("show_tooltip"):
		m.show_tooltip(title, body, at)


## Shows a tooltip while the mouse is over `node` (and on tap for touch screens).
static func hover_tip(node: Control, title: String, body: String) -> void:
	node.mouse_entered.connect(func(): tooltip(node, title, body, node.get_global_rect().get_center()))
	node.mouse_exited.connect(func():
		var m := main(node)
		if m != null:
			m.hide_tooltip())


static func relic_tip(id: String) -> Array:
	var r: Dictionary = RelicDatabase.get_relic(id)
	return [r["name"], "%s relic\n%s" % [str(r["rarity"]).capitalize(), r["desc"]]]


static func potion_tip(id: String) -> Array:
	var p: Dictionary = PotionDatabase.get_potion(id)
	return [p["name"], "%s potion\n%s%s" % [str(p["rarity"]).capitalize(), p["desc"], "\nCan be used outside combat." if p.get("anywhere", false) else ""]]


static func card_tip(id: String) -> Array:
	var c := CardDatabase.resolve(id)
	var kind := "Curse" if c["type"] == "curse" else ("Status card" if c["type"] == "status" else str(c["type"]).capitalize())
	return [c["name"], "%s\n%s" % [kind, CardDatabase.describe(c)]]


static var _grabber: Texture2D


static func _grabber_tex() -> Texture2D:
	if _grabber == null:
		var n := 30
		var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
		for y in n:
			for x in n:
				var d := Vector2(x - n / 2.0 + 0.5, y - n / 2.0 + 0.5).length()
				if d <= n / 2.0 - 1:
					img.set_pixel(x, y, Palette.GOLD if d < n / 2.0 - 4 else Palette.GOLD.darkened(0.45))
		_grabber = ImageTexture.create_from_image(img)
	return _grabber


## "Music  [=====o----]  80%" row bound to a 0..1 profile value.
static func volume_row(title: String, key: String, width: float, on_change: Callable) -> HBoxContainer:
	var row := hbox(14)
	var l := label(title, 20, Palette.TEXT)
	l.custom_minimum_size = Vector2(150, 0)
	row.add_child(l)
	var s := HSlider.new()
	s.min_value = 0
	s.max_value = 100
	s.step = 5
	s.value = round(float(SaveManager.profile.get(key, 0.8)) * 100.0)
	s.custom_minimum_size = Vector2(width - 240, 40)
	s.focus_mode = Control.FOCUS_NONE
	s.add_theme_icon_override("grabber", _grabber_tex())
	s.add_theme_icon_override("grabber_highlight", _grabber_tex())
	var track := Palette.flat(Palette.BG_2, 6, Palette.LINE, 1)
	track.content_margin_top = 5
	track.content_margin_bottom = 5
	s.add_theme_stylebox_override("slider", track)
	s.add_theme_stylebox_override("grabber_area", Palette.flat(Palette.GOLD.darkened(0.3), 6))
	s.add_theme_stylebox_override("grabber_area_highlight", Palette.flat(Palette.GOLD.darkened(0.2), 6))
	row.add_child(s)
	var v := label("%d%%" % int(s.value), 18, Palette.TEXT_DIM)
	v.custom_minimum_size = Vector2(56, 0)
	row.add_child(v)
	s.value_changed.connect(func(val):
		v.text = "%d%%" % int(val)
		SaveManager.profile[key] = val / 100.0
		on_change.call())
	s.drag_ended.connect(func(_changed): SaveManager.save_profile())
	return row


static func toast(from: Node, text: String, color: Color = Palette.TEXT) -> void:
	var m := main(from)
	if m != null and m.has_method("show_toast"):
		m.show_toast(text, color)
