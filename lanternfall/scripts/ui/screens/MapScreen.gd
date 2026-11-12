extends Screen
## Horizontally-scrolling branching map (landscape). Drag to pan, tap a glowing node to travel.

const FLOOR_SPACING := 150.0
const MARGIN_X := 110.0
const NODE_R := 26.0

var map_view: MapView


func _ready() -> void:
	map_view = MapView.new()
	map_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map_view.offset_top = TopBar.HEIGHT
	add_child(map_view)
	add_top_bar()
	var legend := UI.hbox(18, BoxContainer.ALIGNMENT_BEGIN)
	legend.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	legend.position = Vector2(20, -46)
	legend.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for t in ["monster", "elite", "event", "rest", "shop", "treasure", "boss"]:
		legend.add_child(LegendItem.new(t))
	var lp := UI.panel(Color(Palette.BG_2, 0.9), 12, Palette.LINE)
	lp.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	lp.offset_left = 16
	lp.offset_top = -62
	lp.offset_bottom = -10
	lp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var lsb := Palette.flat(Color(Palette.BG_2, 0.9), 12, Palette.LINE, 1)
	lsb.content_margin_top = 4
	lsb.content_margin_bottom = 4
	lp.add_theme_stylebox_override("panel", lsb)
	lp.add_child(legend)
	add_child(lp)
	var act_label := UI.label("ACT %d — %s" % [int(GameManager.run["act"]), "The Ashen Road" if int(GameManager.run["act"]) == 1 else "The Ember Depths"], 22, Palette.GOLD)
	act_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	act_label.position = Vector2(-360, TopBar.HEIGHT + 12)
	act_label.size = Vector2(340, 30)
	act_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(act_label)


class LegendItem extends HBoxContainer:
	func _init(t: String) -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_theme_constant_override("separation", 6)
		var ic := Dot.new(t)
		add_child(ic)
		add_child(UI.label(t.capitalize(), 15, Palette.TEXT_DIM))

	class Dot extends Control:
		var t: String
		func _init(kind: String) -> void:
			t = kind
			custom_minimum_size = Vector2(26, 26)
			mouse_filter = Control.MOUSE_FILTER_IGNORE
		func _draw() -> void:
			IconDraw.icon(self, t, size / 2.0, 10, Palette.NODE_COLORS[t])


