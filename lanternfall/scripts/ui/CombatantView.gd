class_name CombatantView
extends Control
## Visual for a Combatant: creature art, intent, HP bar, block and statuses.

signal tapped(view: CombatantView)

const VIEW_SIZE := Vector2(240, 330)
const STATUS_ICONS := {
	"strength": "attack", "dexterity": "shield", "vulnerable": "debuff", "weak": "down", "bleed": "fire",
	"thorns": "ring", "ritual": "star", "regen": "heart", "flow": "ribbon", "grace": "ribbon", "rhythm": "bell",
	"spotlight": "star", "amplify": "gear", "factory": "gear", "perpetual": "gear", "lucky": "die",
	"extra_die": "die", "fate_six": "star", "masque": "ribbon", "fortune": "die",
}

var c: Combatant
var cm: CombatManager
var shape: String = "blob"
var color: Color = Color.WHITE
var creature_scale: float = 1.0
var body_offset := Vector2.ZERO
var flash: float = 0.0
var targeted: bool = false
var targetable: bool = false
var _t: float = 0.0
var _shown_hp: float = 0.0
var dying: float = -1.0          # >= 0 while the death dissolve plays (0..1)
var _motes: Array = []


func _init(combatant: Combatant, combat: CombatManager) -> void:
	c = combatant
	cm = combat
	size = VIEW_SIZE
	custom_minimum_size = VIEW_SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP
	if c.is_player:
		var ch: Dictionary = CharacterDatabase.get_character(GameManager.run["character"])
		shape = ch["shape"]
		color = Color(ch["color"])
		creature_scale = 1.15
	else:
		shape = c.data.get("shape", "blob")
		color = Color(c.data.get("color", "ffffff"))
		creature_scale = float(c.data.get("size", 1.0))
	_shown_hp = c.hp
	_t = randf() * 10.0


func _process(delta: float) -> void:
	_t += delta
	_shown_hp = lerpf(_shown_hp, float(c.hp), clampf(delta * 8.0, 0.0, 1.0))
	queue_redraw()


func body_center() -> Vector2:
	# Feet rest just above the name plate regardless of creature size.
	var s := 58.0 * creature_scale
	return Vector2(size.x / 2.0, size.y - 80.0 - s) + body_offset


