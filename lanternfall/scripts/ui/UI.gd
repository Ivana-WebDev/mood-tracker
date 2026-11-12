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
	b.add_theme_stylebox_override("normal", Palette.flat(color.darkened(0.55), 14, color, 3))
	b.add_theme_stylebox_override("hover", Palette.flat(color.darkened(0.4), 14, color.lightened(0.2), 3))
	b.add_theme_stylebox_override("pressed", Palette.flat(color.darkened(0.7), 14, color, 3))
	b.add_theme_color_override("font_color", color.lightened(0.5))
	return b


static func panel(bg: Color = Palette.PANEL, radius: int = 18, border: Color = Palette.LINE) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := Palette.flat(bg, radius, border, 2)
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 20
	sb.content_margin_bottom = 20
	p.add_theme_stylebox_override("panel", sb)
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


static func toast(from: Node, text: String, color: Color = Palette.TEXT) -> void:
	var m := main(from)
	if m != null and m.has_method("show_toast"):
		m.show_toast(text, color)
