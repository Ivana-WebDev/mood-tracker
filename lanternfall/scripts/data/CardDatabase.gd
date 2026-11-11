class_name CardDatabase
## Data-driven card definitions.
##
## Card keys:
##   name, cost (-1 = unplayable), type (attack/skill/power/status/curse),
##   rarity (starter/common/uncommon/rare/special), owner (warden/shade/arcanist/neutral/token/curse),
##   target ("enemy" needs a target, "none" otherwise), effects (Array), exhaust, up (card-level overrides).
## Effect keys:
##   type, value, times, target ("enemy"/"all"/"random"/"self"), status, card, count, base, per,
##   up (number => upgraded "value", or Dictionary of overrides).

const CARDS := {
	# ------------------------------------------------------------ CLOCKWRIGHT
	# Mechanic: Gadgets. Up to 3 deployed at once; each fires at the end of your turn until it winds down.
	"c_wrench": {"name": "Wrench Swing", "cost": 1, "type": "attack", "rarity": "starter", "owner": "clockwright", "target": "enemy",
		"effects": [{"type": "damage", "value": 6, "up": 9}]},
	"c_plating": {"name": "Plating", "cost": 1, "type": "skill", "rarity": "starter", "owner": "clockwright", "target": "none",
		"effects": [{"type": "block", "value": 5, "up": 8}]},
	"c_tick_turret": {"name": "Tick Turret", "cost": 1, "type": "skill", "rarity": "starter", "owner": "clockwright", "target": "none",
		"effects": [{"type": "gadget", "kind": "turret", "power": 3, "turns": 3, "up": {"power": 5}}]},
	"c_overclock": {"name": "Overclock", "cost": 1, "type": "skill", "rarity": "starter", "owner": "clockwright", "target": "none",
		"effects": [{"type": "overclock", "value": 1}], "up": {"cost": 0}},
	"c_rivet_shot": {"name": "Rivet Shot", "cost": 1, "type": "attack", "rarity": "common", "owner": "clockwright", "target": "enemy",
		"effects": [{"type": "damage", "value": 7, "up": 10}, {"type": "wind", "value": 1}]},
	"c_barrier_node": {"name": "Barrier Node", "cost": 1, "type": "skill", "rarity": "common", "owner": "clockwright", "target": "none",
		"effects": [{"type": "gadget", "kind": "barrier", "power": 4, "turns": 3, "up": {"power": 6}}]},
	"c_spanner_toss": {"name": "Spanner Toss", "cost": 1, "type": "attack", "rarity": "common", "owner": "clockwright", "target": "none",
		"effects": [{"type": "damage", "value": 5, "target": "all", "up": 8}]},
	"c_scrap_shield": {"name": "Scrap Shield", "cost": 1, "type": "skill", "rarity": "common", "owner": "clockwright", "target": "none",
		"effects": [{"type": "block", "value": 4, "up": 6}, {"type": "block_per", "count": "gadgets", "value": 3}]},
	"c_tinker": {"name": "Tinker", "cost": 0, "type": "skill", "rarity": "common", "owner": "clockwright", "target": "none",
		"effects": [{"type": "draw", "value": 1, "up": 2}, {"type": "tune", "value": 1}]},
	"c_steam_vent": {"name": "Steam Vent", "cost": 2, "type": "attack", "rarity": "common", "owner": "clockwright", "target": "enemy",
		"effects": [{"type": "damage_per", "count": "gadgets", "base": 8, "per": 4, "up": {"base": 11, "per": 5}}]},
	"c_target_lock": {"name": "Target Lock", "cost": 1, "type": "skill", "rarity": "common", "owner": "clockwright", "target": "enemy",
		"effects": [{"type": "apply", "status": "vulnerable", "value": 2, "up": 3}, {"type": "draw", "value": 1}]},
	"c_tesla_coil": {"name": "Tesla Coil", "cost": 2, "type": "skill", "rarity": "uncommon", "owner": "clockwright", "target": "none",
		"effects": [{"type": "gadget", "kind": "tesla", "power": 4, "turns": 3, "up": {"power": 6}}]},
	"c_repair_drone": {"name": "Repair Drone", "cost": 1, "type": "skill", "rarity": "uncommon", "owner": "clockwright", "target": "none",
		"exhaust": true, "effects": [{"type": "gadget", "kind": "drone", "power": 2, "turns": 3, "up": {"power": 3}}]},
	"c_amplifier": {"name": "Amplifier", "cost": 1, "type": "power", "rarity": "uncommon", "owner": "clockwright", "target": "none",
		"effects": [{"type": "apply", "status": "amplify", "value": 1, "target": "self", "up": 2}]},
	"c_double_shift": {"name": "Double Shift", "cost": 1, "type": "skill", "rarity": "uncommon", "owner": "clockwright", "target": "none",
		"exhaust": true, "effects": [{"type": "overclock", "value": 2}], "up": {"exhaust": false}},
	"c_cog_barrage": {"name": "Cog Barrage", "cost": 1, "type": "attack", "rarity": "uncommon", "owner": "clockwright", "target": "none",
		"effects": [{"type": "damage", "value": 3, "times": 4, "target": "random", "up": {"times": 6}}]},
	"c_reinforced_frame": {"name": "Reinforced Frame", "cost": 2, "type": "skill", "rarity": "uncommon", "owner": "clockwright", "target": "none",
		"effects": [{"type": "block", "value": 13, "up": 17}, {"type": "wind", "value": 1}]},
	"c_assembly_line": {"name": "Assembly Line", "cost": 2, "type": "power", "rarity": "rare", "owner": "clockwright", "target": "none",
		"effects": [{"type": "apply", "status": "factory", "value": 1, "target": "self"}], "up": {"cost": 1}},
	"c_siege_engine": {"name": "Siege Engine", "cost": 3, "type": "skill", "rarity": "rare", "owner": "clockwright", "target": "none",
		"effects": [{"type": "gadget", "kind": "cannon", "power": 12, "turns": 2, "up": {"power": 16}}]},
	"c_perpetual": {"name": "Perpetual Motion", "cost": 3, "type": "power", "rarity": "rare", "owner": "clockwright", "target": "none",
		"effects": [{"type": "apply", "status": "perpetual", "value": 1, "target": "self"}], "up": {"cost": 2}},

	# ------------------------------------------------------------- FATEBINDER
	# Mechanic: Fate Dice. Roll 3 dice every turn; cards spend, reroll and reshape them.
	"f_card_edge": {"name": "Card Edge", "cost": 1, "type": "attack", "rarity": "starter", "owner": "fatebinder", "target": "enemy",
		"effects": [{"type": "damage", "value": 6, "up": 9}]},
	"f_veil": {"name": "Veil", "cost": 1, "type": "skill", "rarity": "starter", "owner": "fatebinder", "target": "none",
		"effects": [{"type": "block", "value": 5, "up": 8}]},
	"f_fortune_blade": {"name": "Fortune Blade", "cost": 1, "type": "attack", "rarity": "starter", "owner": "fatebinder", "target": "enemy",
		"effects": [{"type": "die_damage", "pick": "high", "mult": 2, "bonus": 0, "up": {"bonus": 4}}]},
	"f_second_roll": {"name": "Second Roll", "cost": 0, "type": "skill", "rarity": "starter", "owner": "fatebinder", "target": "none",
		"effects": [{"type": "reroll"}, {"type": "draw", "value": 1, "up": 2}]},
	"f_lucky_strike": {"name": "Lucky Strike", "cost": 1, "type": "attack", "rarity": "common", "owner": "fatebinder", "target": "enemy",
		"effects": [{"type": "damage", "value": 7, "up": 10}, {"type": "add_die"}]},
	"f_charm_ward": {"name": "Charm Ward", "cost": 1, "type": "skill", "rarity": "common", "owner": "fatebinder", "target": "none",
		"effects": [{"type": "die_block", "pick": "low", "mult": 2, "bonus": 4, "up": {"bonus": 7}}]},
	"f_gamble": {"name": "Gamble", "cost": 1, "type": "attack", "rarity": "common", "owner": "fatebinder", "target": "enemy",
		"effects": [{"type": "die_damage", "pick": "low", "mult": 3, "bonus": 2, "up": {"mult": 4}}]},
	"f_tilt": {"name": "Tilt the Odds", "cost": 1, "type": "skill", "rarity": "common", "owner": "fatebinder", "target": "none",
		"effects": [{"type": "bump", "value": 1, "up": 2}, {"type": "draw", "value": 1}]},
	"f_omen": {"name": "Ill Omen", "cost": 1, "type": "skill", "rarity": "common", "owner": "fatebinder", "target": "enemy",
		"effects": [{"type": "apply", "status": "weak", "value": 2, "up": 3}, {"type": "apply", "status": "vulnerable", "value": 1, "up": 2}]},
	"f_dealers_hand": {"name": "Dealer's Hand", "cost": 1, "type": "skill", "rarity": "common", "owner": "fatebinder", "target": "none",
		"effects": [{"type": "block", "value": 6, "up": 9}, {"type": "reroll"}]},
	"f_coin_toss": {"name": "Coin Toss", "cost": 0, "type": "attack", "rarity": "common", "owner": "fatebinder", "target": "enemy",
		"effects": [{"type": "damage", "value": 4, "up": 6}, {"type": "bump", "value": 1}]},
	"f_jackpot": {"name": "Jackpot", "cost": 2, "type": "attack", "rarity": "uncommon", "owner": "fatebinder", "target": "enemy",
		"effects": [{"type": "dice_sum", "mult": 1, "base": 0, "up": {"base": 6}}]},
	"f_destiny": {"name": "Destiny", "cost": 1, "type": "skill", "rarity": "uncommon", "owner": "fatebinder", "target": "none",
		"effects": [{"type": "set_low", "value": 6}, {"type": "draw", "value": 1}], "up": {"cost": 0}},
	"f_loaded": {"name": "Loaded Dice", "cost": 1, "type": "power", "rarity": "uncommon", "owner": "fatebinder", "target": "none",
		"effects": [{"type": "apply", "status": "lucky", "value": 1, "target": "self", "up": 2}]},
	"f_fourth_die": {"name": "Fourth Die", "cost": 2, "type": "power", "rarity": "uncommon", "owner": "fatebinder", "target": "none",
		"effects": [{"type": "apply", "status": "extra_die", "value": 1, "target": "self"}], "up": {"cost": 1}},
	"f_double_down": {"name": "Double Down", "cost": 1, "type": "skill", "rarity": "uncommon", "owner": "fatebinder", "target": "none",
		"effects": [{"type": "double_high"}], "up": {"cost": 0}},
	"f_fortune_shield": {"name": "Fortune Shield", "cost": 2, "type": "skill", "rarity": "uncommon", "owner": "fatebinder", "target": "none",
		"effects": [{"type": "die_block", "pick": "high", "mult": 3, "bonus": 2, "up": {"mult": 4}}]},
	"f_critical_fate": {"name": "Critical Fate", "cost": 2, "type": "power", "rarity": "rare", "owner": "fatebinder", "target": "none",
		"effects": [{"type": "apply", "status": "fate_six", "value": 1, "target": "self"}], "up": {"cost": 1}},
	"f_all_in": {"name": "All In", "cost": 3, "type": "attack", "rarity": "rare", "owner": "fatebinder", "target": "enemy",
		"effects": [{"type": "dice_sum", "mult": 2, "base": 0, "up": {"mult": 3}}]},
	"f_rewrite": {"name": "Rewrite Fate", "cost": 1, "type": "skill", "rarity": "rare", "owner": "fatebinder", "target": "none",
		"exhaust": true, "effects": [{"type": "set_all", "value": 6}, {"type": "add_die", "value": 6, "up": {"count": 2}}]},

	# ------------------------------------------------------------- DUSKDANCER
	# Mechanic: Flow. Playing a different card type than the previous card builds Flow (max 6);
	# repeating a type breaks it. Each Flow adds +1 damage per hit and +1 Block.
	"d_lash": {"name": "Ribbon Lash", "cost": 1, "type": "attack", "rarity": "starter", "owner": "duskdancer", "target": "enemy",
		"effects": [{"type": "damage", "value": 6, "up": 9}]},
	"d_pirouette": {"name": "Pirouette", "cost": 1, "type": "skill", "rarity": "starter", "owner": "duskdancer", "target": "none",
		"effects": [{"type": "block", "value": 5, "up": 8}]},
	"d_crescendo": {"name": "Crescendo", "cost": 1, "type": "attack", "rarity": "starter", "owner": "duskdancer", "target": "enemy",
		"effects": [{"type": "burst", "status": "flow", "base": 4, "per": 3, "up": {"base": 5, "per": 4}}]},
	"d_light_step": {"name": "Light Step", "cost": 0, "type": "skill", "rarity": "starter", "owner": "duskdancer", "target": "none",
		"effects": [{"type": "block", "value": 2, "up": 4}, {"type": "draw", "value": 1}]},
	"d_fan_kick": {"name": "Fan Kick", "cost": 1, "type": "attack", "rarity": "common", "owner": "duskdancer", "target": "none",
		"effects": [{"type": "damage", "value": 5, "target": "all", "up": 8}]},
	"d_twirl": {"name": "Twirl", "cost": 1, "type": "skill", "rarity": "common", "owner": "duskdancer", "target": "none",
		"effects": [{"type": "block", "value": 6, "up": 9}, {"type": "apply", "status": "flow", "value": 1, "target": "self"}]},
	"d_flourish": {"name": "Flourish", "cost": 1, "type": "attack", "rarity": "common", "owner": "duskdancer", "target": "enemy",
		"effects": [{"type": "damage", "value": 3, "times": 2, "up": 4}]},
	"d_tempo": {"name": "Tempo", "cost": 1, "type": "skill", "rarity": "common", "owner": "duskdancer", "target": "none",
		"effects": [{"type": "draw", "value": 2, "up": 3}]},
	"d_downbeat": {"name": "Downbeat", "cost": 0, "type": "attack", "rarity": "common", "owner": "duskdancer", "target": "enemy",
		"effects": [{"type": "damage", "value": 3, "up": 5}]},
	"d_veil_dance": {"name": "Veil Dance", "cost": 1, "type": "skill", "rarity": "common", "owner": "duskdancer", "target": "enemy",
		"effects": [{"type": "block", "value": 3}, {"type": "apply", "status": "weak", "value": 2, "up": 3}]},
	"d_leap": {"name": "Leap", "cost": 1, "type": "attack", "rarity": "common", "owner": "duskdancer", "target": "enemy",
		"effects": [{"type": "damage", "value": 7, "up": 10}, {"type": "apply", "status": "flow", "value": 1, "target": "self"}]},
	"d_grace": {"name": "Grace", "cost": 1, "type": "power", "rarity": "uncommon", "owner": "duskdancer", "target": "none",
		"effects": [{"type": "apply", "status": "grace", "value": 1, "target": "self"}], "up": {"cost": 0}},
	"d_rhythm": {"name": "Rhythm", "cost": 1, "type": "power", "rarity": "uncommon", "owner": "duskdancer", "target": "none",
		"effects": [{"type": "apply", "status": "rhythm", "value": 1, "target": "self"}], "up": {"cost": 0}},
	"d_finale": {"name": "Finale", "cost": 2, "type": "attack", "rarity": "uncommon", "owner": "duskdancer", "target": "none",
		"effects": [{"type": "burst", "status": "flow", "base": 3, "per": 3, "target": "all", "up": {"base": 6, "per": 4}}]},
	"d_encore": {"name": "Encore", "cost": 0, "type": "skill", "rarity": "uncommon", "owner": "duskdancer", "target": "none",
		"exhaust": true, "effects": [{"type": "energy", "value": 1, "up": 2}, {"type": "apply", "status": "flow", "value": 1, "target": "self"}]},
	"d_sway": {"name": "Sway", "cost": 2, "type": "skill", "rarity": "uncommon", "owner": "duskdancer", "target": "none",
		"effects": [{"type": "block", "value": 6, "up": 9}, {"type": "block_per", "count": "flow", "value": 2, "up": 3}]},
	"d_ribbon_storm": {"name": "Ribbon Storm", "cost": 2, "type": "attack", "rarity": "uncommon", "owner": "duskdancer", "target": "none",
		"effects": [{"type": "damage", "value": 2, "times": 5, "target": "random", "up": {"times": 7}}]},
	"d_spotlight": {"name": "Spotlight", "cost": 3, "type": "power", "rarity": "rare", "owner": "duskdancer", "target": "none",
		"effects": [{"type": "apply", "status": "spotlight", "value": 1, "target": "self"}], "up": {"cost": 2}},
	"d_grand_jete": {"name": "Grand Jete", "cost": 2, "type": "attack", "rarity": "rare", "owner": "duskdancer", "target": "enemy",
		"effects": [{"type": "damage", "value": 14, "up": 18}, {"type": "apply", "status": "flow", "value": 2, "target": "self"}]},
	"d_ovation": {"name": "Standing Ovation", "cost": 1, "type": "skill", "rarity": "rare", "owner": "duskdancer", "target": "none",
		"exhaust": true, "effects": [{"type": "apply", "status": "flow", "value": 4, "target": "self", "up": 6}]},

	# ----------------------------------------------------------------- NEUTRAL
	"n_bandage": {"name": "Bandage", "cost": 0, "type": "skill", "rarity": "uncommon", "owner": "neutral", "target": "none",
		"exhaust": true, "effects": [{"type": "heal", "value": 4, "up": 6}]},
	"n_flashbang": {"name": "Flashbang", "cost": 0, "type": "skill", "rarity": "uncommon", "owner": "neutral", "target": "none",
		"effects": [{"type": "apply", "status": "weak", "value": 1, "target": "all", "up": 2}, {"type": "draw", "value": 1}]},
	"n_second_wind": {"name": "Second Wind", "cost": 1, "type": "skill", "rarity": "uncommon", "owner": "neutral", "target": "none",
		"exhaust": true, "effects": [{"type": "block", "value": 12, "up": 16}]},
	"n_quickstep": {"name": "Quickstep", "cost": 0, "type": "skill", "rarity": "uncommon", "owner": "neutral", "target": "none",
		"effects": [{"type": "block", "value": 2, "up": 4}, {"type": "draw", "value": 1}]},
	"n_crushing_blow": {"name": "Crushing Blow", "cost": 2, "type": "attack", "rarity": "uncommon", "owner": "neutral", "target": "enemy",
		"effects": [{"type": "damage", "value": 15, "up": 20}]},
	"n_battle_trance": {"name": "Battle Trance", "cost": 0, "type": "skill", "rarity": "rare", "owner": "neutral", "target": "none",
		"exhaust": true, "effects": [{"type": "draw", "value": 3, "up": 4}]},

	# --------------------------------------------------------- STATUS / CURSES
	"x_wound": {"name": "Wound", "cost": -1, "type": "status", "rarity": "special", "owner": "curse", "target": "none",
		"unplayable": true, "effects": []},
	"x_doubt": {"name": "Doubt", "cost": -1, "type": "curse", "rarity": "special", "owner": "curse", "target": "none",
		"unplayable": true, "ethereal_text": "At the end of your turn, gain 1 Weak.", "effects": []},
}

