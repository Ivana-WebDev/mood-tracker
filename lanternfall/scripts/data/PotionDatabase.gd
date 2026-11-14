class_name PotionDatabase
## Single-use consumables. Effects use the same vocabulary as cards and resolve through CombatManager.
## target: "enemy" (needs a target), "none". anywhere: usable outside combat too.
## owner: "any" or a hero id (hero potions only drop for that hero).

const MAX_SLOTS := 3

const POTIONS := {
	"healing_draught": {"name": "Healing Draught", "rarity": "common", "owner": "any", "color": "e5484d", "target": "none", "anywhere": true,
		"desc": "Heal 15 HP.", "effects": [{"type": "heal", "value": 15}]},
	"fire_flask": {"name": "Fire Flask", "rarity": "common", "owner": "any", "color": "ff8a4f", "target": "enemy",
		"desc": "Deal 20 damage to an enemy.", "effects": [{"type": "potion_damage", "value": 20}]},
	"frost_bomb": {"name": "Frost Bomb", "rarity": "common", "owner": "any", "color": "7ee8ff", "target": "none",
		"desc": "Deal 10 damage to ALL enemies.", "effects": [{"type": "potion_damage", "value": 10, "target": "all"}]},
	"iron_tonic": {"name": "Iron Tonic", "rarity": "common", "owner": "any", "color": "5ab0ff", "target": "none",
		"desc": "Gain 12 Block.", "effects": [{"type": "block", "value": 12}]},
	"swift_elixir": {"name": "Swift Elixir", "rarity": "common", "owner": "any", "color": "7ee0a1", "target": "none",
		"desc": "Draw 3 cards.", "effects": [{"type": "draw", "value": 3}]},
	"hex_vial": {"name": "Hex Vial", "rarity": "common", "owner": "any", "color": "c38bff", "target": "enemy",
		"desc": "Apply 3 Vulnerable to an enemy.", "effects": [{"type": "apply", "status": "vulnerable", "value": 3}]},
	"fog_bottle": {"name": "Fog in a Bottle", "rarity": "uncommon", "owner": "any", "color": "b8c0d8", "target": "none",
		"desc": "Apply 2 Weak to ALL enemies.", "effects": [{"type": "apply", "status": "weak", "value": 2, "target": "all"}]},
	"ember_brew": {"name": "Ember Brew", "rarity": "uncommon", "owner": "any", "color": "ffcf4a", "target": "none",
		"desc": "Gain 2 Energy.", "effects": [{"type": "energy", "value": 2}]},
	"giants_ale": {"name": "Giant's Ale", "rarity": "uncommon", "owner": "any", "color": "d9a066", "target": "none",
		"desc": "Gain 2 Strength.", "effects": [{"type": "apply", "status": "strength", "value": 2, "target": "self"}]},
	"phoenix_tears": {"name": "Phoenix Tears", "rarity": "rare", "owner": "any", "color": "ff6b9a", "target": "none", "anywhere": true,
		"desc": "Heal 30 HP.", "effects": [{"type": "heal", "value": 30}]},
	# Hero potions
	"overdrive_oil": {"name": "Overdrive Oil", "rarity": "uncommon", "owner": "clockwright", "color": "e0a74a", "target": "none",
		"desc": "Fire all Gadgets twice.", "effects": [{"type": "overclock", "value": 2}]},
	"liquid_luck": {"name": "Liquid Luck", "rarity": "uncommon", "owner": "fatebinder", "color": "b18cff", "target": "none",
		"desc": "Set all dice to 6.", "effects": [{"type": "set_all", "value": 6}]},
	"rhythm_tonic": {"name": "Rhythm Tonic", "rarity": "uncommon", "owner": "duskdancer", "color": "3fd6b4", "target": "none",
		"desc": "Gain 4 Flow.", "effects": [{"type": "apply", "status": "flow", "value": 4, "target": "self"}]},
}

static func get_potion(id: String) -> Dictionary:
	return POTIONS.get(id, {"name": id, "desc": "", "color": "ffffff", "target": "none", "effects": [], "rarity": "common"})

static func pool(character: String, rarity: String) -> Array:
	var out: Array = []
	for id in POTIONS:
		var p: Dictionary = POTIONS[id]
		if p["rarity"] == rarity and (p["owner"] == "any" or p["owner"] == character):
			out.append(id)
	return out

static func price(rarity: String) -> int:
	return {"common": 50, "uncommon": 72, "rare": 100}.get(rarity, 60)
