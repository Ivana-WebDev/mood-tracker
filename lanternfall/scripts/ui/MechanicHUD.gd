class_name MechanicHUD
extends Control
## Hero-specific combat HUD: Gadget Bay (Clockwright), Dice Tray (Fatebinder), Flow Meter (Duskdancer).

signal slot_tapped(index: int)

var cm: CombatManager
var mode: String = ""
var _t := 0.0
var _flash: Array = [0.0, 0.0, 0.0]
var _roll_anim: float = 0.0
var _shown_dice: Array = []
var _flow_pulse: float = 0.0


func _init(combat: CombatManager) -> void:
	cm = combat
	mode = combat.mechanic
	mouse_filter = Control.MOUSE_FILTER_STOP
	match mode:
		"gadgets": size = Vector2(96, 300)
		"dice": size = Vector2(250, 96)
		"flow": size = Vector2(250, 86)


func _ready() -> void:
	cm.gadget_fired.connect(func(i):
		if i < _flash.size():
			_flash[i] = 1.0)
	cm.dice_changed.connect(_on_dice)
	cm.state_changed.connect(func(): queue_redraw())
	cm.flow_broken.connect(func(): _flow_pulse = -1.0)


func _on_dice() -> void:
	if cm.dice.size() >= _shown_dice.size() and cm.dice != _shown_dice:
		_roll_anim = 1.0
	_shown_dice = cm.dice.duplicate()


func _process(delta: float) -> void:
	_t += delta
	for i in _flash.size():
		_flash[i] = maxf(0.0, _flash[i] - delta * 2.5)
	_roll_anim = maxf(0.0, _roll_anim - delta * 3.0)
	_flow_pulse = move_toward(_flow_pulse, 0.0, delta * 2.0)
	queue_redraw()


func slot_center(i: int) -> Vector2:
	return Vector2(size.x / 2.0, 50 + i * 100)


func _draw() -> void:
	match mode:
		"gadgets": _draw_gadgets()
		"dice": _draw_dice()
		"flow": _draw_flow()


func _panel(r: Rect2, accent: Color) -> void:
	draw_style_box(Palette.flat(Color(Palette.BG_2, 0.88), 14, Color(accent, 0.6), 2), r)


func _draw_gadgets() -> void:
	var f := UI.font()
	for i in CombatManager.MAX_GADGETS:
		var c := slot_center(i)
		var r := Rect2(c - Vector2(44, 44), Vector2(88, 88))
		if i < cm.gadgets.size():
			var g: Dictionary = cm.gadgets[i]
			var gd: Dictionary = CardDatabase.GADGETS[g["kind"]]
			var col := Color(gd["color"])
			if _flash[i] > 0.0:
				draw_circle(c, 52 + _flash[i] * 10, Color(col, 0.25 * _flash[i]))
			_panel(r, col)
			# machine base + rotating gear behind the icon
			IconDraw.gear(self, c + Vector2(22, -22), 13, 10, 7, col.darkened(0.4), _t * 2.0)
			IconDraw.icon(self, gd["icon"], c + Vector2(0, -4), 22 + _flash[i] * 6, col.lerp(Color.WHITE, _flash[i] * 0.6))
			draw_string(f, c + Vector2(-40, 38), str(g["power"]), HORIZONTAL_ALIGNMENT_LEFT, 40, 20, Palette.TEXT)
			# turns pips
			var turns := int(g["turns"])
			for k in mini(turns, 6):
				draw_circle(c + Vector2(34 - k * 9, 32), 3.2, col)
			if cm.player.get_status("perpetual") > 0:
				draw_string(f, c + Vector2(0, 38), "∞", HORIZONTAL_ALIGNMENT_LEFT, 40, 18, col)
		else:
			_panel(r, Palette.LINE)
			draw_arc(c, 18, 0, TAU, 24, Color(Palette.LINE, 0.8), 2.0, true)
			draw_string(f, c + Vector2(-44, 6), "empty", HORIZONTAL_ALIGNMENT_CENTER, 88, 13, Palette.TEXT_DIM.darkened(0.3))