class MapView extends Control:
	var scroll_x := 0.0
	var _drag_from := Vector2.ZERO
	var _scroll_from := 0.0
	var _pressing := false
	var _dragged := false
	var _t := 0.0
	var _velocity := 0.0
	var read_only := false

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		clip_contents = true

	func _ready() -> void:
		# Centre the view on the current progress.
		await get_tree().process_frame
		var run := GameManager.run
		var cur := int(run["current_node"])
		var f := 0
		if cur >= 0:
			f = int(run["map"]["nodes"][cur]["floor"])
		scroll_x = _clamp_scroll(f * MapScreenConst.FS + MapScreenConst.MX - size.x * 0.3)

	func content_width() -> float:
		var floors := int(GameManager.run["map"]["floors"])
		return MapScreenConst.MX * 2.0 + (floors - 1) * MapScreenConst.FS

	func _clamp_scroll(v: float) -> float:
		return clampf(v, 0.0, maxf(0.0, content_width() - size.x))

	func node_pos(n: Dictionary) -> Vector2:
		var lanes := 7.0
		var usable_h := size.y - 120.0
		var lane_h := usable_h / lanes
		var x := MapScreenConst.MX + float(n["floor"]) * MapScreenConst.FS + float(n.get("jx", 0.0)) * MapScreenConst.FS * 0.5
		var y := 40.0 + (float(n["lane"]) + 0.5) * lane_h + float(n.get("jy", 0.0)) * lane_h
		if n["type"] == "boss":
			x += 40.0
			y = 40.0 + usable_h / 2.0
		return Vector2(x - scroll_x, y)

	func _process(delta: float) -> void:
		_t += delta
		if not _pressing and absf(_velocity) > 1.0:
			scroll_x = _clamp_scroll(scroll_x + _velocity * delta)
			_velocity = lerpf(_velocity, 0.0, 6.0 * delta)
		queue_redraw()

	func _draw() -> void:
		var run := GameManager.run
		var nodes: Array = run["map"]["nodes"]
		var avail: Array = MapManager.available_nodes(run)
		var cur := int(run["current_node"])
		var act_col := Palette.SKILL if int(run["act"]) == 1 else Color("ff8a4f")
		Scenery.draw(self, size, act_col, _t, 0.94, false, scroll_x)
		# Parchment-like floor bands
		for f in int(run["map"]["floors"]):
			var x := MapScreenConst.MX + f * MapScreenConst.FS - scroll_x
			if x < -100 or x > size.x + 100:
				continue
			draw_line(Vector2(x, 20), Vector2(x, size.y - 70), Color(Palette.LINE, 0.18), 1.0)
		# Edges
		for n in nodes:
			var a := node_pos(n)
			for nid in n["next"]:
				var m: Dictionary = nodes[nid]
				var b := node_pos(m)
				if maxf(a.x, b.x) < -50 or minf(a.x, b.x) > size.x + 50:
					continue
				var taken: bool = n["visited"] and m["visited"]
				var col := Palette.GOLD if taken else Color(Palette.TEXT_DIM, 0.35)
				if n["id"] == cur and avail.has(nid):
					col = Color(Palette.GOLD, 0.75)
				if taken:
					draw_line(a, b, Color(Palette.GOLD, 0.18), 9.0, true)
				_dashed(a, b, col, 3.0 if taken else 2.0)
		# Nodes
		for n in nodes:
			var p := node_pos(n)
			if p.x < -60 or p.x > size.x + 60:
				continue
			var t: String = n["type"]
			var col: Color = Palette.NODE_COLORS[t]
			var r := MapScreenConst.R * (1.9 if t == "boss" else 1.0)
			var is_avail := avail.has(n["id"])
			if is_avail:
				var pulse := 0.5 + 0.5 * sin(_t * 4.0)
				draw_circle(p, r + 8 + pulse * 6, Color(col, 0.18 + pulse * 0.12))
			var fill := Palette.PANEL
			if n["visited"]:
				fill = col.darkened(0.55)
			draw_circle(p + Vector2(3, 5), r + 2, Color(0, 0, 0, 0.45))
			draw_circle(p, r + 2, IconDraw.OUTLINE)
			draw_circle(p, r, fill)
			draw_circle(p + Vector2(-r * 0.15, -r * 0.2), r * 0.75, fill.lightened(0.07))
			var ring := col if (is_avail or n["visited"]) else Color(col, 0.45)
			draw_arc(p, r, 0, TAU, 40, ring, 3.0, true)
			if n["id"] == cur:
				draw_arc(p, r + 6, 0, TAU, 40, Palette.TEXT, 2.0, true)
			var icol := col if (is_avail or n["visited"] or t == "boss") else Color(col, 0.55)
			IconDraw.icon(self, t, p, r * 0.6, icol)
		# Fade edges to hint at scrolling.
		var w := 40.0
		for i in 8:
			var a2 := 0.5 * (1.0 - i / 8.0)
			draw_rect(Rect2(i * w / 8.0, 0, w / 8.0, size.y), Color(Palette.BG, a2))
			draw_rect(Rect2(size.x - (i + 1) * w / 8.0, 0, w / 8.0, size.y), Color(Palette.BG, a2))

	func _dashed(a: Vector2, b: Vector2, col: Color, w: float) -> void:
		var d := a.distance_to(b)
		var dir := (b - a) / maxf(d, 0.001)
		var start := MapScreenConst.R
		var end := d - MapScreenConst.R
		var s := start
		while s < end:
			var e := minf(s + 10.0, end)
			draw_line(a + dir * s, a + dir * e, col, w, true)
			s += 18.0

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN or event.button_index == MOUSE_BUTTON_WHEEL_RIGHT:
				scroll_x = _clamp_scroll(scroll_x + 60)
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_LEFT:
				scroll_x = _clamp_scroll(scroll_x - 60)
			elif event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					_pressing = true
					_dragged = false
					_velocity = 0.0
					_drag_from = event.position
					_scroll_from = scroll_x
				else:
					_pressing = false
					if not _dragged:
						_tap(event.position)
		elif event is InputEventMouseMotion and _pressing:
			if event.position.distance_to(_drag_from) > 12.0:
				_dragged = true
			if _dragged:
				scroll_x = _clamp_scroll(_scroll_from - (event.position.x - _drag_from.x))
				_velocity = -event.relative.x * 30.0

	func _tap(pos: Vector2) -> void:
		if read_only:
			return
		var run := GameManager.run
		var avail: Array = MapManager.available_nodes(run)
		for nid in avail:
			var n: Dictionary = run["map"]["nodes"][nid]
			var r := MapScreenConst.R * (1.9 if n["type"] == "boss" else 1.0)
			if node_pos(n).distance_to(pos) <= r + 18.0:
				GameManager.enter_node(int(nid))
				return