func _draw() -> void:
	var f := UI.font()
	var bc := body_center()
	var s := 58.0 * creature_scale
	if targeted or targetable:
		var pulse := 0.5 + 0.5 * sin(_t * 6.0)
		var rc := Palette.BAD if targeted else Color(Palette.GOLD, 0.35 + pulse * 0.3)
		draw_arc(bc + Vector2(0, s * 0.1), s * 1.25, 0, TAU, 48, rc, 3.0 if targeted else 2.0, true)
		if targeted:
			for i in 4:
				var a := i * PI / 2.0 + _t
				var p := bc + Vector2(0, s * 0.1) + Vector2(cos(a), sin(a)) * s * 1.25
				draw_circle(p, 5, Palette.BAD)
	_draw_pedestal(bc, s)
	var col := color.lerp(Color.WHITE, flash)
	var low := c.is_player and c.hp > 0 and float(c.hp) / float(maxi(1, c.max_hp)) < LowHPOverlay.THRESHOLD
	if low:
		var hb := 0.5 + 0.5 * sin(_t * 7.0)
		for k in 4:
			draw_circle(bc + Vector2(0, s * 0.2), s * (1.25 + k * 0.18 + hb * 0.1), Color(0.85, 0.05, 0.1, 0.07 + hb * 0.04))
		col = col.lerp(Color(1.0, 0.3, 0.3), 0.18 + 0.12 * hb)
	# Idle breathing: a gentle squash & stretch anchored at the feet.
	var feet := bc + Vector2(0, s)
	var br := sin(_t * 2.4) * 0.018
	var sc := Vector2(1.0 - br, 1.0 + br)
	if dying >= 0.0:
		sc = Vector2(1.0 + dying * 0.25, maxf(0.05, 1.0 - dying * 0.9))
		col = col.lerp(Color(1, 1, 1), dying * 0.6)
		col.a = 1.0 - dying
	draw_set_transform(feet, 0.0, sc)
	IconDraw.creature(self, shape, bc - feet, s, col, _t, 1.0 if c.is_player else -1.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if flash > 0.05:
		draw_circle(bc, s * (0.9 + (0.85 - flash) * 0.6), Color(1, 1, 1, flash * 0.18))
	if dying >= 0.0:
		_draw_motes(bc, s)
		return
	# Intent
	if not c.is_player and c.is_alive() and cm != null and cm.phase != "over":
		_draw_intent(f, Vector2(size.x / 2.0, 26))
	# Name + HP bar
	var bar_w := 176.0
	var bar := Rect2((size.x - bar_w) / 2.0, size.y - 64, bar_w, 20)
	draw_string_outline(f, Vector2(0, bar.position.y - 8), c.display_name, HORIZONTAL_ALIGNMENT_CENTER, size.x, 15, 4, Color(0, 0, 0, 0.7))
	draw_string(f, Vector2(0, bar.position.y - 8), c.display_name, HORIZONTAL_ALIGNMENT_CENTER, size.x, 15, Palette.TEXT_DIM.lightened(0.2))
	draw_style_box(Palette.flat(Color(0, 0, 0, 0.55), 10, IconDraw.OUTLINE, 2), bar.grow(2))
	draw_style_box(Palette.flat(Palette.HP_BG, 9), bar)
	if c.is_player and c.hp > 0 and float(c.hp) / float(maxi(1, c.max_hp)) < LowHPOverlay.THRESHOLD:
		draw_style_box(Palette.flat(Color(0, 0, 0, 0), 12, Color(1.0, 0.2, 0.25, 0.5 + 0.5 * sin(_t * 9.0)), 3), bar.grow(5))
	var frac := clampf(_shown_hp / float(maxi(1, c.max_hp)), 0.0, 1.0)
	var real := clampf(float(c.hp) / float(maxi(1, c.max_hp)), 0.0, 1.0)
	var inner := Rect2(bar.position + Vector2(2, 2), Vector2(bar.size.x - 4, bar.size.y - 4))
	if frac > real:
		draw_rect(Rect2(inner.position, Vector2(inner.size.x * frac, inner.size.y)), Color("ffd9a0", 0.8))
	if real > 0.0:
		var fill_r := Rect2(inner.position, Vector2(maxf(4.0, inner.size.x * real), inner.size.y))
		var top_c := (Palette.HP if c.block == 0 else Palette.BLOCK).lightened(0.15)
		var bot_c := (Palette.HP if c.block == 0 else Palette.BLOCK).darkened(0.3)
		draw_polygon(PackedVector2Array([fill_r.position, Vector2(fill_r.end.x, fill_r.position.y), fill_r.end, Vector2(fill_r.position.x, fill_r.end.y)]),
			PackedColorArray([top_c, top_c, bot_c, bot_c]))
		draw_line(fill_r.position + Vector2(2, 3), Vector2(fill_r.end.x - 2, fill_r.position.y + 3), Color(1, 1, 1, 0.3), 2.0)
	var burn := c.get_status("bleed")
	if burn > 0 and c.hp > 0:
		var bw := inner.size.x * clampf(float(mini(burn, c.hp)) / float(c.max_hp), 0.0, 1.0)
		draw_rect(Rect2(inner.position.x + inner.size.x * real - bw, inner.position.y, bw, inner.size.y), Color("ff8a4f", 0.75))
	for k in range(10, c.max_hp, 10):
		var tx := inner.position.x + inner.size.x * float(k) / c.max_hp
		draw_line(Vector2(tx, inner.position.y + inner.size.y * 0.55), Vector2(tx, inner.end.y), Color(0, 0, 0, 0.35), 1.0)
	draw_string_outline(f, Vector2(bar.position.x, bar.position.y + 16), "%d/%d" % [maxi(0, c.hp), c.max_hp], HORIZONTAL_ALIGNMENT_CENTER, bar.size.x, 14, 3, Color(0, 0, 0, 0.7))
	draw_string(f, Vector2(bar.position.x, bar.position.y + 16), "%d/%d" % [maxi(0, c.hp), c.max_hp], HORIZONTAL_ALIGNMENT_CENTER, bar.size.x, 14, Palette.TEXT)
	if c.block > 0:
		var bpos := bar.position + Vector2(-12, 10)
		IconDraw.icon(self, "shield", bpos + Vector2(1, 2), 19, IconDraw.OUTLINE)
		IconDraw.icon(self, "shield", bpos, 18, Palette.BLOCK)
		draw_string_outline(f, bpos + Vector2(-20, 6), str(c.block), HORIZONTAL_ALIGNMENT_CENTER, 40, 15, 3, Color(0, 0, 0, 0.8))
		draw_string(f, bpos + Vector2(-20, 6), str(c.block), HORIZONTAL_ALIGNMENT_CENTER, 40, 15, Palette.TEXT)
	# Status chips
	var keys := c.statuses.keys()
	var chip_w := 44.0
	var x0 := (size.x - keys.size() * chip_w) / 2.0
	for i in keys.size():
		var k: String = keys[i]
		var info: Dictionary = CardDatabase.STATUS_INFO.get(k, {"buff": true, "name": k})
		var cc := Palette.BUFF if info["buff"] else Palette.DEBUFF
		if k == "bleed":
			cc = Color("ff8a4f")
		var r := Rect2(x0 + i * chip_w + 2, size.y - 38, chip_w - 4, 26)
		draw_style_box(Palette.flat(cc.darkened(0.72), 9, cc, 1), r)
		IconDraw.icon(self, STATUS_ICONS.get(k, "orb"), r.position + Vector2(11, 13), 8, cc)
		draw_string(f, r.position + Vector2(18, 18), str(c.statuses[k]), HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 20, 13, Palette.TEXT)


func _draw_intent(f: Font, at: Vector2) -> void:
	var info := cm.intent_info(c)
	var kinds: Array = info["kinds"]
	var bob := sin(_t * 3.0) * 3.0
	var has_attack := "attack" in kinds
	var n := kinds.size()
	var x := at.x - (n - 1) * 24.0
	var dmg_total := int(info.get("damage", 0)) * maxi(1, int(info.get("times", 1)))
	for k in kinds:
		var p := Vector2(x, at.y + 4 + bob)
		var kc: Color = {"attack": Palette.ATTACK, "defend": Palette.BLOCK, "buff": Palette.BUFF, "debuff": Palette.DEBUFF}.get(k, Palette.TEXT_DIM)
		# Hexagonal badge with glow.
		var hex := PackedVector2Array()
		for i in 6:
			var a2 := PI / 6.0 + i * PI / 3.0
			hex.append(p + Vector2(cos(a2), sin(a2)) * 22.0)
		var pulse := 0.5 + 0.5 * sin(_t * 4.0)
		if k == "attack":
			for g in 3:
				draw_circle(p, 26.0 + g * 5.0 + pulse * 3.0, Color(kc, 0.07 + (0.05 if dmg_total >= 15 else 0.0)))
		draw_colored_polygon(hex, Color(Palette.BG_2, 0.92))
		var inner := PackedVector2Array()
		for q in hex:
			inner.append(p + (q - p) * 0.82)
		var cols := PackedColorArray()
		for q in inner:
			cols.append(kc.darkened(0.45).lerp(kc.darkened(0.75), clampf((q.y - p.y + 18.0) / 36.0, 0.0, 1.0)))
		draw_polygon(inner, cols)
		var hc := hex.duplicate()
		hc.append(hex[0])
		draw_polyline(hc, IconDraw.OUTLINE, 4.0, true)
		draw_polyline(hc, kc.lightened(0.15), 2.0, true)
		match k:
			"attack":
				var sword_c := kc.lerp(Color("ffe08a"), clampf(float(dmg_total - 8) / 20.0, 0.0, 0.6))
				IconDraw.icon(self, "attack", p + Vector2(0, -2), 15, sword_c)
			"defend":
				IconDraw.icon(self, "shield", p, 13, kc.lightened(0.2))
			"buff":
				IconDraw.icon(self, "buff", p, 13, kc.lightened(0.2))
			"debuff":
				IconDraw.icon(self, "debuff", p, 13, kc.lightened(0.2))
		x += 48.0
	if has_attack:
		var txt := str(info["damage"])
		if int(info["times"]) > 1:
			txt += "x%d" % int(info["times"])
		var tp := Vector2(at.x - 60, at.y + 46 + bob)
		var tc := Palette.TEXT if dmg_total < 15 else Color("ffb38a")
		draw_string_outline(f, tp, txt, HORIZONTAL_ALIGNMENT_CENTER, 120, 20, 5, Color(0, 0, 0, 0.85))
		draw_string(f, tp, txt, HORIZONTAL_ALIGNMENT_CENTER, 120, 20, tc)


## Glowing rune circle the combatant stands on.
func _draw_pedestal(bc: Vector2, s: float) -> void:
	var feet := bc + Vector2(0, s * 1.0)
	var rc := color.lerp(Palette.GOLD, 0.35) if c.is_player else color.lerp(Palette.BAD, 0.25)
	var rx := s * 0.95
	var ry := s * 0.2
	var fade := 1.0 - maxf(dying, 0.0)
	draw_colored_polygon(IconDraw.ellipse_pts(feet, rx * 1.15, ry * 1.25, 32), Color(rc, 0.07 * fade))
	draw_polyline(_ellipse_closed(feet, rx, ry), Color(rc, 0.45 * fade), 2.0, true)
	draw_polyline(_ellipse_closed(feet, rx * 0.78, ry * 0.78), Color(rc, 0.22 * fade), 1.0, true)
	for i in 8:
		var a := _t * (0.5 if c.is_player else -0.5) + i * TAU / 8.0
		var p := feet + Vector2(cos(a) * rx * 0.89, sin(a) * ry * 0.89)
		var w := 3.0 + (i % 2) * 2.0
		draw_line(p - Vector2(w, 0), p + Vector2(w, 0), Color(rc, (0.25 + 0.35 * (0.5 + 0.5 * sin(a))) * fade), 1.5, true)
	# Rising light motes.
	for i in 4:
		var ph := fmod(_t * 0.35 + i * 0.25, 1.0)
		var a2 := i * 1.7 + _t * 0.2
		draw_circle(feet + Vector2(cos(a2) * rx * 0.7, -ph * s * 0.9), 1.6, Color(rc, 0.5 * (1.0 - ph) * fade))


func _ellipse_closed(cpt: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var pts := IconDraw.ellipse_pts(cpt, rx, ry, 40)
	pts.append(pts[0])
	return pts


func _draw_motes(bc: Vector2, s: float) -> void:
	for m in _motes:
		var age: float = dying * float(m["speed"])
		var p: Vector2 = bc + (m["off"] as Vector2) * s + Vector2(sin(age * 6.0 + float(m["ph"])) * 6.0, -age * s * 1.6)
		var a := clampf(1.0 - dying, 0.0, 1.0)
		draw_circle(p, float(m["r"]) * (1.0 - dying * 0.5) * 2.2, Color(color.lightened(0.4), 0.12 * a))
		draw_circle(p, float(m["r"]), Color(color.lightened(0.5), 0.9 * a))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		tapped.emit(self)
		accept_event()


func describe() -> String:
	var lines: PackedStringArray = []
	if not c.is_player and cm != null:
		var info := cm.intent_info(c)
		var intent := "Intends: %s" % info["name"]
		if "attack" in info["kinds"]:
			intent += " (%d damage%s)" % [info["damage"], "" if int(info["times"]) <= 1 else " x%d" % int(info["times"])]
		lines.append(intent)
	if c.block > 0:
		lines.append("Block %d: absorbs damage this round." % c.block)
	for k in c.statuses:
		var info2: Dictionary = CardDatabase.STATUS_INFO.get(k, {"name": k, "desc": ""})
		lines.append("%s %d: %s" % [info2["name"], c.statuses[k], info2["desc"]])
	if lines.is_empty():
		lines.append("No effects.")
	return "\n".join(lines)


func play_lunge() -> void:
	var dir := 1.0 if c.is_player else -1.0
	var tw := create_tween()
	tw.tween_property(self, "body_offset", Vector2(36 * dir, -6), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "body_offset", Vector2.ZERO, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)


func play_hit() -> void:
	flash = 0.85
	var tw := create_tween()
	tw.tween_property(self, "flash", 0.0, 0.25)
	var tw2 := create_tween()
	var dir := -1.0 if c.is_player else 1.0
	tw2.tween_property(self, "body_offset", Vector2(14 * dir, 0), 0.05)
	tw2.tween_property(self, "body_offset", Vector2(-8 * dir, 0), 0.05)
	tw2.tween_property(self, "body_offset", Vector2.ZERO, 0.08)


func play_death() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_motes.clear()
	for i in 34:
		_motes.append({"off": Vector2(randf_range(-0.8, 0.8), randf_range(-1.1, 0.9)), "speed": randf_range(0.6, 1.4),
			"r": randf_range(1.5, 3.8), "ph": randf() * TAU})
	dying = 0.0
	var tw := create_tween()
	tw.tween_property(self, "dying", 1.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "modulate:a", 0.0, 0.15)
