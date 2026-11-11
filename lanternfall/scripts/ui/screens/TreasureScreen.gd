extends Screen
## Treasure chest: gold + relic.

var _t := 0.0
var _open := 0.0
var _box: VBoxContainer


func _ready() -> void:
	add_top_bar()
	_box = UI.vbox(14)
	var c := UI.center(_box)
	c.offset_top = TopBar.HEIGHT + 220
	add_child(c)
	move_child(c, 0)
	if GameManager.run["pending"].get("opened", false):
		_open = 1.0
	_build()


func _process(d: float) -> void:
	_t += d
	queue_redraw()


func _draw() -> void:
	draw_backdrop(Palette.NODE_COLORS["treasure"])
	var c := Vector2(size.x / 2.0, 230)
	draw_circle(c, 110 + _open * 30 + sin(_t * 2.0) * 4, Color(Palette.GOLD, 0.06 + _open * 0.1))
	IconDraw.icon(self, "chest", c + Vector2(0, -_open * 10), 80, Palette.NODE_COLORS["treasure"])


func _build() -> void:
	for ch in _box.get_children():
		ch.queue_free()
	var p: Dictionary = GameManager.run["pending"]
	if not p.get("opened", false):
		_box.add_child(UI.label("A sealed chest glimmers.", 22, Palette.TEXT, HORIZONTAL_ALIGNMENT_CENTER))
		_box.add_child(UI.accent_button("Open", _open_chest, Palette.GOLD, Vector2(280, 64)))
		return
	_box.add_child(UI.label("+%d Gold" % int(p["gold"]), 24, Palette.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	if p.get("relic", "") != "":
		var r: Dictionary = RelicDatabase.get_relic(p["relic"])
		var row := UI.hbox(10)
		row.add_child(RelicIcon.new(p["relic"], 48))
		var l := UI.wrap_label("%s — %s" % [r["name"], r["desc"]], 18, Palette.TEXT, HORIZONTAL_ALIGNMENT_LEFT)
		l.custom_minimum_size = Vector2(440, 0)
		row.add_child(l)
		_box.add_child(row)
	_box.add_child(UI.accent_button("Continue", GameManager.node_done, Palette.GOOD, Vector2(280, 64)))


func _open_chest() -> void:
	var p: Dictionary = GameManager.run["pending"]
	p["opened"] = true
	GameManager.add_gold(int(p["gold"]))
	RelicManager.add_relic(p.get("relic", ""))
	SaveManager.save_run()
	create_tween().tween_property(self, "_open", 1.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_build()
