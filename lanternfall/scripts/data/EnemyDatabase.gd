class_name EnemyDatabase
## Enemy definitions + encounter tables.
## Move effects use the same vocabulary as cards. target: "player" (default for damage/debuffs) or "self".
## pattern: "cycle" walks moves in order; "random" picks by weight without repeating the same move 3x.

const ENEMIES := {
	# ---------------------------------------------------------------- ACT 1
	"gloom_slime": {"name": "Gloom Slime", "hp": [26, 31], "shape": "blob", "color": "5fd38a", "size": 1.0,
		"pattern": "random", "moves": [
			{"name": "Spit", "weight": 3, "effects": [{"type": "damage", "value": 7}]},
			{"name": "Harden", "weight": 2, "effects": [{"type": "block", "value": 6, "target": "self"}, {"type": "damage", "value": 3}]},
			{"name": "Ooze", "weight": 2, "effects": [{"type": "apply", "status": "weak", "value": 1}]},
		]},
	"cave_bat": {"name": "Cave Bat", "hp": [13, 17], "shape": "wisp", "color": "a08cff", "size": 0.75,
		"pattern": "random", "moves": [
			{"name": "Bite", "weight": 3, "effects": [{"type": "damage", "value": 5}]},
			{"name": "Screech", "weight": 1, "effects": [{"type": "apply", "status": "weak", "value": 1}]},
		]},
	"bandit": {"name": "Road Bandit", "hp": [40, 44], "shape": "knight", "color": "d9a066", "size": 1.0,
		"pattern": "cycle", "moves": [
			{"name": "Cheap Shot", "effects": [{"type": "damage", "value": 6}, {"type": "apply", "status": "vulnerable", "value": 1}]},
			{"name": "Slash", "effects": [{"type": "damage", "value": 10}]},
			{"name": "Guard", "effects": [{"type": "block", "value": 8, "target": "self"}, {"type": "damage", "value": 4}]},
		]},
	"fungal_brute": {"name": "Fungal Brute", "hp": [46, 52], "shape": "golem", "color": "c47a5a", "size": 1.1,
		"pattern": "cycle", "moves": [
			{"name": "Spore Cloud", "effects": [{"type": "apply", "status": "strength", "value": 2, "target": "self"}]},
			{"name": "Smash", "effects": [{"type": "damage", "value": 11}]},
			{"name": "Smash", "effects": [{"type": "damage", "value": 11}]},
		]},
	"thorn_sprout": {"name": "Thorn Sprout", "hp": [22, 26], "shape": "spike", "color": "8fd14f", "size": 0.85,
		"start_status": {"thorns": 2}, "pattern": "random", "moves": [
			{"name": "Lash", "weight": 3, "effects": [{"type": "damage", "value": 6}]},
			{"name": "Root", "weight": 1, "effects": [{"type": "block", "value": 7, "target": "self"}]},
		]},
	"iron_sentinel": {"name": "Iron Sentinel", "hp": [78, 84], "shape": "golem", "color": "8fa3c7", "size": 1.35, "elite": true,
		"pattern": "cycle", "moves": [
			{"name": "Fortify", "effects": [{"type": "block", "value": 10, "target": "self"}, {"type": "apply", "status": "strength", "value": 2, "target": "self"}]},
			{"name": "Hammer", "effects": [{"type": "damage", "value": 12}]},
			{"name": "Twin Strike", "effects": [{"type": "damage", "value": 5, "times": 2}]},
		]},
	"hex_witch": {"name": "Hex Witch", "hp": [66, 72], "shape": "eye", "color": "c38bff", "size": 1.2, "elite": true,
		"pattern": "cycle", "moves": [
			{"name": "Hex", "effects": [{"type": "apply", "status": "vulnerable", "value": 1}, {"type": "apply", "status": "weak", "value": 2}]},
			{"name": "Curse Bolt", "effects": [{"type": "damage", "value": 11}]},
			{"name": "Drain", "effects": [{"type": "damage", "value": 8}, {"type": "heal", "value": 8, "target": "self"}]},
		]},
	"hollow_king": {"name": "The Hollow King", "hp": [160, 160], "shape": "crown", "color": "f2b84b", "size": 1.45, "boss": true,
		"pattern": "cycle", "moves": [
			{"name": "Royal Decree", "effects": [{"type": "apply", "status": "strength", "value": 2, "target": "self"}, {"type": "block", "value": 8, "target": "self"}]},
			{"name": "Cleave", "effects": [{"type": "damage", "value": 12}]},
			{"name": "Scepter Storm", "effects": [{"type": "damage", "value": 4, "times": 3}]},
			{"name": "Humble", "effects": [{"type": "apply", "status": "weak", "value": 2}, {"type": "apply", "status": "vulnerable", "value": 1}]},
			{"name": "Crush", "effects": [{"type": "damage", "value": 18}]},
		]},
	"lantern_moth": {"name": "Lantern Moth", "hp": [18, 22], "shape": "moth", "color": "e8b45a", "size": 0.8,
		"pattern": "random", "moves": [
			{"name": "Dust", "weight": 2, "effects": [{"type": "damage", "value": 3}, {"type": "apply", "status": "weak", "value": 1}]},
			{"name": "Dive", "weight": 3, "effects": [{"type": "damage", "value": 7}]},
			{"name": "Flutter", "weight": 1, "effects": [{"type": "block", "value": 5, "target": "self"}]},
		]},
	"shellback": {"name": "Shellback Crab", "hp": [36, 40], "shape": "crab", "color": "e07a5f", "size": 1.0,
		"pattern": "cycle", "moves": [
			{"name": "Shell Up", "effects": [{"type": "block", "value": 9, "target": "self"}, {"type": "damage", "value": 3}]},
			{"name": "Pinch", "effects": [{"type": "damage", "value": 5, "times": 2}]},
			{"name": "Crush", "effects": [{"type": "damage", "value": 10}]},
		]},
	"spore_cap": {"name": "Spore Cap", "hp": [18, 22], "shape": "mushroom", "color": "c05bd0", "size": 0.8,
		"pattern": "random", "moves": [
			{"name": "Headbutt", "weight": 3, "effects": [{"type": "damage", "value": 6}]},
			{"name": "Spores", "weight": 2, "effects": [{"type": "apply", "status": "weak", "value": 1}, {"type": "damage", "value": 2}]},
			{"name": "Choking Cloud", "weight": 1, "effects": [{"type": "add_card", "card": "x_doubt", "count": 1}]},
		]},
	"bramble_matron": {"name": "Bramble Matron", "hp": [76, 82], "shape": "treant", "color": "5fa35a", "size": 1.35, "elite": true,
		"start_status": {"thorns": 2}, "pattern": "cycle", "moves": [
			{"name": "Entangle", "effects": [{"type": "apply", "status": "weak", "value": 2}, {"type": "block", "value": 10, "target": "self"}]},
			{"name": "Thorn Whip", "effects": [{"type": "damage", "value": 6, "times": 2}]},
			{"name": "Bloom", "effects": [{"type": "apply", "status": "strength", "value": 2, "target": "self"}, {"type": "apply", "status": "regen", "value": 4, "target": "self"}]},
			{"name": "Bough Crush", "effects": [{"type": "damage", "value": 14}]},
		]},
	"tolling_bell": {"name": "The Tolling Bell", "hp": [165, 165], "shape": "bell", "color": "c99a4a", "size": 1.45, "boss": true,
		"pattern": "cycle", "moves": [
			{"name": "Resonate", "effects": [{"type": "apply", "status": "strength", "value": 2, "target": "self"}, {"type": "block", "value": 10, "target": "self"}]},
			{"name": "Toll", "effects": [{"type": "damage", "value": 10}, {"type": "add_card", "card": "x_doubt", "count": 1}]},
			{"name": "Peal", "effects": [{"type": "damage", "value": 4, "times": 3}]},
			{"name": "Echo", "effects": [{"type": "damage", "value": 6}, {"type": "apply", "status": "weak", "value": 1}]},
			{"name": "Death Knell", "effects": [{"type": "damage", "value": 16}]},
		]},
	# ---------------------------------------------------------------- ACT 2
	"rot_priest": {"name": "Rot Priest", "hp": [54, 60], "shape": "eye", "color": "9fbf5a", "size": 1.05,
		"pattern": "cycle", "moves": [
			{"name": "Blight", "effects": [{"type": "add_card", "card": "x_wound", "count": 2}]},
			{"name": "Smite", "effects": [{"type": "damage", "value": 12}]},
			{"name": "Unholy Prayer", "effects": [{"type": "heal", "value": 10, "target": "self"}, {"type": "block", "value": 6, "target": "self"}]},
		]},
	"shade_hound": {"name": "Shade Hound", "hp": [38, 44], "shape": "spike", "color": "6a7bff", "size": 0.95,
		"pattern": "random", "moves": [
			{"name": "Rend", "weight": 3, "effects": [{"type": "damage", "value": 7, "times": 2}]},
			{"name": "Howl", "weight": 1, "effects": [{"type": "apply", "status": "strength", "value": 2, "target": "self"}]},
		]},
	"crystal_golem": {"name": "Crystal Golem", "hp": [68, 74], "shape": "golem", "color": "6fe0e8", "size": 1.2,
		"pattern": "cycle", "moves": [
			{"name": "Crystallize", "effects": [{"type": "block", "value": 16, "target": "self"}]},
			{"name": "Slam", "effects": [{"type": "damage", "value": 17}]},
			{"name": "Shardspray", "effects": [{"type": "damage", "value": 5, "times": 2}, {"type": "apply", "status": "vulnerable", "value": 1}]},
		]},
	"ember_imp": {"name": "Ember Imp", "hp": [24, 28], "shape": "wisp", "color": "ff8a4f", "size": 0.8,
		"pattern": "random", "moves": [
			{"name": "Fireball", "weight": 3, "effects": [{"type": "damage", "value": 7}]},
			{"name": "Ignite", "weight": 2, "effects": [{"type": "apply", "status": "bleed", "value": 3}]},
		]},
	"void_knight": {"name": "Void Knight", "hp": [118, 126], "shape": "knight", "color": "8f7bff", "size": 1.4, "elite": true,
		"pattern": "cycle", "moves": [
			{"name": "Sunder", "effects": [{"type": "damage", "value": 11}, {"type": "apply", "status": "vulnerable", "value": 1}]},
			{"name": "Parry", "effects": [{"type": "block", "value": 16, "target": "self"}, {"type": "damage", "value": 7}]},
			{"name": "Execute", "effects": [{"type": "damage", "value": 24}]},
		]},
	"wraith": {"name": "Wailing Wraith", "hp": [54, 60], "shape": "wisp", "color": "b7c4ff", "size": 1.1, "elite": true,
		"pattern": "random", "moves": [
			{"name": "Wail", "weight": 1, "effects": [{"type": "apply", "status": "weak", "value": 1}, {"type": "apply", "status": "strength", "value": 1, "target": "self"}]},
			{"name": "Claw", "weight": 3, "effects": [{"type": "damage", "value": 9}]},
		]},
	"lantern_wyrm": {"name": "The Lantern Wyrm", "hp": [265, 265], "shape": "dragon", "color": "ff6b3d", "size": 1.5, "boss": true,
		"start_status": {"ritual": 1}, "pattern": "cycle", "moves": [
			{"name": "Kindle", "effects": [{"type": "block", "value": 16, "target": "self"}, {"type": "apply", "status": "bleed", "value": 3}]},
			{"name": "Flame Breath", "effects": [{"type": "damage", "value": 7, "times": 3}]},
			{"name": "Coil", "effects": [{"type": "apply", "status": "strength", "value": 2, "target": "self"}, {"type": "block", "value": 12, "target": "self"}]},
			{"name": "Ember Rain", "effects": [{"type": "add_card", "card": "x_wound", "count": 2}, {"type": "damage", "value": 9}]},
			{"name": "Inferno", "effects": [{"type": "damage", "value": 28}]},
		]},
	"gloomweaver": {"name": "Gloomweaver", "hp": [44, 50], "shape": "spider", "color": "7a5cc7", "size": 1.0,
		"pattern": "random", "moves": [
			{"name": "Web", "weight": 1, "effects": [{"type": "apply", "status": "weak", "value": 2}]},
			{"name": "Bite", "weight": 3, "effects": [{"type": "damage", "value": 6, "times": 2}]},
			{"name": "Venom", "weight": 2, "effects": [{"type": "damage", "value": 4}, {"type": "apply", "status": "bleed", "value": 3}]},
		]},
	"gilded_mimic": {"name": "Gilded Mimic", "hp": [56, 62], "shape": "mimic", "color": "e0a83a", "size": 1.05,
		"pattern": "cycle", "moves": [
			{"name": "Lure", "effects": [{"type": "block", "value": 12, "target": "self"}, {"type": "apply", "status": "strength", "value": 1, "target": "self"}]},
			{"name": "Chomp", "effects": [{"type": "damage", "value": 15}]},
			{"name": "Gnash", "effects": [{"type": "damage", "value": 6, "times": 2}]},
		]},
	"ash_serpent": {"name": "Ash Serpent", "hp": [40, 46], "shape": "serpent", "color": "c94f3c", "size": 0.95,
		"pattern": "cycle", "moves": [
			{"name": "Hiss", "effects": [{"type": "apply", "status": "vulnerable", "value": 1}, {"type": "apply", "status": "strength", "value": 1, "target": "self"}]},
			{"name": "Strike", "effects": [{"type": "damage", "value": 10}]},
			{"name": "Constrict", "effects": [{"type": "damage", "value": 5}, {"type": "apply", "status": "weak", "value": 1}]},
		]},
	"gargoyle": {"name": "Gargoyle", "hp": [50, 56], "shape": "gargoyle", "color": "8f96a8", "size": 1.05,
		"pattern": "cycle", "moves": [
			{"name": "Stone Skin", "effects": [{"type": "block", "value": 14, "target": "self"}]},
			{"name": "Dive", "effects": [{"type": "damage", "value": 13}]},
			{"name": "Shriek", "effects": [{"type": "damage", "value": 5}, {"type": "apply", "status": "weak", "value": 1}]},
		]},
	"mirror_fiend": {"name": "Mirror Fiend", "hp": [100, 108], "shape": "mirror", "color": "8f7bff", "size": 1.3, "elite": true,
		"pattern": "cycle", "moves": [
			{"name": "Mock", "effects": [{"type": "apply", "status": "weak", "value": 2}, {"type": "apply", "status": "vulnerable", "value": 1}]},
			{"name": "Shatter", "effects": [{"type": "damage", "value": 6, "times": 3}]},
			{"name": "Reflect", "effects": [{"type": "block", "value": 18, "target": "self"}, {"type": "apply", "status": "thorns", "value": 3, "target": "self"}]},
			{"name": "Glass Lance", "effects": [{"type": "damage", "value": 20}]},
		]},
	"moonless_weaver": {"name": "The Moonless Weaver", "hp": [240, 240], "shape": "spider_queen", "color": "4a5a8f", "size": 1.5, "boss": true,
		"pattern": "cycle", "moves": [
			{"name": "Cocoon", "effects": [{"type": "block", "value": 18, "target": "self"}, {"type": "apply", "status": "weak", "value": 2}]},
			{"name": "Fang Rain", "effects": [{"type": "damage", "value": 5, "times": 3}]},
			{"name": "Brood", "effects": [{"type": "apply", "status": "strength", "value": 3, "target": "self"}, {"type": "add_card", "card": "x_wound", "count": 2}]},
			{"name": "Venom Bite", "effects": [{"type": "damage", "value": 12}, {"type": "apply", "status": "bleed", "value": 4}]},
			{"name": "Devour", "effects": [{"type": "damage", "value": 24}]},
		]},
	# ---------------------------------------------------------------- EVENT CHAMPIONS (never on the map; only fought by choice)
	"masked_champion": {"name": "The Masked Champion", "hp": [74, 80], "shape": "knight", "color": "f2c96b", "size": 1.3, "elite": true,
		"pattern": "cycle", "moves": [
			{"name": "Salute", "effects": [{"type": "block", "value": 10, "target": "self"}, {"type": "apply", "status": "strength", "value": 2, "target": "self"}]},
			{"name": "Riposte", "effects": [{"type": "damage", "value": 7, "times": 2}]},
			{"name": "Feint", "effects": [{"type": "damage", "value": 5}, {"type": "apply", "status": "vulnerable", "value": 1}]},
			{"name": "Grand Lunge", "effects": [{"type": "damage", "value": 16}]},
		]},
	"ashen_warden": {"name": "The Ashen Warden", "hp": [122, 130], "shape": "golem", "color": "ff7a45", "size": 1.45, "elite": true,
		"pattern": "cycle", "moves": [
			{"name": "Stoke", "effects": [{"type": "block", "value": 14, "target": "self"}, {"type": "apply", "status": "strength", "value": 3, "target": "self"}]},
			{"name": "Ember Fist", "effects": [{"type": "damage", "value": 17}]},
			{"name": "Cinder Storm", "effects": [{"type": "damage", "value": 5, "times": 3}, {"type": "apply", "status": "bleed", "value": 2}]},
		]},
}

