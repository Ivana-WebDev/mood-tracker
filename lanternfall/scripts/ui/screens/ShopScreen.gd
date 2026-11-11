extends Screen
## Merchant: buy cards and relics, pay to remove a card.

var _root: VBoxContainer


func _ready() -> void:
	add_top_bar()
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = TopBar.HEIGHT + 6
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.scroll_deadzone = 12
	add_child(scroll)
	move_child(scroll, 0)
	_root = UI.vbox(14)
	_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_root.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll.add_child(_root)
	_build()


func _draw() -> void:
	draw_backdrop(Palette.NODE_COLORS["shop"])


func _stock() -> Dictionary:
	return GameManager.run["pending"]["stock"]


func _build() -> void:
	for ch in _root.get_children():
		ch.queue_free()
	var head := UI.hbox(30)
	head.mouse_filter = Control.MOUSE_FILTER_PASS
	head.add_child(UI.label("The Lantern Merchant", 32, Palette.GOLD))
	head.add_child(UI.label("Gold: %d" % int(GameManager.run["gold"]), 24, Palette.GOLD))
	head.add_child(UI.accent_button("Leave", GameManager.node_done, Palette.GOOD, Vector2(160, 56)))
	_root.add_child(head)
	var cards_row := UI.hbox(16)
	cards_row.mouse_filter = Control.MOUSE_FILTER_PASS
	var stock := _stock()
	for i in stock["cards"].size():
		var item: Dictionary = stock["cards"][i]
		var col := UI.vbox(6)
		col.mouse_filter = Control.MOUSE_FILTER_PASS
		var holder := Control.new()
		holder.custom_minimum_size = CardView.CARD_SIZE
		holder.mouse_filter = Control.MOUSE_FILTER_PASS
		if not item["sold"]:
			var v := CardView.new({"uid": -1, "id": item["id"], "upgraded": item.get("upgraded", false)})
			v.mouse_filter = Control.MOUSE_FILTER_PASS
			v.show_glow = false
			v.playable = int(GameManager.run["gold"]) >= int(item["price"])
			v.tapped.connect(func(_cv): _buy_card(i))
			holder.add_child(v)
		col.add_child(holder)
		var price := UI.label("SOLD" if item["sold"] else "%d g" % int(item["price"]), 20,
			Palette.TEXT_DIM if item["sold"] else (Palette.GOLD if int(GameManager.run["gold"]) >= int(item["price"]) else Palette.BAD), HORIZONTAL_ALIGNMENT_CENTER)
		col.add_child(price)
		cards_row.add_child(col)
	_root.add_child(cards_row)
	var bottom := UI.hbox(24)
	bottom.mouse_filter = Control.MOUSE_FILTER_PASS
	for i in stock["relics"].size():
		var r: Dictionary = stock["relics"][i]
		var rd: Dictionary = RelicDatabase.get_relic(r["id"])
		var p := UI.panel(Palette.PANEL, 14, Color(rd["color"]))
		p.custom_minimum_size = Vector2(260, 0)
		var v2 := UI.vbox(6)
		var top := UI.hbox(8)
		top.add_child(RelicIcon.new(r["id"], 44))
		top.add_child(UI.label(rd["name"], 18, Palette.TEXT))
		v2.add_child(top)
		var d := UI.wrap_label(rd["desc"], 14, Palette.TEXT_DIM, HORIZONTAL_ALIGNMENT_LEFT)
		d.custom_minimum_size = Vector2(220, 0)
		v2.add_child(d)
		if r["sold"]:
			v2.add_child(UI.label("SOLD", 18, Palette.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER))
		else:
			var b := UI.accent_button("Buy %d g" % int(r["price"]), _buy_relic.bind(i), Palette.GOLD, Vector2(200, 48))
			b.disabled = int(GameManager.run["gold"]) < int(r["price"]) or RelicManager.has(r["id"])
			v2.add_child(b)
		p.add_child(v2)
		bottom.add_child(p)
	var rp := UI.panel(Palette.PANEL, 14, Palette.BAD)
	rp.custom_minimum_size = Vector2(240, 0)
	var rv := UI.vbox(8)
	rv.add_child(UI.label("Card Removal", 20, Palette.TEXT, HORIZONTAL_ALIGNMENT_CENTER))
	var rd2 := UI.wrap_label("Remove a card from your deck.", 14, Palette.TEXT_DIM)
	rd2.custom_minimum_size = Vector2(200, 0)
	rv.add_child(rd2)
	var cost := int(round(int(GameManager.run["remove_cost"]) * RelicManager.price_multiplier()))
	if stock["removed"]:
		rv.add_child(UI.label("SOLD OUT", 18, Palette.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER))
	else:
		var rb := UI.accent_button("Remove %d g" % cost, _remove.bind(cost), Palette.BAD, Vector2(200, 48))
		rb.disabled = int(GameManager.run["gold"]) < cost
		rv.add_child(rb)
	rp.add_child(rv)
	bottom.add_child(rp)
	_root.add_child(bottom)


func _buy_card(i: int) -> void:
	var item: Dictionary = _stock()["cards"][i]
	if item["sold"]:
		return
	if int(GameManager.run["gold"]) < int(item["price"]):
		UI.toast(self, "Not enough gold", Palette.BAD)
		return
	GameManager.add_gold(-int(item["price"]))
	GameManager.add_card(item["id"], item.get("upgraded", false))
	item["sold"] = true
	SaveManager.save_run()
	UI.toast(self, "Bought %s" % CardDatabase.CARDS[item["id"]]["name"], Palette.GOOD)
	_build()


func _buy_relic(i: int) -> void:
	var r: Dictionary = _stock()["relics"][i]
	if r["sold"] or int(GameManager.run["gold"]) < int(r["price"]):
		return
	GameManager.add_gold(-int(r["price"]))
	RelicManager.add_relic(r["id"])
	r["sold"] = true
	SaveManager.save_run()
	_build()


func _remove(cost: int) -> void:
	var ov := DeckViewer.new(GameManager.run["deck"], "Choose a card to remove", "remove")
	ov.picked.connect(func(uid: int):
		GameManager.add_gold(-cost)
		GameManager.remove_card(uid)
		GameManager.run["remove_cost"] = int(GameManager.run["remove_cost"]) + 25
		_stock()["removed"] = true
		SaveManager.save_run()
		_build())
	Overlay.open(self, ov)
