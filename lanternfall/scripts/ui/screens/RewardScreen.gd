extends Screen
## Post-combat rewards: gold, card draft, relic, boss relic.

var _list: VBoxContainer


func _ready() -> void:
	add_top_bar()
	var p := UI.panel()
	p.custom_minimum_size = Vector2(560, 0)
	var v := UI.vbox(14)
	p.add_child(v)
	v.add_child(UI.label("Rewards", 36, Palette.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	_list = UI.vbox(10)
	v.add_child(_list)
	v.add_child(UI.accent_button("Continue", _proceed, Palette.GOOD, Vector2(500, 64)))
	var c := UI.center(p)
	c.offset_top = TopBar.HEIGHT
	add_child(c)
	move_child(c, 0)
	_build()


func _draw() -> void:
	draw_backdrop(Palette.GOLD)


func _p() -> Dictionary:
	return GameManager.run["pending"]


func _build() -> void:
	for ch in _list.get_children():
		ch.queue_free()
	var p := _p()
	if not p.get("gold_taken", false) and int(p.get("gold", 0)) > 0:
		_list.add_child(_row("Take %d Gold" % int(p["gold"]), Palette.GOLD, _take_gold))
	if not p.get("card_taken", false) and not p.get("cards", []).is_empty():
		_list.add_child(_row("Add a card to your deck", Palette.SKILL, _pick_card))
	if not p.get("relic_taken", false) and p.get("relic", "") != "":
		var r: Dictionary = RelicDatabase.get_relic(p["relic"])
		_list.add_child(_row("Relic: %s" % r["name"], Color(r["color"]), _take_relic))
	if not p.get("relic_taken", false) and not p.get("boss_relics", []).is_empty():
		_list.add_child(_row("Choose a Boss Relic", Palette.RARITY["boss"], _pick_boss_relic))
	if _list.get_child_count() == 0:
		_list.add_child(UI.label("All rewards claimed.", 18, Palette.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER))


func _row(text: String, color: Color, cb: Callable) -> Button:
	return UI.accent_button(text, cb, color, Vector2(500, 60))


func _take_gold() -> void:
	var p := _p()
	GameManager.add_gold(int(p["gold"]))
	p["gold_taken"] = true
	SaveManager.save_run()
	_build()


func _take_relic() -> void:
	var p := _p()
	RelicManager.add_relic(p["relic"])
	p["relic_taken"] = true
	SaveManager.save_run()
	UI.toast(self, "Obtained %s" % RelicDatabase.get_relic(p["relic"])["name"], Palette.GOLD)
	_build()


func _pick_card() -> void:
	var ov := CardChoice.new(_p()["cards"])
	ov.chosen.connect(func(card: Dictionary):
		if card.is_empty():
			return
		GameManager.add_card(card["id"], card.get("upgraded", false))
		_p()["card_taken"] = true
		SaveManager.save_run()
		UI.toast(self, "Added %s" % CardDatabase.resolve(card["id"], card.get("upgraded", false))["name"], Palette.GOOD)
		_build())
	Overlay.open(self, ov)


func _pick_boss_relic() -> void:
	var ov := RelicChoice.new(_p()["boss_relics"])
	ov.chosen.connect(func(id: String):
		if id == "":
			return
		RelicManager.add_relic(id)
		_p()["relic_taken"] = true
		SaveManager.save_run()
		_build())
	Overlay.open(self, ov)


func _proceed() -> void:
	GameManager.finish_reward()