func _draw_dice() -> void:
	var f := UI.font()
	_panel(Rect2(Vector2.ZERO, size), Color("b18cff"))
	draw_string(f, Vector2(12, 20), "FATE DICE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.TEXT_DIM)
	if cm.dice.is_empty():
		draw_string(f, Vector2(12, 62), "No dice left", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Palette.TEXT_DIM)
		return
	var n := cm.dice.size()
	var gap := minf(54.0, (size.x - 24) / n)
	var hi := cm._die_index("high")
	var lo := cm._die_index("low")
	for i in n:
		var v := int(cm.dice[i])
		var p := Vector2(12 + gap * (i + 0.5), 58)
		var rot := _roll_anim * 6.0 * (1.0 if i % 2 == 0 else -1.0) + sin(_t * 2.0 + i) * 0.04
		var shown := v if _roll_anim < 0.35 else 1 + int(_t * 20.0 + i * 3) % 6
		var col := Color("f5f1ff")
		if v >= 6:
			col = Color("ffe29a")
		IconDraw.die(self, p + Vector2(0, -_roll_anim * 10.0), minf(20.0, gap * 0.4), shown, col, rot)
		if i == hi and n > 1:
			draw_string(f, p + Vector2(-20, 34), "HI", HORIZONTAL_ALIGNMENT_CENTER, 40, 11, Palette.GOLD)
		elif i == lo and n > 1:
			draw_string(f, p + Vector2(-20, 34), "LO", HORIZONTAL_ALIGNMENT_CENTER, 40, 11, Palette.TEXT_DIM)
	draw_string(f, Vector2(size.x - 82, 20), "total %d" % cm.dice_total(), HORIZONTAL_ALIGNMENT_RIGHT, 70, 13, Palette.TEXT_DIM)


func _draw_flow() -> void:
	var f := UI.font()
	var teal := Color("3fd6b4")
	_panel(Rect2(Vector2.ZERO, size), teal if _flow_pulse >= 0.0 else Palette.BAD)
	var flow := cm.player.get_status("flow")
	draw_string(f, Vector2(12, 22), "FLOW", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Palette.TEXT_DIM)
	draw_string(f, Vector2(60, 22), "+%d" % cm.flow_bonus(), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, teal)
	for i in CardDatabase.FLOW_MAX:
		var p := Vector2(24 + i * 36, 48)
		var on := i < flow
		var col := teal.lerp(Palette.GOLD, float(i) / CardDatabase.FLOW_MAX) if on else Palette.LINE
		var pts := PackedVector2Array([p + Vector2(-12, 0), p + Vector2(0, -12), p + Vector2(12, 0), p + Vector2(0, 12)])
		if on:
			draw_circle(p, 14 + sin(_t * 4.0 + i) * 2.0, Color(col, 0.2))
		IconDraw.fill(self, pts, col if on else Color(Palette.BG, 0.8), 1.5, on)
	var nxt := "Play any card"
	if cm.last_type != "":
		var opts := ["attack", "skill", "power"].filter(func(x): return x != cm.last_type)
		nxt = "Last: %s  ->  next: %s" % [cm.last_type.capitalize(), " / ".join(opts.map(func(x): return x.capitalize()))]
	draw_string(f, Vector2(12, 78), nxt, HORIZONTAL_ALIGNMENT_LEFT, size.x - 20, 13, Palette.TEXT_DIM)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		var title := ""
		var body := ""
		match mode:
			"gadgets":
				title = "Gadgets"
				body = "Up to 3 Gadgets. Each fires at the end of your turn, then loses a turn. Deploying a 4th pushes out the oldest (it fires once).\n"
				for g in cm.gadgets:
					var gd: Dictionary = CardDatabase.GADGETS[g["kind"]]
					body += "\n%s: %s, %d turns left" % [gd["name"], gd["desc"] % int(g["power"]), int(g["turns"])]
			"dice":
				title = "Fate Dice"
				body = "You roll 3 dice at the start of each turn. Cards spend your highest or lowest die, reroll or reshape them. Unspent dice are lost at end of turn."
			"flow":
				title = "Flow"
				body = CardDatabase.STATUS_INFO["flow"]["desc"].replace("+X", "+1 per Flow:") + "\nMax %d." % CardDatabase.FLOW_MAX
		UI.tooltip(self, title, body, get_global_rect().get_center())
		accept_event()
