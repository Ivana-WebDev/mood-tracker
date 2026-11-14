class_name PotionMenu
extends Overlay
## Drink / discard a potion. In combat, drinking is routed through the CombatScreen (targeting).

var index: int = 0


func _init(slot: int = 0) -> void:
	super._init()
	index = slot


func _ready() -> void:
	super._ready()
	var pots: Array = GameManager.potions()
	if index >= pots.size():
		close()
		return
	var p := PotionDatabase.get_potion(pots[index])
	var col := Color(p["color"])
	var panel := UI.panel(Palette.PANEL, 18, col)
	panel.custom_minimum_size = Vector2(420, 0)
	var v := UI.vbox(12)
	var icon := PotionIcon.new(index, pots[index], 88)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(UI.center(icon))
	v.get_child(0).custom_minimum_size = Vector2(0, 96)
	v.add_child(UI.label(p["name"], 26, col.lightened(0.3), HORIZONTAL_ALIGNMENT_CENTER))
	v.add_child(UI.label(p["rarity"].capitalize() + " potion", 15, Palette.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER))
	var d := UI.wrap_label(p["desc"], 19, Palette.TEXT)
	d.custom_minimum_size = Vector2(360, 0)
	v.add_child(d)
	var screen = UI.main(self).current if UI.main(self) != null else null
	var in_combat: bool = screen != null and screen.has_method("try_use_potion")
	var can_drink := false
	var why := ""
	if in_combat:
		can_drink = screen.cm.phase == "player"
		why = "Wait for your turn." if not can_drink else ""
	else:
		can_drink = p.get("anywhere", false)
		why = "Can only be used in combat." if not can_drink else ""
	var row := UI.hbox(14)
	var drink := UI.accent_button("Drink", _drink, Palette.GOOD, Vector2(150, 58))
	drink.disabled = not can_drink
	row.add_child(drink)
	row.add_child(UI.accent_button("Discard", _discard, Palette.BAD, Vector2(150, 58)))
	v.add_child(row)
	if why != "":
		v.add_child(UI.label(why, 15, Palette.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER))
	v.add_child(UI.button("Cancel", close, Vector2(320, 50), 18))
	panel.add_child(v)
	content.add_child(panel)


func _drink() -> void:
	var screen = UI.main(self).current
	close()
	if screen != null and screen.has_method("try_use_potion"):
		screen.try_use_potion(index)
	elif GameManager.use_potion_outside_combat(index):
		UI.toast(self, "Refreshing!", Palette.GOOD)


func _discard() -> void:
	GameManager.discard_potion(index)
	close()
