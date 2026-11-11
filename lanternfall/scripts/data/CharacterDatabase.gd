class_name CharacterDatabase

const CHARACTERS := {
	"warden": {
		"name": "The Warden", "title": "Shieldbearer of the Last Lantern",
		"desc": "A stalwart defender. Stacks Block, builds Strength and turns defence into devastating blows.",
		"hp": 80, "gold": 99, "color": "e8664f", "shape": "warden", "relic": "iron_oath",
		"deck": ["w_hack", "w_hack", "w_hack", "w_hack", "w_hack", "w_guard", "w_guard", "w_guard", "w_guard", "w_shatter_blow"],
	},
	"shade": {
		"name": "The Shade", "title": "Knife in the Lantern-light",
		"desc": "A nimble assassin. Inflicts stacking Bleed, conjures Knives and chains cheap cards together.",
		"hp": 70, "gold": 99, "color": "8f7bff", "shape": "shade", "relic": "smoke_charm",
		"deck": ["s_slash", "s_slash", "s_slash", "s_slash", "s_evade", "s_evade", "s_evade", "s_evade", "s_lacerate", "s_knife_fan"],
	},
	"arcanist": {
		"name": "The Arcanist", "title": "Keeper of the Ember Flame",
		"desc": "A storm-caller. Stores Charge with every spell, then unleashes it in a single cataclysmic burst.",
		"hp": 72, "gold": 99, "color": "4fc3e8", "shape": "arcanist", "relic": "ember_core",
		"deck": ["a_bolt", "a_bolt", "a_bolt", "a_bolt", "a_ward", "a_ward", "a_ward", "a_ward", "a_channel", "a_discharge"],
	},
}

const ORDER := ["warden", "shade", "arcanist"]

static func get_character(id: String) -> Dictionary:
	return CHARACTERS.get(id, {})