const ENCOUNTERS := {
	1: {
		"easy": [["gloom_slime"], ["cave_bat", "cave_bat"], ["thorn_sprout", "cave_bat"], ["spore_cap", "lantern_moth"], ["shellback"]],
		"hard": [["bandit"], ["fungal_brute"], ["gloom_slime", "thorn_sprout"], ["cave_bat", "cave_bat", "cave_bat"], ["bandit", "cave_bat"],
			["shellback", "spore_cap"], ["lantern_moth", "lantern_moth", "spore_cap"], ["fungal_brute", "lantern_moth"]],
		"elite": [["iron_sentinel"], ["hex_witch"], ["bramble_matron"]],
		"boss": [["hollow_king"], ["tolling_bell"]],
	},
	2: {
		"easy": [["shade_hound"], ["ember_imp", "ember_imp"], ["rot_priest"], ["gloomweaver"], ["ash_serpent"]],
		"hard": [["crystal_golem"], ["rot_priest", "ember_imp"], ["shade_hound", "shade_hound"], ["crystal_golem", "ember_imp"], ["ember_imp", "ember_imp", "ember_imp"],
			["gilded_mimic"], ["gargoyle", "ember_imp"], ["gloomweaver", "ash_serpent"], ["gargoyle", "shade_hound"]],
		"elite": [["void_knight"], ["wraith", "wraith"], ["mirror_fiend"]],
		"boss": [["lantern_wyrm"], ["moonless_weaver"]],
	},
}


static func get_enemy(id: String) -> Dictionary:
	return ENEMIES.get(id, {})
