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
	# ------------------------------------------------------------------ WARDEN
	"w_hack": {"name": "Hack", "cost": 1, "type": "attack", "rarity": "starter", "owner": "warden", "target": "enemy",
		"effects": [{"type": "damage", "value": 6, "up": 9}]},
	"w_guard": {"name": "Guard", "cost": 1, "type": "skill", "rarity": "starter", "owner": "warden", "target": "none",
		"effects": [{"type": "block", "value": 5, "up": 8}]},
	"w_shatter_blow": {"name": "Shatter Blow", "cost": 2, "type": "attack", "rarity": "starter", "owner": "warden", "target": "enemy",
		"effects": [{"type": "damage", "value": 8, "up": 10}, {"type": "apply", "status": "vulnerable", "value": 2, "up": 3}]},
	"w_rampart_slam": {"name": "Rampart Slam", "cost": 1, "type": "attack", "rarity": "common", "owner": "warden", "target": "enemy",
		"effects": [{"type": "damage_block"}], "up": {"cost": 0}},
	"w_iron_skin": {"name": "Iron Skin", "cost": 1, "type": "skill", "rarity": "common", "owner": "warden", "target": "none",
		"effects": [{"type": "block", "value": 8, "up": 11}]},
	"w_heavy_swing": {"name": "Heavy Swing", "cost": 2, "type": "attack", "rarity": "common", "owner": "warden", "target": "enemy",
		"effects": [{"type": "damage", "value": 14, "up": 19}]},
	"w_twin_cut": {"name": "Twin Cut", "cost": 1, "type": "attack", "rarity": "common", "owner": "warden", "target": "enemy",
		"effects": [{"type": "damage", "value": 4, "times": 2, "up": 6}]},
	"w_brace": {"name": "Brace", "cost": 0, "type": "skill", "rarity": "common", "owner": "warden", "target": "none",
		"effects": [{"type": "block", "value": 3, "up": 5}, {"type": "draw", "value": 1}]},
	"w_taunt": {"name": "Taunt", "cost": 1, "type": "skill", "rarity": "common", "owner": "warden", "target": "none",
		"effects": [{"type": "block", "value": 4, "up": 6}, {"type": "apply", "status": "weak", "value": 2, "target": "all", "up": 3}]},
	"w_sweep": {"name": "Wide Sweep", "cost": 1, "type": "attack", "rarity": "common", "owner": "warden", "target": "none",
		"effects": [{"type": "damage", "value": 7, "target": "all", "up": 10}]},
	"w_war_cry": {"name": "War Cry", "cost": 1, "type": "skill", "rarity": "uncommon", "owner": "warden", "target": "none",
		"exhaust": true, "effects": [{"type": "apply", "status": "strength", "value": 2, "target": "self", "up": 3}]},
	"w_bulwark": {"name": "Bulwark", "cost": 2, "type": "power", "rarity": "uncommon", "owner": "warden", "target": "none",
		"effects": [{"type": "apply", "status": "bulwark", "value": 4, "target": "self", "up": 6}]},
	"w_counter": {"name": "Spiked Guard", "cost": 1, "type": "skill", "rarity": "uncommon", "owner": "warden", "target": "none",
		"effects": [{"type": "block", "value": 6, "up": 9}, {"type": "apply", "status": "thorns", "value": 3, "target": "self", "up": 4}]},
	"w_bloodlust": {"name": "Bloodlust", "cost": 0, "type": "skill", "rarity": "uncommon", "owner": "warden", "target": "none",
		"effects": [{"type": "lose_hp", "value": 3}, {"type": "energy", "value": 2, "up": 3}]},
	"w_shield_wall": {"name": "Shield Wall", "cost": 2, "type": "skill", "rarity": "uncommon", "owner": "warden", "target": "none",
		"effects": [{"type": "block", "value": 15, "up": 20}]},
	"w_steadfast": {"name": "Steadfast", "cost": 3, "type": "power", "rarity": "rare", "owner": "warden", "target": "none",
		"effects": [{"type": "apply", "status": "steadfast", "value": 1, "target": "self"}], "up": {"cost": 2}},
	"w_berserk": {"name": "Rising Fury", "cost": 1, "type": "power", "rarity": "rare", "owner": "warden", "target": "none",
		"effects": [{"type": "apply", "status": "rage", "value": 1, "target": "self"}], "up": {"cost": 0}},
	"w_titan_blow": {"name": "Titan Blow", "cost": 3, "type": "attack", "rarity": "rare", "owner": "warden", "target": "enemy",
		"effects": [{"type": "damage", "value": 30, "up": 40}]},
	"w_unbreakable": {"name": "Unbreakable", "cost": 1, "type": "skill", "rarity": "rare", "owner": "warden", "target": "none",
		"exhaust": true, "effects": [{"type": "double_block"}], "up": {"exhaust": false}},

	# ------------------------------------------------------------------- SHADE
	"s_slash": {"name": "Slash", "cost": 1, "type": "attack", "rarity": "starter", "owner": "shade", "target": "enemy",
		"effects": [{"type": "damage", "value": 6, "up": 9}]},
	"s_evade": {"name": "Evade", "cost": 1, "type": "skill", "rarity": "starter", "owner": "shade", "target": "none",
		"effects": [{"type": "block", "value": 5, "up": 8}]},
	"s_lacerate": {"name": "Lacerate", "cost": 1, "type": "attack", "rarity": "starter", "owner": "shade", "target": "enemy",
		"effects": [{"type": "damage", "value": 4, "up": 5}, {"type": "apply", "status": "bleed", "value": 3, "up": 5}]},
	"s_knife_fan": {"name": "Knife Fan", "cost": 1, "type": "skill", "rarity": "starter", "owner": "shade", "target": "none",
		"effects": [{"type": "add_card", "card": "t_knife", "count": 2, "up": {"count": 3}}]},
	"s_rend": {"name": "Rend", "cost": 1, "type": "attack", "rarity": "common", "owner": "shade", "target": "enemy",
		"effects": [{"type": "damage", "value": 7, "up": 9}, {"type": "apply", "status": "bleed", "value": 2, "up": 3}]},
	"s_sidestep": {"name": "Sidestep", "cost": 1, "type": "skill", "rarity": "common", "owner": "shade", "target": "none",
		"effects": [{"type": "block", "value": 7, "up": 10}, {"type": "draw", "value": 1}]},
	"s_flurry": {"name": "Flurry", "cost": 1, "type": "attack", "rarity": "common", "owner": "shade", "target": "enemy",
		"effects": [{"type": "damage", "value": 3, "times": 3, "up": 4}]},
	"s_razor_wind": {"name": "Razor Wind", "cost": 1, "type": "attack", "rarity": "common", "owner": "shade", "target": "none",
		"effects": [{"type": "damage", "value": 4, "target": "all", "up": 6}, {"type": "apply", "status": "bleed", "value": 2, "target": "all", "up": 3}]},
	"s_focus_breath": {"name": "Focus Breath", "cost": 0, "type": "skill", "rarity": "common", "owner": "shade", "target": "none",
		"exhaust": true, "effects": [{"type": "draw", "value": 2, "up": 3}]},
	"s_hamstring": {"name": "Hamstring", "cost": 1, "type": "skill", "rarity": "common", "owner": "shade", "target": "enemy",
		"effects": [{"type": "apply", "status": "weak", "value": 2, "up": 3}, {"type": "apply", "status": "vulnerable", "value": 1, "up": 2}]},
	"s_serrated": {"name": "Serrated Edge", "cost": 1, "type": "power", "rarity": "uncommon", "owner": "shade", "target": "none",
		"effects": [{"type": "apply", "status": "serrated", "value": 1, "target": "self", "up": 2}]},
	"s_exsanguinate": {"name": "Exsanguinate", "cost": 1, "type": "attack", "rarity": "uncommon", "owner": "shade", "target": "enemy",
		"effects": [{"type": "bleed_burst", "value": 2, "up": 3}]},
	"s_veil": {"name": "Shadow Veil", "cost": 1, "type": "power", "rarity": "uncommon", "owner": "shade", "target": "none",
		"effects": [{"type": "apply", "status": "dexterity", "value": 2, "target": "self", "up": 3}]},
	"s_adrenaline": {"name": "Adrenaline", "cost": 0, "type": "skill", "rarity": "uncommon", "owner": "shade", "target": "none",
		"exhaust": true, "effects": [{"type": "energy", "value": 1, "up": 2}, {"type": "draw", "value": 2}]},
	"s_blade_storm": {"name": "Blade Storm", "cost": 2, "type": "attack", "rarity": "uncommon", "owner": "shade", "target": "none",
		"effects": [{"type": "damage", "value": 4, "times": 5, "target": "random", "up": {"times": 7}}]},
	"s_hemorrhage": {"name": "Hemorrhage", "cost": 2, "type": "attack", "rarity": "rare", "owner": "shade", "target": "enemy",
		"effects": [{"type": "damage", "value": 10, "up": 12}, {"type": "apply", "status": "bleed", "value": 8, "up": 12}]},
	"s_phantom_blades": {"name": "Phantom Blades", "cost": 2, "type": "power", "rarity": "rare", "owner": "shade", "target": "none",
		"effects": [{"type": "apply", "status": "phantom", "value": 1, "target": "self"}], "up": {"cost": 1}},
	"s_thousand_cuts": {"name": "Thousand Cuts", "cost": 2, "type": "attack", "rarity": "rare", "owner": "shade", "target": "enemy",
		"effects": [{"type": "damage", "value": 2, "times": 8, "up": 3}]},

	# ---------------------------------------------------------------- ARCANIST
	"a_bolt": {"name": "Bolt", "cost": 1, "type": "attack", "rarity": "starter", "owner": "arcanist", "target": "enemy",
		"effects": [{"type": "damage", "value": 6, "up": 9}]},
	"a_ward": {"name": "Ward", "cost": 1, "type": "skill", "rarity": "starter", "owner": "arcanist", "target": "none",
		"effects": [{"type": "block", "value": 5, "up": 8}]},
	"a_channel": {"name": "Channel", "cost": 1, "type": "skill", "rarity": "starter", "owner": "arcanist", "target": "none",
		"effects": [{"type": "block", "value": 3, "up": 5}, {"type": "apply", "status": "charge", "value": 2, "target": "self", "up": 3}]},
	"a_discharge": {"name": "Discharge", "cost": 1, "type": "attack", "rarity": "starter", "owner": "arcanist", "target": "enemy",
		"effects": [{"type": "charge_burst", "base": 3, "per": 3, "up": {"base": 4, "per": 4}}]},
	"a_spark_shield": {"name": "Spark Shield", "cost": 1, "type": "skill", "rarity": "common", "owner": "arcanist", "target": "none",
		"effects": [{"type": "block", "value": 6, "up": 9}, {"type": "apply", "status": "charge", "value": 1, "target": "self"}]},
	"a_arc_lash": {"name": "Arc Lash", "cost": 1, "type": "attack", "rarity": "common", "owner": "arcanist", "target": "enemy",
		"effects": [{"type": "damage", "value": 8, "up": 11}, {"type": "apply", "status": "charge", "value": 1, "target": "self"}]},
	"a_chain_lightning": {"name": "Chain Lightning", "cost": 2, "type": "attack", "rarity": "common", "owner": "arcanist", "target": "none",
		"effects": [{"type": "damage", "value": 9, "target": "all", "up": 12}]},
	"a_static_field": {"name": "Static Field", "cost": 1, "type": "skill", "rarity": "common", "owner": "arcanist", "target": "none",
		"effects": [{"type": "block", "value": 2}, {"type": "block_charge", "value": 3, "up": 4}]},
	"a_insight": {"name": "Insight", "cost": 1, "type": "skill", "rarity": "common", "owner": "arcanist", "target": "none",
		"effects": [{"type": "draw", "value": 2, "up": 3}, {"type": "apply", "status": "charge", "value": 1, "target": "self"}]},
	"a_frost_ray": {"name": "Frost Ray", "cost": 1, "type": "attack", "rarity": "common", "owner": "arcanist", "target": "enemy",
		"effects": [{"type": "damage", "value": 6, "up": 8}, {"type": "apply", "status": "weak", "value": 2, "up": 3}]},
	"a_overflow": {"name": "Overflow", "cost": 1, "type": "power", "rarity": "uncommon", "owner": "arcanist", "target": "none",
		"effects": [{"type": "apply", "status": "overflow", "value": 1, "target": "self"}], "up": {"cost": 0}},
	"a_meteor": {"name": "Meteor", "cost": 3, "type": "attack", "rarity": "uncommon", "owner": "arcanist", "target": "none",
		"effects": [{"type": "charge_burst", "base": 10, "per": 5, "target": "all", "up": {"base": 14, "per": 6}}]},
	"a_surge": {"name": "Mana Surge", "cost": 0, "type": "skill", "rarity": "uncommon", "owner": "arcanist", "target": "none",
		"exhaust": true, "effects": [{"type": "energy", "value": 1, "up": 2}, {"type": "apply", "status": "charge", "value": 1, "target": "self"}]},
	"a_amplify": {"name": "Amplify", "cost": 1, "type": "skill", "rarity": "uncommon", "owner": "arcanist", "target": "none",
		"exhaust": true, "effects": [{"type": "double_charge"}], "up": {"exhaust": false}},
	"a_mirror_ward": {"name": "Mirror Ward", "cost": 2, "type": "skill", "rarity": "uncommon", "owner": "arcanist", "target": "none",
		"effects": [{"type": "block", "value": 10, "up": 14}, {"type": "apply", "status": "thorns", "value": 3, "target": "self"}]},
	"a_singularity": {"name": "Singularity", "cost": 2, "type": "attack", "rarity": "rare", "owner": "arcanist", "target": "enemy",
		"effects": [{"type": "charge_burst", "base": 4, "per": 8, "up": {"base": 6, "per": 10}}]},
	"a_ley_line": {"name": "Ley Line", "cost": 2, "type": "power", "rarity": "rare", "owner": "arcanist", "target": "none",
		"effects": [{"type": "apply", "status": "ley", "value": 1, "target": "self"}], "up": {"cost": 1}},
	"a_time_warp": {"name": "Time Warp", "cost": 2, "type": "skill", "rarity": "rare", "owner": "arcanist", "target": "none",
		"exhaust": true, "effects": [{"type": "draw", "value": 4}, {"type": "energy", "value": 2}], "up": {"cost": 1}},

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

	# ------------------------------------------------------- TOKENS / STATUS / CURSES
	"t_knife": {"name": "Knife", "cost": 0, "type": "attack", "rarity": "special", "owner": "token", "target": "enemy",
		"exhaust": true, "effects": [{"type": "damage", "value": 4, "up": 6}]},
	"x_wound": {"name": "Wound", "cost": -1, "type": "status", "rarity": "special", "owner": "curse", "target": "none",
		"unplayable": true, "effects": []},
	"x_doubt": {"name": "Doubt", "cost": -1, "type": "curse", "rarity": "special", "owner": "curse", "target": "none",
		"unplayable": true, "ethereal_text": "At the end of your turn, gain 1 Weak.", "effects": []},
}