const GADGETS := {
	"turret": {"name": "Tick Turret", "icon": "turret", "color": "f2b84b", "desc": "deals %d damage to a random enemy"},
	"barrier": {"name": "Barrier Node", "icon": "shield", "color": "5ab0ff", "desc": "gives %d Block"},
	"tesla": {"name": "Tesla Coil", "icon": "bolt", "color": "7ee8ff", "desc": "deals %d damage to ALL enemies"},
	"drone": {"name": "Repair Drone", "icon": "heart", "color": "46c37b", "desc": "heals %d HP"},
	"cannon": {"name": "Siege Cannon", "icon": "cannon", "color": "ff8a4f", "desc": "deals %d damage to the strongest enemy"},
}

const STATUS_INFO := {
	"strength": {"name": "Strength", "desc": "Attacks deal +X damage.", "buff": true},
	"dexterity": {"name": "Dexterity", "desc": "Block cards give +X Block.", "buff": true},
	"vulnerable": {"name": "Vulnerable", "desc": "Takes 50% more attack damage. Decreases each turn.", "buff": false},
	"weak": {"name": "Weak", "desc": "Deals 25% less attack damage. Decreases each turn.", "buff": false},
	"bleed": {"name": "Burn", "desc": "Loses X HP at the start of its turn, then Burn decreases by 1.", "buff": false},
	"thorns": {"name": "Thorns", "desc": "Attackers take X damage.", "buff": true},
	"ritual": {"name": "Ritual", "desc": "Gains X Strength at the end of its turn.", "buff": true},
	"regen": {"name": "Regen", "desc": "Heals X HP at the end of its turn.", "buff": true},
	# Clockwright
	"amplify": {"name": "Amplifier", "desc": "Gadgets you deploy get +X power.", "buff": true},
	"factory": {"name": "Assembly Line", "desc": "At the start of each turn, deploy X Tick Turret (2 damage, 2 turns).", "buff": true},
	"perpetual": {"name": "Perpetual Motion", "desc": "Your Gadgets never wind down.", "buff": true},
	# Fatebinder
	"lucky": {"name": "Loaded Dice", "desc": "Your Fate Dice roll +X (max 6).", "buff": true},
	"extra_die": {"name": "Fourth Die", "desc": "Roll X extra Fate Die each turn.", "buff": true},
	"fate_six": {"name": "Critical Fate", "desc": "Whenever you spend a 6 or higher, gain X Energy and draw X card.", "buff": true},
	# Duskdancer
	"flow": {"name": "Flow", "desc": "+X damage per hit and +X Block. Alternate card types to build it; repeating a type breaks it.", "buff": true},
	"grace": {"name": "Grace", "desc": "Repeating a card type only loses 1 Flow instead of all of it.", "buff": true},
	"rhythm": {"name": "Rhythm", "desc": "At the start of each turn, gain X Flow.", "buff": true},
	"spotlight": {"name": "Spotlight", "desc": "Flow bonuses are doubled.", "buff": true},
}

