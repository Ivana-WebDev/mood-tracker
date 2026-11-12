extends Node
## Plays through menus and combat using only simulated mouse events (no direct handler calls).

var main: Control
var fails := 0


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shots="):
			shots_dir = a.substr(8)
	main = load("res://scenes/Main.tscn").instantiate()
	main.name = "Main"
	get_tree().root.add_child.call_deferred(main)
	await _frames(10)
	# Title -> New Run (click the button)
	await _click_button("New Run")
	await _frames(10)
	_check(main.current_name == "char_select", "clicking New Run opens hero select")
	await _click_button("Embark")
	await _frames(10)
	_check(main.current_name == "map", "clicking Embark starts a run on the map")
	# Click an available map node
	var mv = main.current.map_view
	var nid: int = MapManager.available_nodes(GameManager.run)[0]
	var p: Vector2 = mv.get_global_rect().position + mv.node_pos(GameManager.run["map"]["nodes"][nid])
	await _click(p)
	await _wait(1.3)
	_check(main.current_name == "combat", "clicking a map node starts combat")
	var scr = main.current
	var cm: CombatManager = scr.cm
	# Hover lifts a card
	var first: CardView = scr.card_views[int(cm.deck.hand[0]["uid"])]
	var y0 := first.position.y
	await _move(first.get_global_rect().get_center())
	await _wait(0.3)
	_check(first.position.y < y0 - 10, "hovering a card lifts it")
	# Drag an attack onto an enemy
	var atk := _find_card(cm, true)
	var e: Combatant = cm.alive_enemies()[0]
	var hp0 := e.hp
	var en0 := cm.energy
	var ev: CombatantView = scr.enemy_views[0]
	await _drag(scr.card_views[int(atk["uid"])].get_global_rect().get_center(), ev.get_global_rect().get_center())
	await _wait(0.4)
	_check(cm.energy < en0 and (e.hp < hp0 or e.block > 0 or not e.is_alive()), "dragging an attack onto an enemy plays it")
	# Click a skill, then click it again to play
	var sk := _find_card(cm, false)
	if not sk.is_empty():
		var en1 := cm.energy
		var v: CardView = scr.card_views[int(sk["uid"])]
		await _click(v.get_global_rect().get_center())
		await _wait(0.3)
		_check(scr.selected == v, "clicking a card selects it")
		await _click(v.get_global_rect().get_center())
		await _wait(0.4)
		_check(cm.energy < en1, "clicking a selected skill again plays it")
	# Click attack, then click enemy
	if cm.energy > 0 and cm.alive_enemies().size() > 0:
		var atk2 := _find_card(cm, true)
		if not atk2.is_empty():
			var en2 := cm.energy
			await _click(scr.card_views[int(atk2["uid"])].get_global_rect().get_center())
			await _wait(0.3)
			var tgt: CombatantView = null
			for vv in scr.enemy_views:
				if vv.c.is_alive():
					tgt = vv
					break
			await _click(tgt.get_global_rect().get_center())
			await _wait(0.4)
			_check(cm.energy < en2, "click card, then click enemy plays it")
	# Potion: give one, click the slot, click Drink
	GameManager.add_potion("iron_tonic")
	await _frames(4)
	var blk0 := cm.player.block
	var slot := _find_potion_slot(0)
	await _click(slot.get_global_rect().get_center())
	await _frames(6)
	_check(main.has_overlay(), "clicking a potion opens the potion menu")
	await _click_button("Drink")
	await _wait(0.3)
	_check(cm.player.block >= blk0 + 12 and GameManager.potions().is_empty(), "clicking Drink uses the potion")
	# Targeted potion with several enemies: Drink, then click an enemy
	if cm.alive_enemies().size() > 1:
		GameManager.add_potion("fire_flask")
		await _frames(4)
		var tgt2: CombatantView = null
		for vv in scr.enemy_views:
			if vv.c.is_alive():
				tgt2 = vv
		var hp2 := tgt2.c.hp + tgt2.c.block
		await _click(_find_potion_slot(0).get_global_rect().get_center())
		await _frames(6)
		await _click_button("Drink")
		await _wait(0.3)
		await _click(tgt2.get_global_rect().get_center())
		await _wait(0.3)
		_check(tgt2.c.hp + tgt2.c.block < hp2 and GameManager.potions().is_empty(), "targeted potion hits the clicked enemy")
	# Pause menu must sit above the hand of cards and receive clicks
	await _click_button("Menu")
	await _frames(8)
	await _shot("pause_over_cards")
	var resume := _find_button(main, "Resume")
	_check(resume != null, "pause menu opens in combat")
	var on_top := true
	if resume != null:
		var rc := resume.get_global_rect().get_center()
		for uid in scr.card_views:
			var cv: CardView = scr.card_views[uid]
			if cv.get_global_rect().has_point(rc) and cv.z_index + 0 >= 200:
				on_top = false
		var en_before := cm.energy
		await _click(rc)
		await _frames(6)
		on_top = on_top and not main.has_overlay() and cm.energy == en_before
	_check(on_top, "pause menu draws above cards and Resume click reaches it")
	# End turn button
	var t0 := cm.turn
	await _click_button("End Turn")
	await _wait(4.0)
	_check(cm.turn > t0 or cm.phase == "over", "clicking End Turn runs the enemy turn")
	# Deck button opens viewer, clicking backdrop closes it
	await _click_button("Deck 10")
	await _frames(6)
	_check(main.has_overlay(), "clicking Deck opens the deck viewer")
	await _click_button("Close")
	await _frames(6)
	_check(not main.has_overlay(), "clicking Close closes it")
	# Map button from a non-map screen (event)
	GameManager.set_pending({"type": "event", "event": "smith"})
	GameManager.goto("event", {"event": "smith"})
	await _frames(10)
	await _click_button("Map")
	await _frames(8)
	await _shot("map_overlay")
	_check(main.has_overlay() and main.current_name == "event", "Map button opens the map over the event")
	await _click_button("Close")
	await _frames(6)
	_check(not main.has_overlay(), "map overlay closes")
	print("MOUSE TEST DONE fails=%d" % fails)
	SaveManager.clear_run()
	get_tree().quit(1 if fails > 0 else 0)