const STATUS_INFO := {
	"strength": {"name": "Strength", "desc": "Attacks deal +X damage.", "buff": true},
	"dexterity": {"name": "Dexterity", "desc": "Block cards give +X Block.", "buff": true},
	"vulnerable": {"name": "Vulnerable", "desc": "Takes 50% more attack damage. Decreases each turn.", "buff": false},
	"weak": {"name": "Weak", "desc": "Deals 25% less attack damage. Decreases each turn.", "buff": false},
	"bleed": {"name": "Bleed", "desc": "Loses X HP at the start of its turn, then Bleed decreases by 1.", "buff": false},
	"thorns": {"name": "Thorns", "desc": "Attackers take X damage.", "buff": true},
	"charge": {"name": "Charge", "desc": "Stored arcane power. Spent by Charge finishers.", "buff": true},
	"bulwark": {"name": "Bulwark", "desc": "At the end of your turn, gain X Block.", "buff": true},
	"steadfast": {"name": "Steadfast", "desc": "Block is not removed at the start of your turn.", "buff": true},
	"rage": {"name": "Rising Fury", "desc": "At the start of each turn, gain X Strength.", "buff": true},
	"serrated": {"name": "Serrated", "desc": "Your attacks apply X Bleed.", "buff": true},
	"phantom": {"name": "Phantom Blades", "desc": "At the start of each turn, add X Knife to your hand.", "buff": true},
	"overflow": {"name": "Overflow", "desc": "At the start of each turn, gain X Charge.", "buff": true},
	"ley": {"name": "Ley Line", "desc": "Gain X extra Energy each turn.", "buff": true},
	"ritual": {"name": "Ritual", "desc": "Gains X Strength at the end of its turn.", "buff": true},
	"regen": {"name": "Regen", "desc": "Heals X HP at the end of its turn.", "buff": true},
}

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
				if e["status"] in ["bulwark", "rage", "serrated", "phantom", "overflow", "ley", "steadfast"]:
					return STATUS_INFO[e["status"]]["desc"].replace("X", str(e["value"])).replace(" 1 Knife", " a Knife")
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
		"damage_block":
			if ctx != null:
				return "Deal damage equal to your Block (%d)." % _dmg(ctx.player.block, ctx, target)
			return "Deal damage equal to your Block."
		"double_block":
			return "Double your Block."
		"double_charge":
			return "Double your Charge."
		"block_charge":
			var s2 := "Gain %d Block per Charge" % int(e["value"])
			if ctx != null:
				s2 += " (%d)" % (int(e["value"]) * ctx.player.get_status("charge"))
			return s2 + "."
		"charge_burst":
			var s3 := "Deal %d + %d per Charge damage" % [int(e["base"]), int(e["per"])]
			if ctx != null:
				var raw: int = int(e["base"]) + int(e["per"]) * ctx.player.get_status("charge")
				s3 = "Deal %d damage" % _dmg(raw, ctx, target if tgt == "enemy" else null)
			if tgt == "all":
				s3 += " to ALL enemies"
			return s3 + ". Spend all Charge."
		"bleed_burst":
			return "Target loses HP equal to %dx its Bleed." % int(e["value"])
	return ""
