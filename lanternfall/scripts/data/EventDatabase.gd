class_name EventDatabase
## Text events. Each option has "effects" (Array of {type, value...}) and optional "cost" requirements.
## Effect types: gold, hp, max_hp, heal_pct, relic (random of rarity), card_reward, upgrade_random,
## remove_card (opens picker), upgrade_card (opens picker), add_curse, nothing.

const EVENTS := {
	"shrine": {"title": "The Whispering Shrine",
		"text": "A cracked shrine hums with old power. Its voice asks for a sacrifice of blood.",
		"options": [
			{"label": "Offer blood (Lose 9 HP, gain a Relic)", "effects": [{"type": "hp", "value": -9}, {"type": "relic", "value": "common"}], "result": "The shrine drinks deep and leaves a gift at your feet."},
			{"label": "Pray (Heal 25% HP)", "effects": [{"type": "heal_pct", "value": 25}], "result": "Warmth fills your limbs."},
			{"label": "Leave", "effects": [], "result": "You step away from the whispers."},
		]},
	"smith": {"title": "Wandering Smith",
		"text": "A soot-covered smith sits by a portable forge. \"I can sharpen something... or melt it down.\"",
		"options": [
			{"label": "Sharpen (Upgrade a card)", "effects": [{"type": "upgrade_card"}], "result": "The smith hands it back, gleaming."},
			{"label": "Melt down (Remove a card)", "effects": [{"type": "remove_card"}], "result": "Nothing remains but slag."},
			{"label": "Leave", "effects": [], "result": "The smith shrugs."},
		]},
	"fountain": {"title": "Gilded Fountain",
		"text": "Coins glitter at the bottom of a clear fountain. The water smells of iron.",
		"options": [
			{"label": "Grab the coins (Gain 70 Gold, add Doubt curse)", "effects": [{"type": "gold", "value": 70}, {"type": "add_curse", "value": "x_doubt"}], "result": "Your pockets are heavy. So is your conscience."},
			{"label": "Drink (Gain 6 Max HP)", "effects": [{"type": "max_hp", "value": 6}], "result": "You feel sturdier."},
		]},
	"duelist": {"title": "The Retired Duelist",
		"text": "An old duelist offers to teach you a trick — for a price.",
		"options": [
			{"label": "Pay 40 Gold (Choose a card)", "cost_gold": 40, "effects": [{"type": "gold", "value": -40}, {"type": "card_reward", "value": "rare"}], "result": "\"Practice it daily,\" they say."},
			{"label": "Spar (Lose 6 HP, upgrade 2 random cards)", "effects": [{"type": "hp", "value": -6}, {"type": "upgrade_random", "value": 2}], "result": "Bruised, but wiser."},
			{"label": "Leave", "effects": [], "result": "You nod and move on."},
		]},
	"lost_caravan": {"title": "Lost Caravan",
		"text": "An overturned caravan blocks the path. Something rustles in the crates.",
		"options": [
			{"label": "Search the crates (Gain 35 Gold)", "effects": [{"type": "gold", "value": 35}], "result": "Mostly junk, but some coin."},
			{"label": "Help the survivor (Heal 12, gain a card)", "effects": [{"type": "hp", "value": 12}, {"type": "card_reward", "value": "normal"}], "result": "A grateful merchant shares supplies."},
		]},
}
