class_name CharacterDatabase
## mechanic: "gadgets" | "dice" | "flow" — enables the matching combat system + HUD.

const CHARACTERS := {
	"clockwright": {
		"name": "The Clockwright", "title": "Tinker of the Brass Lantern",
		"desc": "Deploys Gadgets that keep fighting on their own: turrets, barrier nodes, tesla coils. Overclock them to fire early.",
		"mechanic": "gadgets", "mechanic_name": "Gadgets",
		"hp": 76, "gold": 99, "color": "e0a74a", "shape": "clockwright", "relic": "mainspring",
		"deck": ["c_wrench", "c_wrench", "c_wrench", "c_wrench", "c_plating", "c_plating", "c_plating", "c_plating", "c_tick_turret", "c_overclock"],
	},
	"fatebinder": {
		"name": "The Fatebinder", "title": "Reader of the Lantern's Dice",
		"desc": "Rolls three Fate Dice every turn. Cards spend, reroll and reshape them. Stack the odds, then cash it all in.",
		"mechanic": "dice", "mechanic_name": "Fate Dice",
		"hp": 72, "gold": 99, "color": "b18cff", "shape": "fatebinder", "relic": "weighted_die",
		"deck": ["f_card_edge", "f_card_edge", "f_card_edge", "f_card_edge", "f_veil", "f_veil", "f_veil", "f_veil", "f_fortune_blade", "f_second_roll"],
	},
	"duskdancer": {
		"name": "The Duskdancer", "title": "Ribbon of the Twilight Court",
		"desc": "Builds Flow by alternating Attacks and Skills. Every Flow sharpens each card, but repeating a type breaks the dance.",
		"mechanic": "flow", "mechanic_name": "Flow",
		"hp": 70, "gold": 99, "color": "3fd6b4", "shape": "duskdancer", "relic": "silver_bell",
		"deck": ["d_lash", "d_lash", "d_lash", "d_lash", "d_pirouette", "d_pirouette", "d_pirouette", "d_pirouette", "d_crescendo", "d_light_step"],
	},
}

const ORDER := ["clockwright", "fatebinder", "duskdancer"]

static func get_character(id: String) -> Dictionary:
	return CHARACTERS.get(id, CHARACTERS["clockwright"])

static func mechanic(id: String) -> String:
	return get_character(id).get("mechanic", "")
