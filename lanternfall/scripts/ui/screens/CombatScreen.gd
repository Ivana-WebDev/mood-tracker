extends Screen
## Combat presentation: fanned hand with drag-to-play, enemy targeting, intents, FX.

const PLAY_LINE := 0.58 # fraction of screen height a non-target card must be dragged above

var cm: CombatManager
var world: Control
var fx_layer: Control
var hand_layer: Control
var arrow: TargetArrow
var player_view: CombatantView
var enemy_views: Array = []
var card_views: Dictionary = {} # uid -> CardView
var held: CardView = null
var hovered_enemy: CombatantView = null
var selected: CardView = null
var end_btn: Button
var draw_btn: Button
var discard_btn: Button
var exhaust_btn: Button
var energy_orb: EnergyOrb
var banner: Label
var hint: Label
var _ended := false
var mech_hud: MechanicHUD
var hovered: CardView = null
var pending_potion: int = -1
var _mouse_hover := not DisplayServer.is_touchscreen_available()
var _float_stack: Dictionary = {} # view -> [last_time, count]


func _ready() -> void:
	world = Control.new()
	world.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	world.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(world)

	cm = CombatManager.new()
	cm.speed = 0.5 if SaveManager.profile.get("fast_combat", false) else 1.0
	add_child(cm)
	cm.setup(params.get("enemies", ["gloom_slime"]), params.get("kind", "monster"))

	player_view = CombatantView.new(cm.player, cm)
	player_view.tapped.connect(_on_combatant_tapped)
	world.add_child(player_view)
	for e in cm.enemies:
		var v := CombatantView.new(e, cm)
		v.tapped.connect(_on_combatant_tapped)
		world.add_child(v)
		enemy_views.append(v)

	_build_hud()
	hand_layer = Control.new()
	hand_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hand_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hand_layer)
	arrow = TargetArrow.new()
	add_child(arrow)
	fx_layer = Control.new()
	fx_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fx_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fx_layer)
	banner = UI.label("", 52, Palette.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	banner.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	banner.size = Vector2(800, 80)
	banner.modulate.a = 0.0
	add_child(banner)
	add_top_bar()

	cm.hand_changed.connect(_sync_hand)
	cm.state_changed.connect(_refresh)
	cm.floating_text.connect(_on_float)
	cm.attacked.connect(func(who): _view_for(who).play_lunge())
	cm.was_hit.connect(_on_hit)
	cm.gadget_fired.connect(_on_gadget_fired)
	cm.enemy_died.connect(func(who): _view_for(who).play_death())
	cm.turn_started.connect(_on_turn_started)
	cm.enemy_turn_started.connect(_on_enemy_turn)
	cm.enemy_acting.connect(func(who, mv): _on_float(who, mv, Palette.GOLD))
	cm.combat_ended.connect(_on_combat_ended)
	resized.connect(_layout)
	_layout()
	cm.start()


func _draw() -> void:
	var kind: String = params.get("kind", "monster")
	var accent := Palette.SKILL
	if kind == "elite":
		accent = Palette.NODE_COLORS["elite"]
	elif kind == "boss":
		accent = Palette.NODE_COLORS["boss"]
	elif int(GameManager.run.get("act", 1)) == 2:
		accent = Color("ff8a4f")
	draw_backdrop(accent, 0.56, false, 0.42)


func _build_hud() -> void:
	energy_orb = EnergyOrb.new()
	add_child(energy_orb)
	if cm.mechanic != "":
		mech_hud = MechanicHUD.new(cm)
		add_child(mech_hud)
	end_btn = UI.accent_button("End Turn", _on_end_turn, Palette.GOLD, Vector2(170, 64))
	add_child(end_btn)
	draw_btn = UI.button("Draw 0", func(): _show_pile("draw"), Vector2(140, 50), 17)
	add_child(draw_btn)
	discard_btn = UI.button("Discard 0", func(): _show_pile("discard"), Vector2(150, 50), 17)
	add_child(discard_btn)
	exhaust_btn = UI.button("Exhaust 0", func(): _show_pile("exhaust"), Vector2(150, 40), 15)
	add_child(exhaust_btn)
	hint = UI.label("", 18, Palette.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER)
	add_child(hint)
	if int(GameManager.run["stats"].get("floors", 0)) <= 1:
		if DisplayServer.is_touchscreen_available():
			hint.text = "Drag a card upward to play it  ·  Drag attacks onto an enemy  ·  Or tap a card, then tap a target"
		else:
			hint.text = "Drag cards to play  ·  or click a card, then an enemy  ·  1-9 select  ·  E / Space end turn  ·  F11 fullscreen"


func _layout() -> void:
	var W := size.x
	var H := size.y
	player_view.position = Vector2(W * 0.2 - CombatantView.VIEW_SIZE.x / 2.0, H * 0.13)
	var alive := enemy_views.size()
	var region_l := W * 0.47
	var region_r := W * 0.95
	for i in alive:
		var v: CombatantView = enemy_views[i]
		var cx := region_l + (i + 0.5) * (region_r - region_l) / alive
		v.position = Vector2(cx - CombatantView.VIEW_SIZE.x / 2.0, H * 0.13)
	energy_orb.position = Vector2(26, H - 250)
	if mech_hud:
		if cm.mechanic == "gadgets":
			mech_hud.position = Vector2(player_view.position.x + CombatantView.VIEW_SIZE.x + 6, H * 0.13 + 6)
			mech_hud.size.y = minf(300.0, H * 0.56)
		else:
			mech_hud.position = Vector2(16, TopBar.HEIGHT + 40)
	draw_btn.position = Vector2(16, H - 66)
	discard_btn.position = Vector2(W - 166, H - 66)
	exhaust_btn.position = Vector2(W - 166, H - 112)
	end_btn.position = Vector2(W - 186, H - 196)
	hint.position = Vector2(0, TopBar.HEIGHT + 4)
	hint.size = Vector2(W, 26)
	banner.position = Vector2((W - 800) / 2.0, H * 0.36)
	_layout_hand()
	queue_redraw()


# ------------------------------------------------------------------ hand

func _sync_hand() -> void:
	var hand: Array = cm.deck.hand
	var uids := {}
	for c in hand:
		uids[int(c["uid"])] = true
		if not card_views.has(int(c["uid"])):
			var v := CardView.new(c, cm)
			v.position = draw_btn.position + Vector2(0, -60)
			v.scale = Vector2(0.4, 0.4)
			v.pressed_at.connect(_on_card_pressed)
			v.dragged_to.connect(_on_card_dragged)
			v.released_at.connect(_on_card_released)
			v.tapped.connect(_on_card_tapped)
			v.hover_changed.connect(_on_card_hover)
			hand_layer.add_child(v)
			card_views[int(c["uid"])] = v
	for uid in card_views.keys():
		if not uids.has(uid):
			var v: CardView = card_views[uid]
			card_views.erase(uid)
			if v == held:
				held = null
				arrow.visible = false
			if v == selected:
				selected = null
			_animate_out(v)
	_layout_hand()
	_refresh()


func _animate_out(v: CardView) -> void:
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.z_index = 40
	var tw := v.create_tween()
	if v.get_meta("played", false):
		tw.tween_property(v, "position", Vector2(size.x / 2.0 - CardView.CARD_SIZE.x / 2.0, size.y * 0.3), 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(v, "rotation", 0.0, 0.14)
		tw.parallel().tween_property(v, "scale", Vector2(1.1, 1.1), 0.14)
		tw.tween_interval(0.08)
	var dest := discard_btn.position + Vector2(-20, -80)
	tw.tween_property(v, "position", dest, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(v, "scale", Vector2(0.3, 0.3), 0.22)
	tw.parallel().tween_property(v, "modulate:a", 0.0, 0.22)
	tw.tween_callback(v.queue_free)


func _layout_hand() -> void:
	if cm == null or cm.deck == null:
		return
	var hand: Array = cm.deck.hand
	var n := hand.size()
	if n == 0:
		return
	var W := size.x
	var H := size.y
	var cw := CardView.CARD_SIZE.x
	var ch := CardView.CARD_SIZE.y
	var spread := W * 0.56
	var spacing := minf(cw * 0.92, spread / maxf(1.0, n - 1.0))
	for i in n:
		var uid := int(hand[i]["uid"])
		if not card_views.has(uid):
			continue
		var v: CardView = card_views[uid]
		if v == held:
			continue
		var off := i - (n - 1) / 2.0
		var pos := Vector2(W / 2.0 + off * spacing - cw / 2.0, H - ch - 8.0 + absf(off) * absf(off) * 3.0)
		var rot := deg_to_rad(off * 3.2)
		var sc := Vector2.ONE
		v.z_index = i
		if v == hovered and v != selected and _mouse_hover and held == null:
			pos.y = H - ch - 46
			rot = 0.0
			sc = Vector2(1.12, 1.12)
			v.z_index = 25
		if v == selected:
			pos.y = H - ch - 64
			rot = 0.0
			sc = Vector2(1.18, 1.18)
			v.z_index = 30
		var tw := v.create_tween()
		tw.set_parallel(true)
		tw.tween_property(v, "position", pos, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(v, "rotation", rot, 0.18)
		tw.tween_property(v, "scale", sc, 0.18)


func _on_card_pressed(_v: CardView, _pos: Vector2) -> void:
	pass


func _on_card_hover(v: CardView, on: bool) -> void:
	if not _mouse_hover:
		return
	if on:
		hovered = v
	elif hovered == v:
		hovered = null
	_layout_hand()


## PC shortcuts: 1-9/0 select a card, E/Space end turn, right-click cancels.
func _unhandled_input(event: InputEvent) -> void:
	if _ended or cm == null:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if selected != null:
			selected = null
			_layout_hand()
			_refresh()
			accept_event()
		return
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var k: int = event.keycode
	if k == KEY_E or k == KEY_SPACE:
		_on_end_turn()
		accept_event()
	elif k >= KEY_0 and k <= KEY_9:
		var idx := 9 if k == KEY_0 else k - KEY_1
		var hand: Array = cm.deck.hand
		if idx < hand.size() and card_views.has(int(hand[idx]["uid"])):
			_on_card_tapped(card_views[int(hand[idx]["uid"])])
			accept_event()


func _on_card_dragged(v: CardView, pos: Vector2) -> void:
	if cm.phase != "player" or _ended:
		return
	var local := pos - get_global_rect().position
	if held != v:
		held = v
		selected = null
		v.z_index = 50
		v.rotation = 0.0
		v.scale = Vector2(1.08, 1.08)
		_layout_hand()
	if cm.needs_target(v.inst) and cm.can_play(v.inst):
		var anchor := Vector2(size.x / 2.0 - CardView.CARD_SIZE.x / 2.0, size.y - CardView.CARD_SIZE.y - 50)
		v.position = v.position.lerp(anchor, 0.35)
		arrow.visible = true
		arrow.from = anchor + Vector2(CardView.CARD_SIZE.x / 2.0, 10)
		arrow.to = local
		var e := _enemy_at(pos)
		_set_hovered(e)
		arrow.valid = e != null
		v.refresh(e.c if e != null else null)
	else:
		v.position = local - CardView.CARD_SIZE / 2.0
		v.highlight = local.y < size.y * PLAY_LINE and cm.can_play(v.inst)
		v.queue_redraw()


func _on_card_released(v: CardView, pos: Vector2) -> void:
	if held != v:
		return
	held = null
	arrow.visible = false
	v.highlight = false
	var local := pos - get_global_rect().position
	if cm.needs_target(v.inst):
		var e := _enemy_at(pos)
		_set_hovered(null)
		if e != null:
			_try_play(v, e.c)
		else:
			v.refresh()
	elif local.y < size.y * PLAY_LINE:
		_try_play(v, null)
	_layout_hand()


func _on_card_tapped(v: CardView) -> void:
	if cm.phase != "player" or _ended:
		return
	if selected == v:
		if not cm.needs_target(v.inst):
			_try_play(v, null)
			return
		var alive := cm.alive_enemies()
		if alive.size() == 1:
			_try_play(v, alive[0])
			return
		selected = null
	else:
		selected = v
		if cm.needs_target(v.inst) and cm.can_play(v.inst) and cm.alive_enemies().size() > 1:
			UI.toast(self, "Tap an enemy to target", Palette.GOLD)
	_layout_hand()
	_refresh()


func _try_play(v: CardView, target: Combatant) -> void:
	if not cm.can_play(v.inst):
		var d := cm.card_def(v.inst)
		if d.get("unplayable", false):
			UI.toast(self, "This card can't be played", Palette.BAD)
		else:
			UI.toast(self, "Not enough Energy", Palette.BAD)
		_layout_hand()
		return
	v.set_meta("played", true)
	if not cm.play_card(v.inst, target):
		v.set_meta("played", false)
		_layout_hand()
	if hint.text != "":
		hint.text = ""


func _enemy_at(global_pos: Vector2) -> CombatantView:
	for v in enemy_views:
		var ev: CombatantView = v
		if ev.c.is_alive() and ev.get_global_rect().grow(10).has_point(global_pos):
			return ev
	return null


func _set_hovered(e: CombatantView) -> void:
	if hovered_enemy == e:
		return
	if hovered_enemy != null:
		hovered_enemy.targeted = false
	hovered_enemy = e
	if e != null:
		e.targeted = true


## Called by the potion menu. Targeted potions wait for an enemy tap when several are alive.
func try_use_potion(index: int) -> void:
	if cm.phase != "player" or _ended:
		UI.toast(self, "Wait for your turn", Palette.BAD)
		return
	selected = null
	if cm.potion_needs_target(index) and cm.alive_enemies().size() > 1:
		pending_potion = index
		for v in enemy_views:
			v.targetable = v.c.is_alive()
		UI.toast(self, "Choose a target for the potion", Palette.GOLD)
		return
	cm.use_potion(index)


func _on_combatant_tapped(view: CombatantView) -> void:
	if pending_potion >= 0:
		var idx := pending_potion
		pending_potion = -1
		if not view.c.is_player and view.c.is_alive():
			cm.use_potion(idx, view.c)
		_refresh()
		return
	if selected != null and not view.c.is_player and view.c.is_alive() and cm.needs_target(selected.inst):
		var s := selected
		selected = null
		_try_play(s, view.c)
		_layout_hand()
		return
	UI.tooltip(self, view.c.display_name, view.describe(), view.get_global_rect().get_center() + Vector2(0, -60))


func _show_pile(which: String) -> void:
	var cards: Array = []
	var title := ""
	match which:
		"draw":
			cards = cm.deck.draw_pile.duplicate()
			title = "Draw Pile (random order)"
		"discard":
			cards = cm.deck.discard_pile.duplicate()
			title = "Discard Pile"
		"exhaust":
			cards = cm.deck.exhaust_pile.duplicate()
			title = "Exhausted"
	Overlay.open(self, DeckViewer.new(cards, title))


# ------------------------------------------------------------------ refresh + fx

func _refresh() -> void:
	if cm == null or cm.player == null:
		return
	energy_orb.energy = cm.energy
	energy_orb.max_energy = cm.max_energy
	energy_orb.queue_redraw()
	draw_btn.text = "Draw %d" % cm.deck.draw_pile.size()
	discard_btn.text = "Discard %d" % cm.deck.discard_pile.size()
	exhaust_btn.text = "Exhaust %d" % cm.deck.exhaust_pile.size()
	exhaust_btn.visible = cm.deck.exhaust_pile.size() > 0
	end_btn.disabled = cm.phase != "player"
	if top_bar:
		top_bar.set_hp(maxi(0, cm.player.hp), cm.player.max_hp)
	var target_mode := (selected != null and cm.needs_target(selected.inst)) or pending_potion >= 0
	for v in enemy_views:
		v.targetable = target_mode and v.c.is_alive()
	for uid in card_views:
		var cv: CardView = card_views[uid]
		cv.playable = cm.can_play(cv.inst)
		cv.selected = cv == selected
		if cv != held:
			cv.refresh()


func _view_for(who: Combatant) -> CombatantView:
	if who == cm.player:
		return player_view
	for v in enemy_views:
		if v.c == who:
			return v
	return player_view


func _on_float(who: Combatant, text: String, color: Color) -> void:
	var v := _view_for(who)
	if text.begins_with("+") and color == Palette.BLOCK:
		HitFX.spawn(fx_layer, _fx_at(who), "block", Palette.BLOCK)
	elif text.begins_with("+") and color == Palette.GOOD:
		HitFX.spawn(fx_layer, _fx_at(who), "heal", Palette.GOOD)
	var l := UI.label(text, 26 if text.begins_with("-") else 20, color, HORIZONTAL_ALIGNMENT_CENTER)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("font_outline_size", 6)
	l.size = Vector2(220, 34)
	var now := Time.get_ticks_msec() / 1000.0
	var st: Array = _float_stack.get(v, [0.0, 0])
	var count: int = st[1] + 1 if now - float(st[0]) < 0.35 else 0
	_float_stack[v] = [now, count]
	var base := v.position + Vector2(v.size.x / 2.0 - 110 + randf_range(-16, 16), v.body_center().y - 30.0 + count * 30)
	l.position = base
	fx_layer.add_child(l)
	var tw := l.create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "position:y", base.y - 70, 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.9).set_delay(0.35)
	tw.chain().tween_callback(l.queue_free)


func _fx_at(who: Combatant) -> Vector2:
	var v := _view_for(who)
	return v.position + v.body_center()


func _on_gadget_fired(i: int) -> void:
	if mech_hud == null or i >= cm.gadgets.size():
		return
	var g: Dictionary = cm.gadgets[i]
	var from := mech_hud.position + mech_hud.slot_center(i)
	var col := Color(CardDatabase.GADGETS[g["kind"]]["color"])
	if g["kind"] in ["barrier", "drone"]:
		HitFX.spawn(fx_layer, _fx_at(cm.player), "block" if g["kind"] == "barrier" else "heal", col)
	else:
		var alive := cm.alive_enemies()
		var tgt: Vector2 = _fx_at(alive[0]) if not alive.is_empty() else from + Vector2(300, 0)
		HitFX.spawn(fx_layer, from, "zap", col, tgt)


func _on_hit(who: Combatant) -> void:
	_view_for(who).play_hit()
	HitFX.spawn(fx_layer, _fx_at(who), "slash", Palette.HP.lightened(0.3) if who.is_player else Palette.GOLD)
	if who.is_player and SaveManager.profile.get("screen_shake", true):
		var tw := world.create_tween()
		for i in 4:
			tw.tween_property(world, "position", Vector2(randf_range(-9, 9), randf_range(-6, 6)), 0.035)
		tw.tween_property(world, "position", Vector2.ZERO, 0.05)


func _flash_banner(text: String, color: Color) -> void:
	banner.text = text
	banner.add_theme_color_override("font_color", color)
	var tw := banner.create_tween()
	tw.tween_property(banner, "modulate:a", 1.0, 0.15)
	tw.tween_interval(0.6)
	tw.tween_property(banner, "modulate:a", 0.0, 0.3)


func _on_turn_started(turn: int) -> void:
	_flash_banner("Your Turn" if turn > 1 else "Battle Start", Palette.GOLD)
	_refresh()


func _on_enemy_turn() -> void:
	selected = null
	_flash_banner("Enemy Turn", Palette.BAD)
	_refresh()


func _on_end_turn() -> void:
	if cm.phase != "player":
		return
	selected = null
	cm.end_player_turn()


func _on_combat_ended(victory: bool) -> void:
	if _ended:
		return
	_ended = true
	arrow.visible = false
	end_btn.disabled = true
	for uid in card_views:
		card_views[uid].mouse_filter = Control.MOUSE_FILTER_IGNORE
	if victory:
		_flash_banner("Victory!", Palette.GOOD)
		await get_tree().create_timer(1.1).timeout
		GameManager.on_combat_won(params.get("kind", "monster"), cm.player.hp)
	else:
		_flash_banner("Defeated", Palette.BAD)
		await get_tree().create_timer(1.5).timeout
		GameManager.on_combat_lost()


class EnergyOrb extends Control:
	var energy := 0
	var max_energy := 3
	var _t := 0.0

	func _init() -> void:
		size = Vector2(110, 110)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _process(d: float) -> void:
		_t += d
		queue_redraw()

	func _draw() -> void:
		var c := size / 2.0
		var on := energy > 0
		var glow := 0.5 + 0.5 * sin(_t * 3.0) if on else 0.0
		IconDraw.glow(self, c, 58 + glow * 4.0, Palette.ENERGY if on else Palette.LINE, 5)
		draw_circle(c, 47, IconDraw.OUTLINE)
		draw_circle(c, 44, Palette.ENERGY.darkened(0.55) if on else Palette.BG_2)
		draw_circle(c + Vector2(-3, -3), 38, Palette.ENERGY.darkened(0.25) if on else Palette.PANEL)
		# swirling inner flame
		for i in 6:
			var a := _t * 1.5 + i * TAU / 6.0
			draw_circle(c + Vector2(cos(a), sin(a)) * 22.0, 5.0, Color(Palette.ENERGY.lightened(0.3), 0.35 if on else 0.08))
		draw_arc(c, 44, 0, TAU, 48, Palette.ENERGY if on else Palette.LINE, 3.0, true)
		draw_circle(c + Vector2(-16, -18), 7, Color(1, 1, 1, 0.25))
		IconDraw.icon(self, "bolt", c + Vector2(0, -24), 9, Palette.ENERGY.lightened(0.3))
		draw_string_outline(UI.font(), c + Vector2(-50, 16), "%d/%d" % [energy, max_energy], HORIZONTAL_ALIGNMENT_CENTER, 100, 30, 5, Color(0, 0, 0, 0.7))
		draw_string(UI.font(), c + Vector2(-50, 16), "%d/%d" % [energy, max_energy], HORIZONTAL_ALIGNMENT_CENTER, 100, 30, Palette.TEXT)