const POWER_STATUSES := ["amplify", "factory", "perpetual", "lucky", "extra_die", "fate_six", "grace", "rhythm", "spotlight"]
const FLOW_MAX := 6

const DECAYING := ["vulnerable", "weak"]


static func exists(id: String) -> bool:
	return CARDS.has(id)


## Returns the fully resolved card definition (with upgrade applied).
static func resolve(id: String, upgraded: bool = false) -> Dictionary:
	if not CARDS.has(id):
		push_error("Unknown card: %s" % id)
		return {}
	var base: Dictionary = CARDS[id].duplicate(true)
	base["id"] = id
	base["upgraded"] = upgraded
	var resolved_effects: Array = []
	for e in base.get("effects", []):
		var eff: Dictionary = e.duplicate(true)
		var up = eff.get("up", null)
		eff.erase("up")
		if upgraded and up != null:
			if typeof(up) == TYPE_DICTIONARY:
				for k in up:
					eff[k] = up[k]
			else:
				eff["value"] = up
		resolved_effects.append(eff)
	base["effects"] = resolved_effects
	var card_up: Dictionary = base.get("up", {})
	base.erase("up")
	if upgraded:
		for k in card_up:
			base[k] = card_up[k]
		base["name"] = base["name"] + "+"
	if not base.has("exhaust"):
		base["exhaust"] = false
	return base


