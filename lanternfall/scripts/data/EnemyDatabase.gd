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
	"iron_sentinel": {"name": "Iron Sentinel", "hp": [86, 92], "shape": "golem", "color": "8fa3c7", "size": 1.35, "elite": true,
		"pattern": "cycle", "moves": [
			{"name": "Fortify", "effects": [{"type": "block", "value": 12, "target": "self"}, {"type": "apply", "status": "strength", "value": 2, "target": "self"}]},
			{"name": "Hammer", "effects": [{"type": "damage", "value": 14}]},
			{"name": "Twin Strike", "effects": [{"type": "damage", "value": 6, "times": 2}]},
		]},
	"hex_witch": {"name": "Hex Witch", "hp": [72, 78], "shape": "eye", "color": "c38bff", "size": 1.2, "elite": true,
		"pattern": "cycle", "moves": [
			{"name": "Hex", "effects": [{"type": "apply", "status": "vulnerable", "value": 2}, {"type": "apply", "status": "weak", "value": 2}]},
			{"name": "Curse Bolt", "effects": [{"type": "damage", "value": 12}]},
			{"name": "Drain", "effects": [{"type": "damage", "value": 8}, {"type": "heal", "value": 8, "target": "self"}]},
		]},
	"hollow_king": {"name": "The Hollow King", "hp": [180, 180], "shape": "crown", "color": "f2b84b", "size": 1.45, "boss": true,
		"pattern": "cycle", "moves": [
			{"name": "Royal Decree", "effects": [{"type": "apply", "status": "strength", "value": 2, "target": "self"}, {"type": "block", "value": 10, "target": "self"}]},
			{"name": "Cleave", "effects": [{"type": "damage", "value": 14}]},
			{"name": "Scepter Storm", "effects": [{"type": "damage", "value": 5, "times": 3}]},
			{"name": "Humble", "effects": [{"type": "apply", "status": "weak", "value": 2}, {"type": "apply", "status": "vulnerable", "value": 2}]},
			{"name": "Crush", "effects": [{"type": "damage", "value": 21}]},
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
	"void_knight": {"name": "Void Knight", "hp": [135, 145], "shape": "knight", "color": "8f7bff", "size": 1.4, "elite": true,
		"pattern": "cycle", "moves": [
			{"name": "Sunder", "effects": [{"type": "damage", "value": 12}, {"type": "apply", "status": "vulnerable", "value": 2}]},
			{"name": "Parry", "effects": [{"type": "block", "value": 20, "target": "self"}, {"type": "damage", "value": 8}]},
			{"name": "Execute", "effects": [{"type": "damage", "value": 28}]},
		]},
	"wraith": {"name": "Wailing Wraith", "hp": [62, 68], "shape": "wisp", "color": "b7c4ff", "size": 1.1, "elite": true,
		"pattern": "random", "moves": [
			{"name": "Wail", "weight": 1, "effects": [{"type": "apply", "status": "weak", "value": 2}, {"type": "apply", "status": "strength", "value": 1, "target": "self"}]},
			{"name": "Claw", "weight": 3, "effects": [{"type": "damage", "value": 11}]},
		]},
	"lantern_wyrm": {"name": "The Lantern Wyrm", "hp": [300, 300], "shape": "dragon", "color": "ff6b3d", "size": 1.5, "boss": true,
		"start_status": {"ritual": 1}, "pattern": "cycle", "moves": [
			{"name": "Kindle", "effects": [{"type": "block", "value": 20, "target": "self"}, {"type": "apply", "status": "bleed", "value": 4}]},
			{"name": "Flame Breath", "effects": [{"type": "damage", "value": 8, "times": 3}]},
			{"name": "Coil", "effects": [{"type": "apply", "status": "strength", "value": 3, "target": "self"}, {"type": "block", "value": 15, "target": "self"}]},
			{"name": "Ember Rain", "effects": [{"type": "add_card", "card": "x_wound", "count": 2}, {"type": "damage", "value": 10}]},
			{"name": "Inferno", "effects": [{"type": "damage", "value": 32}]},
		]},
}

const ENCOUNTERS := {
	1: {
		"easy": [["gloom_slime"], ["cave_bat", "cave_bat"], ["thorn_sprout", "cave_bat"]],
		"hard": [["bandit"], ["fungal_brute"], ["gloom_slime", "thorn_sprout"], ["cave_bat", "cave_bat", "cave_bat"], ["bandit", "cave_bat"]],
		"elite": [["iron_sentinel"], ["hex_witch"]],
		"boss": [["hollow_king"]],
	},
	2: {
		"easy": [["shade_hound"], ["ember_imp", "ember_imp"], ["rot_priest"]],
		"hard": [["crystal_golem"], ["rot_priest", "ember_imp"], ["shade_hound", "shade_hound"], ["crystal_golem", "ember_imp"], ["ember_imp", "ember_imp", "ember_imp"]],
		"elite": [["void_knight"], ["wraith", "wraith"]],
		"boss": [["lantern_wyrm"]],
	},
}

static func get_enemy(id: String) -> Dictionary:
	return ENEMIES.get(id, {})
