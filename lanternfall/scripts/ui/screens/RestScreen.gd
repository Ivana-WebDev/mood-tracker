extends Screen
## Campfire: heal or upgrade a card.

var _t := 0.0
var _box: VBoxContainer


func _ready() -> void:
	add_top_bar()
	_box = UI.vbox(18)
	var c := UI.center(_box)
	c.offset_top = TopBar.HEIGHT + 150
	add_child(c)
	move_child(c, 0)
	_build()


func _process(d: float) -> void:
	_t += d
	queue_redraw()


func _draw() -> void:
	draw_backdrop(Palette.GOOD)
	var c := Vector2(size.x / 2.0, 205)
	for i in 4:
		draw_circle(c, 90 - i * 18 + sin(_t * 3.0 + i) * 4.0, Color(Palette.GOLD, 0.05 + i * 0.03))
	IconDraw.icon(self, "fire", c, 60 + sin(_t * 5.0) * 3.0, Color("ff8a4f"))


func _build() -> void:
	for ch in _box.get_children():
		ch.queue_free()
	var done: bool = GameManager.run["pending"].get("done", false)
	_box.add_child(UI.label("Campfire", 38, Palette.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	if done:
		_box.add_child(UI.label("You feel ready to continue.", 20, Palette.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER))
		_box.add_child(UI.accent_button("Continue", GameManager.node_done, Palette.GOOD, Vector2(320, 64)))
		return
	var heal := int(ceil(int(GameManager.run["max_hp"]) * 0.3))
	var row := UI.hbox(30)
	row.add_child(UI.accent_button("Rest\nHeal %d HP" % heal, _rest.bind(heal), Palette.GOOD, Vector2(280, 110)))
	var up := UI.accent_button("Smith\nUpgrade a card", _smith, Palette.GOLD, Vector2(280, 110))
	up.disabled = GameManager.upgradable_cards().is_empty()
	row.add_child(up)
	_box.add_child(row)


func _rest(amount: int) -> void:
	GameManager.change_hp(amount)
	GameManager.run["pending"]["done"] = true
	SaveManager.save_run()
	UI.toast(self, "Healed %d HP" % amount, Palette.GOOD)
	_build()


func _smith() -> void:
	var ov := DeckViewer.new(GameManager.upgradable_cards(), "Choose a card to upgrade", "upgrade")
	ov.picked.connect(func(uid: int):
		GameManager.upgrade_card(uid)
		GameManager.run["pending"]["done"] = true
		SaveManager.save_run()
		_build())
	Overlay.open(self, ov)