static func can_upgrade(id: String) -> bool:
	if not CARDS.has(id):
		return false
	var c: Dictionary = CARDS[id]
	if c.get("unplayable", false):
		return false
	if c.has("up"):
		return true
	for e in c.get("effects", []):
		if e.has("up"):
			return true
	return false


static func pool(owner: String, rarity: String) -> Array:
	var out: Array = []
	for id in CARDS:
		var c: Dictionary = CARDS[id]
		if c["owner"] == owner and c["rarity"] == rarity:
			out.append(id)
	return out


static func status_name(s: String) -> String:
	return STATUS_INFO.get(s, {"name": s.capitalize()})["name"]


## Builds rules text. If `ctx` (a CombatManager) is given, numbers include modifiers.
static func describe(card: Dictionary, ctx = null, target = null) -> String:
	var lines: PackedStringArray = []
	if card.get("unplayable", false):
		lines.append("Unplayable.")
		if card.has("ethereal_text"):
			lines.append(card["ethereal_text"])
	for e in card.get("effects", []):
		lines.append(_describe_effect(e, card, ctx, target))
	if card.get("exhaust", false):
		lines.append("Exhaust.")
	if card.get("type", "") == "power":
		pass
	return "\n".join(lines)


static func _dmg(base: int, ctx, target) -> int:
	if ctx == null:
		return base
	return ctx.preview_damage(base, target)