func _find_potion_slot(i: int) -> PotionIcon:
	var all: Array = main.find_children("*", "PotionIcon", true, false)
	for p in all:
		if p.index == i and p.is_visible_in_tree() and not p.is_queued_for_deletion():
			return p
	return null


var shots_dir := ""


func _shot(name: String) -> void:
	if shots_dir == "":
		return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(shots_dir.path_join(name + ".png"))


func _find_card(cm: CombatManager, attack: bool) -> Dictionary:
	for c in cm.deck.hand:
		var d := cm.card_def(c)
		if cm.can_play(c) and (d["type"] == "attack") == attack and cm.needs_target(c) == attack:
			return c
	return {}


func _check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		fails += 1


func _find_button(node: Node, text: String) -> Button:
	for c in node.get_children():
		if c is Button and c.text.begins_with(text) and c.is_visible_in_tree() and not c.is_queued_for_deletion():
			return c
		var r := _find_button(c, text)
		if r != null:
			return r
	return null


func _click_button(text: String) -> void:
	var b := _find_button(main, text)
	if b == null:
		_check(false, "button '%s' exists" % text)
		return
	await _click(b.get_global_rect().get_center())


func _move(p: Vector2) -> void:
	var m := InputEventMouseMotion.new()
	m.position = p
	m.global_position = p
	Input.parse_input_event(m)
	await _frames(2)


func _button(p: Vector2, pressed: bool) -> void:
	var b := InputEventMouseButton.new()
	b.button_index = MOUSE_BUTTON_LEFT
	b.pressed = pressed
	b.position = p
	b.global_position = p
	b.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	Input.parse_input_event(b)
	await _frames(2)


func _click(p: Vector2) -> void:
	await _move(p)
	await _button(p, true)
	await _button(p, false)


func _drag(a: Vector2, b: Vector2) -> void:
	await _move(a)
	await _button(a, true)
	for i in range(1, 13):
		var p := a.lerp(b, i / 12.0)
		var m := InputEventMouseMotion.new()
		m.position = p
		m.global_position = p
		m.button_mask = MOUSE_BUTTON_MASK_LEFT
		m.relative = (b - a) / 12.0
		Input.parse_input_event(m)
		await _frames(1)
	await _button(b, false)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _wait(t: float) -> void:
	await get_tree().create_timer(t).timeout
