class_name Combatant
extends RefCounted
## A participant in combat (the player or an enemy).

var display_name: String = ""
var max_hp: int = 1
var hp: int = 1
var block: int = 0
var statuses: Dictionary = {}
var is_player: bool = false

# Enemy-only data
var enemy_id: String = ""
var data: Dictionary = {}
var move_index: int = -1
var intent: Dictionary = {}
var history: Array = []
var slot: int = 0


func is_alive() -> bool:
	return hp > 0


func get_status(s: String) -> int:
	return int(statuses.get(s, 0))


func add_status(s: String, amount: int) -> void:
	var v := get_status(s) + amount
	if v == 0:
		statuses.erase(s)
	else:
		statuses[s] = v


func set_status(s: String, amount: int) -> void:
	if amount == 0:
		statuses.erase(s)
	else:
		statuses[s] = amount


func heal(amount: int) -> int:
	var before := hp
	hp = mini(max_hp, hp + maxi(0, amount))
	return hp - before


static func make_enemy(id: String, rng: RandomNumberGenerator, slot_index: int) -> Combatant:
	var c := Combatant.new()
	var d: Dictionary = EnemyDatabase.get_enemy(id)
	c.enemy_id = id
	c.data = d
	c.display_name = d["name"]
	var hp_range: Array = d["hp"]
	c.max_hp = rng.randi_range(int(hp_range[0]), int(hp_range[1]))
	c.hp = c.max_hp
	c.slot = slot_index
	var st: Dictionary = d.get("start_status", {})
	for k in st:
		c.statuses[k] = int(st[k])
	return c
