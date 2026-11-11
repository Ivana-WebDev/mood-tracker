class_name DeckManager
extends RefCounted
## Owns the four card piles during a combat. Card instances are Dictionaries: {uid, id, upgraded}.

const HAND_LIMIT := 10

var draw_pile: Array = []
var hand: Array = []
var discard_pile: Array = []
var exhaust_pile: Array = []
var rng: RandomNumberGenerator


func setup(deck: Array, random: RandomNumberGenerator) -> void:
	rng = random
	draw_pile.clear()
	hand.clear()
	discard_pile.clear()
	exhaust_pile.clear()
	for c in deck:
		draw_pile.append(c.duplicate())
	shuffle(draw_pile)


func shuffle(arr: Array) -> void:
	# Fisher-Yates with the run RNG so seeds are reproducible.
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp


## Draws up to n cards. Returns the cards actually drawn.
func draw(n: int) -> Array:
	var drawn: Array = []
	for i in n:
		if hand.size() >= HAND_LIMIT:
			break
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break
			draw_pile = discard_pile.duplicate()
			discard_pile.clear()
			shuffle(draw_pile)
		var c = draw_pile.pop_back()
		hand.append(c)
		drawn.append(c)
	return drawn


func remove_from_hand(card: Dictionary) -> void:
	for i in hand.size():
		if hand[i]["uid"] == card["uid"]:
			hand.remove_at(i)
			return


func discard(card: Dictionary) -> void:
	remove_from_hand(card)
	discard_pile.append(card)


func exhaust(card: Dictionary) -> void:
	remove_from_hand(card)
	exhaust_pile.append(card)


func discard_hand() -> void:
	for c in hand:
		discard_pile.append(c)
	hand.clear()


func add_to_hand(card: Dictionary) -> bool:
	if hand.size() >= HAND_LIMIT:
		discard_pile.append(card)
		return false
	hand.append(card)
	return true
