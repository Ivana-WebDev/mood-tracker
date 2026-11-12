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
	_box = UI.vbox(10)
	p.add_child(_box)
	var c := UI.center(p)
	c.offset_top = TopBar.HEIGHT + 4
	add_child(c)
	move_child(c, 0)
	_build()


func _process(d: float) -> void:
	_t += d
	queue_redraw()


func _draw() -> void:
	draw_backdrop(Palette.NODE_COLORS["event"])


func _build() -> void:
	for ch in _box.get_children():
		ch.queue_free()
	var pending: Dictionary = GameManager.run["pending"]
	var ev_id: String = params.get("event", pending.get("event", "shrine"))
	_box.add_child(EventArt.new(ev_id, Vector2(700, 170)))
	_box.add_child(UI.label(_event["title"], 30, Palette.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	if pending.has("result"):
		var r := UI.wrap_label(pending["result"], 20, Palette.TEXT)
		r.custom_minimum_size = Vector2(700, 0)
		_box.add_child(r)
		var gained: Array = pending.get("gained", [])
		if not gained.is_empty():
			var row := UI.hbox(12)
			row.add_child(UI.label("You received:", 17, Palette.TEXT_DIM))
			for g in gained:
				row.add_child(_gain_chip(g))
			_box.add_child(row)
		_box.add_child(UI.accent_button("Continue", GameManager.node_done, Palette.GOOD, Vector2(320, 60)))
		return
	var t := UI.wrap_label(_event["text"], 20, Palette.TEXT)
	t.custom_minimum_size = Vector2(700, 0)
	_box.add_child(t)
	for i in _event["options"].size():
		var o: Dictionary = _event["options"][i]
		var b := UI.button(o["label"], _choose.bind(i), Vector2(700, 52), 18)
		if int(o.get("cost_gold", 0)) > int(GameManager.run["gold"]):
			b.disabled = true
		var tip := _option_tip(o)
		if tip != "":
			UI.hover_tip(b, o["label"], tip)
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


## Hover text describing exactly what an option gives or costs.
func _option_tip(o: Dictionary) -> String:
	var lines: PackedStringArray = []
	for e in o["effects"]:
		match e["type"]:
			"relic":
				lines.append("A random %s relic." % e["value"])
			"add_curse":
				var ct := UI.card_tip(e["value"])
				lines.append("Adds the curse %s to your deck: %s" % [ct[0], ct[1].get_slice("\n", 1)])
			"card_reward":
				lines.append("Choose 1 of 3 %scards." % ("rare " if e.get("value", "") == "rare" else ""))
			"upgrade_card":
				lines.append("Pick a card to upgrade.")
			"remove_card":
				lines.append("Pick a card to remove from your deck.")
			"upgrade_random":
				lines.append("Upgrades %d random cards." % int(e["value"]))
	return "\n".join(lines)


func _gain_chip(g: Dictionary) -> Control:
	match g["kind"]:
		"relic":
			return RelicIcon.new(g["id"], 48)
		"potion":
			return PotionIcon.new(-1, g["id"], 48)
		_:
			var tip := UI.card_tip(g["id"])
			var col := Palette.CURSE.lightened(0.3) if g["kind"] == "curse" else Palette.SKILL
			var b := UI.accent_button(tip[0], func(): UI.tooltip(self, tip[0], tip[1], get_global_mouse_position()), col, Vector2(150, 48))
			UI.hover_tip(b, tip[0], tip[1])
			return b


func _note_gain(kind: String, id: String) -> void:
	var pending: Dictionary = GameManager.run["pending"]
	if not pending.has("gained"):
		pending["gained"] = []
	pending["gained"].append({"kind": kind, "id": id})


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
				_note_gain("relic", r)
				UI.toast(self, "Obtained %s" % RelicDatabase.get_relic(r)["name"], Palette.GOLD)
		"add_curse":
			GameManager.add_card(e["value"])
			_note_gain("curse", e["value"])
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
				_note_gain("card", card["id"])
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