static func _blk(base: int, ctx) -> int:
	if ctx == null:
		return base
	return ctx.preview_block(base)


static func _pick_word(p: String) -> String:
	return "highest" if p == "high" else "lowest"


static func _describe_effect(e: Dictionary, card: Dictionary, ctx, target) -> String:
	var tgt: String = e.get("target", card.get("target", "enemy"))
	match e["type"]:
		"damage":
			var d := _dmg(int(e["value"]), ctx, target if tgt == "enemy" else null)
			var times: int = int(e.get("times", 1))
			var s := "Deal %d damage" % d
			if times > 1:
				s += " %d times" % times
			if tgt == "all":
				s += " to ALL enemies"
			elif tgt == "random":
				s += " to random enemies"
			return s + "."
		"block":
			return "Gain %d Block." % _blk(int(e["value"]), ctx)
		"apply":
			var sname := status_name(e["status"])
			if tgt == "self":
				if e["status"] in POWER_STATUSES:
					var txt: String = STATUS_INFO[e["status"]]["desc"].replace("X", str(e["value"]))
					return txt.replace("deploy 1 Tick", "deploy a Tick").replace("Roll 1 extra Fate Die", "Roll an extra Fate Die").replace("draw 1 card", "draw a card")
				return "Gain %d %s." % [int(e["value"]), sname]
			if tgt == "all":
				return "Apply %d %s to ALL enemies." % [int(e["value"]), sname]
			return "Apply %d %s." % [int(e["value"]), sname]
		"draw":
			var n := int(e["value"])
			return "Draw %d card%s." % [n, "" if n == 1 else "s"]
		"energy":
			return "Gain %d Energy." % int(e["value"])
		"heal":
			return "Heal %d HP." % int(e["value"])
		"lose_hp":
			return "Lose %d HP." % int(e["value"])
		"add_card":
			var nm: String = CARDS[e["card"]]["name"]
			var cnt := int(e.get("count", 1))
			return "Add %d %s%s to your hand." % [cnt, nm, "" if cnt == 1 else "s"]
		"double_block":
			return "Double your Block."
		# --- Clockwright
		"gadget":
			var g: Dictionary = GADGETS[e["kind"]]
			var pw := int(e["power"])
			if ctx != null:
				pw += ctx.player.get_status("amplify")
			return "Deploy %s: %s for %d turns." % [g["name"], g["desc"] % pw, int(e["turns"])]
		"overclock":
			var times2 := int(e["value"])
			return "Fire all Gadgets%s." % ("" if times2 == 1 else " %d times" % times2)
		"wind":
			return "Gadgets +%d turn%s." % [int(e["value"]), "" if int(e["value"]) == 1 else "s"]
		"tune":
			return "Gadgets +%d power." % int(e["value"])
		"block_per":
			var what := "Gadget" if e["count"] == "gadgets" else status_name(e["count"])
			var s2 := "Gain %d Block per %s" % [int(e["value"]), what]
			if ctx != null:
				s2 += " (%d)" % (int(e["value"]) * ctx.count_of(e["count"]))
			return s2 + "."
		"damage_per":
			var what2 := "Gadget" if e["count"] == "gadgets" else status_name(e["count"])
			if ctx != null:
				var raw: int = int(e["base"]) + int(e["per"]) * ctx.count_of(e["count"])
				return "Deal %d damage (%d + %d per %s)." % [_dmg(raw, ctx, target), int(e["base"]), int(e["per"]), what2]
			return "Deal %d damage +%d per %s." % [int(e["base"]), int(e["per"]), what2]
		# --- Fatebinder
		"die_damage":
			var s3 := "Spend your %s die: deal %dx its value" % [_pick_word(e["pick"]), int(e["mult"])]
			if int(e.get("bonus", 0)) > 0:
				s3 += " +%d" % int(e["bonus"])
			s3 += " damage"
			if ctx != null and not ctx.dice.is_empty():
				var v: int = ctx.peek_die(e["pick"])
				s3 += " (%d)" % _dmg(v * int(e["mult"]) + int(e.get("bonus", 0)), ctx, target)
			return s3 + "."
		"die_block":
			var s4 := "Spend your %s die: gain %dx its value" % [_pick_word(e["pick"]), int(e["mult"])]
			if int(e.get("bonus", 0)) > 0:
				s4 += " +%d" % int(e["bonus"])
			s4 += " Block"
			if ctx != null and not ctx.dice.is_empty():
				s4 += " (%d)" % _blk(ctx.peek_die(e["pick"]) * int(e["mult"]) + int(e.get("bonus", 0)), ctx)
			return s4 + "."
		"reroll":
			return "Reroll your dice."
		"add_die":
			var c2 := int(e.get("count", 1))
			if int(e.get("value", 0)) > 0:
				return "Add %s showing %d." % ["a die" if c2 == 1 else "%d dice" % c2, int(e["value"])]
			return "Roll %s." % ("an extra die" if c2 == 1 else "%d extra dice" % c2)
		"bump":
			return "All dice +%d." % int(e["value"])
		"set_low":
			return "Set your lowest die to %d." % int(e["value"])
		"set_all":
			return "Set all dice to %d." % int(e["value"])
		"double_high":
			return "Double your highest die."
		"dice_sum":
			var s5 := "Spend ALL dice: deal %sthe total" % ("" if int(e["mult"]) == 1 else "%dx " % int(e["mult"]))
			if int(e.get("base", 0)) > 0:
				s5 += " +%d" % int(e["base"])
			s5 += " damage"
			if ctx != null:
				s5 += " (%d)" % _dmg(ctx.dice_total() * int(e["mult"]) + int(e.get("base", 0)), ctx, target)
			return s5 + "."
		# --- Duskdancer
		"burst":
			var sn := status_name(e["status"])
			var s6 := "Deal %d + %d per %s damage" % [int(e["base"]), int(e["per"]), sn]
			if ctx != null:
				var raw2: int = int(e["base"]) + int(e["per"]) * ctx.player.get_status(e["status"])
				s6 = "Deal %d damage" % _dmg(raw2, ctx, target if tgt == "enemy" else null)
			if tgt == "all":
				s6 += " to ALL enemies"
			return s6 + ". Spend all %s." % sn
	return ""
