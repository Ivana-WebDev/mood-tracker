class_name RelicDatabase
## Relic definitions. Behaviour lives in RelicManager (keyed by id).

const RELICS := {
	# Starters
	"iron_oath": {"name": "Iron Oath", "rarity": "starter", "icon": "shield", "color": "e8664f",
		"desc": "Start each combat with 10 Block."},
	"smoke_charm": {"name": "Smoke Charm", "rarity": "starter", "icon": "cloud", "color": "8f7bff",
		"desc": "On your first turn of each combat, draw 2 extra cards."},
	"ember_core": {"name": "Ember Core", "rarity": "starter", "icon": "orb", "color": "4fc3e8",
		"desc": "Start each combat with 3 Charge."},
	# Common
	"whetstone": {"name": "Whetstone", "rarity": "common", "icon": "blade", "color": "b8c0d8",
		"desc": "Start each combat with 1 Strength."},
	"oak_buckler": {"name": "Oak Buckler", "rarity": "common", "icon": "shield", "color": "c47a5a",
		"desc": "Start each combat with 7 Block."},
	"healing_herb": {"name": "Healing Herb", "rarity": "common", "icon": "leaf", "color": "46c37b",
		"desc": "At the end of combat, heal 5 HP."},
	"vital_stone": {"name": "Vital Stone", "rarity": "common", "icon": "heart", "color": "e5484d",
		"desc": "Gain 10 Max HP when picked up."},
	"bronze_spurs": {"name": "Bronze Spurs", "rarity": "common", "icon": "bolt", "color": "d9a066",
		"desc": "Gain 1 extra Energy on the first turn of each combat."},
	"thorn_ring": {"name": "Thorn Ring", "rarity": "common", "icon": "ring", "color": "8fd14f",
		"desc": "Start each combat with 3 Thorns."},
	"coin_pouch": {"name": "Coin Pouch", "rarity": "common", "icon": "coin", "color": "f2b84b",
		"desc": "Gain 30% more Gold from combats."},
	# Uncommon
	"battle_drum": {"name": "Battle Drum", "rarity": "uncommon", "icon": "drum", "color": "ff8a4f",
		"desc": "Every 4th card you play each combat draws a card."},
	"blood_vial": {"name": "Blood Vial", "rarity": "uncommon", "icon": "heart", "color": "ff4f7b",
		"desc": "Whenever an enemy dies, heal 3 HP."},
	"jade_turtle": {"name": "Jade Turtle", "rarity": "uncommon", "icon": "shield", "color": "46c37b",
		"desc": "At the end of your turn, if you have no Block, gain 6 Block."},
	"serpent_fang": {"name": "Serpent Fang", "rarity": "uncommon", "icon": "blade", "color": "c38bff",
		"desc": "At the start of combat, apply 1 Weak and 1 Vulnerable to ALL enemies."},
	"merchant_scale": {"name": "Merchant's Scale", "rarity": "uncommon", "icon": "coin", "color": "7ee0a1",
		"desc": "Shop prices are 25% lower."},
	# Rare
	"phoenix_feather": {"name": "Phoenix Feather", "rarity": "rare", "icon": "feather", "color": "ff6b3d",
		"desc": "Once per run, when you would die, heal to 40% Max HP instead."},
	"dragon_scale": {"name": "Dragon Scale", "rarity": "rare", "icon": "shield", "color": "ff6b9a",
		"desc": "Unblocked attack damage you take is reduced by 1."},
	"war_banner": {"name": "War Banner", "rarity": "rare", "icon": "flag", "color": "e8664f",
		"desc": "At the start of your 3rd turn each combat, gain 2 Strength and 1 Energy."},
	# Boss
	"lantern_heart": {"name": "Lantern Heart", "rarity": "boss", "icon": "orb", "color": "ffcf4a",
		"desc": "Gain 1 extra Energy at the start of each turn."},
	"twin_crown": {"name": "Twin Crown", "rarity": "boss", "icon": "crown", "color": "f2b84b",
		"desc": "Draw 1 extra card each turn."},
	"titan_belt": {"name": "Titan Belt", "rarity": "boss", "icon": "ring", "color": "c47a5a",
		"desc": "Gain 25 Max HP. Start each combat with 2 Strength."},
}

static func get_relic(id: String) -> Dictionary:
	return RELICS.get(id, {"name": id, "desc": "", "rarity": "common", "icon": "orb", "color": "ffffff"})

static func pool(rarity: String) -> Array:
	var out: Array = []
	for id in RELICS:
		if RELICS[id]["rarity"] == rarity:
			out.append(id)
	return out
