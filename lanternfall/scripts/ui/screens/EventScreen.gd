extends Screen
## Text event with choices.

var _box: VBoxContainer
var _event: Dictionary
var _t := 0.0


func _ready() -> void:
	add_top_bar()
	_event = EventDatabase.EVENTS.get(params.get("event", GameManager.run["pending"].get("event", "")), EventDatabase.EVENTS["shrine"])
	var p := UI.panel()
	p.custom_minimum_size = Vector2(760, 0)
	_box = UI.vbox(14)
	p.add_child(_box)
	var c := UI.center(p)
	c.offset_top = TopBar.HEIGHT + 120
	add_child(c)
	move_child(c, 0)
	_build()


func _process(d: float) -> void:
	_t += d
	queue_redraw()


func _draw() -> void:
	draw_backdrop(Palette.NODE_COLORS["event"])
	var c := Vector2(size.x / 2.0, TopBar.HEIGHT + 80)
	draw_circle(c, 52 + sin(_t * 2.0) * 3.0, Color(Palette.NODE_COLORS["event"], 0.15))
	IconDraw.icon(self, "event", c, 36, Palette.NODE_COLORS["event"])


func _build() -> void:
	for ch in _box.get_children():
		ch.queue_free()
	var pending: Dictionary = GameManager.run["pending"]
	_box.add_child(UI.label(_event["title"], 32, Palette.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	if pending.has("result"):
		var r := UI.wrap_label(pending["result"], 20, Palette.TEXT)
		r.custom_minimum_size = Vector2(700, 0)
		_box.add_child(r)
		_box.add_child(UI.accent_button("Continue", GameManager.node_done, Palette.GOOD, Vector2(320, 60)))
		return
	var t := UI.wrap_label(_event["text"], 20, Palette.TEXT)
	t.custom_minimum_size = Vector2(700, 0)
	_box.add_child(t)
	for i in _event["options"].size():
		var o: Dictionary = _event["options"][i]
		var b := UI.button(o["label"], _choose.bind(i), Vector2(700, 58), 19)
		if int(o.get("cost_gold", 0)) > int(GameManager.run["gold"]):
			b.disabled = true
		_box.add_child(b)


func _choose(i: int) -> void:
	var o: Dictionary = _event["options"][i]
	var pending: Dictionary = GameManager.run["pending"]
	pending["result"] = o.get("result", "")
	SaveManager.save_run()
	for e in o["effects"]:
		await _apply(e)
	SaveManager.save_run()
	_build()


func _apply(e: Dictionary) -> void:
	match e["type"]:
		"gold":
			GameManager.add_gold(int(e["value"]))
		"hp":
			GameManager.change_hp(int(e["value"]))
		"max_hp":
			GameManager.change_max_hp(int(e["value"]))
		"heal_pct":
			GameManager.change_hp(int(ceil(int(GameManager.run["max_hp"]) * int(e["value"]) / 100.0)))
		"relic":
			var r := RelicManager.roll_relic(e["value"])
			if r != "":
				RelicManager.add_relic(r)
				UI.toast(self, "Obtained %s" % RelicDatabase.get_relic(r)["name"], Palette.GOLD)
		"add_curse":
			GameManager.add_card(e["value"])
		"upgrade_random":
			var ups := GameManager.upgradable_cards()
			for n in int(e["value"]):
				if ups.is_empty():
					break
				var idx := GameManager.rng.randi_range(0, ups.size() - 1)
				GameManager.upgrade_card(int(ups[idx]["uid"]))
				ups.remove_at(idx)
		"card_reward":
			var kind: String = e.get("value", "normal")
			var ov := CardChoice.new(GameManager.roll_card_rewards("rare" if kind == "rare" else "monster"))
			Overlay.open(self, ov)
			var card: Dictionary = await ov.chosen
			if not card.is_empty():
				GameManager.add_card(card["id"], card.get("upgraded", false))
		"remove_card":
			var ov2 := DeckViewer.new(GameManager.run["deck"], "Choose a card to remove", "remove")
			ov2.dismissable = false
			Overlay.open(self, ov2)
			ov2.picked.connect(func(uid: int): GameManager.remove_card(uid))
			await ov2.closed
		"upgrade_card":
			var ov3 := DeckViewer.new(GameManager.upgradable_cards(), "Choose a card to upgrade", "upgrade")
			ov3.dismissable = false
			Overlay.open(self, ov3)
			ov3.picked.connect(func(uid: int): GameManager.upgrade_card(uid))
			await ov3.closed
