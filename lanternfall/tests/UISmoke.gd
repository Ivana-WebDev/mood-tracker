extends Node
## Drives the real UI through every screen. Optionally saves screenshots.
## Run: godot --path . res://tests/UISmoke.tscn -- --shots=<dir>

var shots_dir := ""
var main: Control


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shots="):
			shots_dir = a.substr(8)
	main = load("res://scenes/Main.tscn").instantiate()
	main.name = "Main"
	get_tree().root.add_child.call_deferred(main)
	await _frames(10)
	await _shot("01_menu")
	GameManager.goto("char_select")
	await _frames(10)
	await _shot("02_char_select")
	GameManager.new_run("clockwright", 77)
	await _frames(10)
	await _shot("03_map")
	# Enter first combat
	var avail: Array = MapManager.available_nodes(GameManager.run)
	GameManager.enter_node(avail[0])
	await _wait(1.2)
	await _shot("04_combat")
	var scr = main.current
	# Play cards through the screen's own handlers.
	for i in 3:
		var hand: Array = scr.cm.deck.hand
		for c in hand:
			if scr.cm.can_play(c):
				var v = scr.card_views[int(c["uid"])]
				var tgt = scr.cm.alive_enemies()[0] if scr.cm.needs_target(c) else null
				scr._try_play(v, tgt)
				break
		await _wait(0.3)
	# Select a card to show the raised state.
	if not scr.cm.deck.hand.is_empty():
		scr._on_card_tapped(scr.card_views[int(scr.cm.deck.hand[0]["uid"])])
	await _wait(0.4)
	await _shot("05_combat_select")
	scr._on_end_turn()
	await _wait(3.5)
	await _shot("06_combat_turn2")
	# Kill everything to reach rewards.
	for e in scr.cm.alive_enemies():
		scr.cm.lose_hp(e, 999)
	await _wait(1.8)
	await _shot("07_reward")
	main.current._pick_card()
	await _frames(8)
	await _shot("08_card_choice")
	main.close_top_overlay()
	await _frames(4)
	GameManager.finish_reward()
	await _frames(8)
	# Other node types with synthetic pending data.
	GameManager.set_pending({"type": "rest"})
	GameManager.goto("rest")
	await _frames(10)
	await _shot("09_rest")
	main.current._smith()
	await _frames(8)
	await _shot("10_upgrade_pick")
	main.close_top_overlay()
	GameManager.run["gold"] = 400
	GameManager.set_pending({"type": "shop", "stock": GameManager._make_shop_stock()})
	GameManager.goto("shop")
	await _frames(10)
	await _shot("11_shop")
	main.current._buy_card(0)
	main.current._buy_relic(0)
	await _frames(4)
	GameManager.set_pending({"type": "event", "event": "smith"})
	GameManager.goto("event", {"event": "smith"})
	await _frames(10)
	await _shot("12_event")
	GameManager.set_pending({"type": "treasure", "gold": 40, "relic": "battle_drum", "opened": false})
	GameManager.goto("treasure")
	await _frames(10)
	main.current._open_chest()
	await _frames(10)
	await _shot("13_treasure")
	GameManager.goto("map")
	await _frames(6)
	main.open_pause()
	await _frames(6)
	await _shot("14_pause")
	main.close_top_overlay()
	Overlay.open(main, RelicChoice.new(["lantern_heart", "twin_crown", "titan_belt"]))
	await _frames(6)
	await _shot("15_boss_relic")
	main.close_top_overlay()
	# Boss combat to check a big enemy layout.
	var p := {"type": "combat", "kind": "boss", "enemies": ["lantern_wyrm"]}
	GameManager.set_pending(p)
	GameManager.goto("combat", p)
	await _wait(1.2)
	await _shot("16_boss")
	var p2 := {"type": "combat", "kind": "monster", "enemies": ["ember_imp", "ember_imp", "ember_imp"]}
	GameManager.set_pending(p2)
	GameManager.goto("combat", p2)
	await _wait(1.2)
	await _shot("17_three_enemies")
	for hero in ["fatebinder", "duskdancer"]:
		GameManager.new_run(hero, 99)
		await _frames(4)
		var pp := {"type": "combat", "kind": "elite", "enemies": ["hex_witch"] if hero == "fatebinder" else ["iron_sentinel"]}
		GameManager.set_pending(pp)
		GameManager.goto("combat", pp)
		await _wait(1.2)
		var sc = main.current
		for k in 2:
			for c in sc.cm.deck.hand:
				if sc.cm.can_play(c):
					var tg = sc.cm.alive_enemies()[0] if sc.cm.needs_target(c) else null
					sc._try_play(sc.card_views[int(c["uid"])], tg)
					break
			await _wait(0.35)
		await _wait(0.3)
		await _shot("19_combat_" + hero)
	GameManager.goto("victory", {"run": GameManager.run.duplicate(true)})
	await _frames(10)
	await _shot("18_victory")
	SaveManager.clear_run()
	print("UI SMOKE DONE")
	get_tree().quit(0)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _wait(t: float) -> void:
	await get_tree().create_timer(t).timeout


func _shot(name: String) -> void:
	if shots_dir == "":
		return
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(shots_dir.path_join(name + ".png"))
