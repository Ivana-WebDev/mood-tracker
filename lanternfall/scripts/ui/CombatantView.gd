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
	var col := color.lerp(Color.WHITE, flash)
	var low := c.is_player and c.hp > 0 and float(c.hp) / float(maxi(1, c.max_hp)) < LowHPOverlay.THRESHOLD
	if low:
		var hb := 0.5 + 0.5 * sin(_t * 7.0)
		for k in 4:
			draw_circle(bc + Vector2(0, s * 0.2), s * (1.25 + k * 0.18 + hb * 0.1), Color(0.85, 0.05, 0.1, 0.07 + hb * 0.04))
		col = col.lerp(Color(1.0, 0.3, 0.3), 0.18 + 0.12 * hb)
	IconDraw.creature(self, shape, bc, s, col, _t, 1.0 if c.is_player else -1.0)
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
	var x := at.x - (kinds.size() - 1) * 22.0
	var bob := sin(_t * 3.0) * 3.0
	var pill_w := kinds.size() * 44.0 + 12.0
	var has_attack := "attack" in kinds
	var pill := Rect2(at.x - pill_w / 2.0, at.y - 22 + bob, pill_w, 64 if has_attack else 44)
	draw_style_box(Palette.flat(Color(Palette.BG_2, 0.85), 14, Color(Palette.ATTACK if has_attack else Palette.LINE, 0.7), 2), pill)
	for k in kinds:
		var p := Vector2(x, at.y + bob)
		match k:
			"attack":
				IconDraw.icon(self, "attack", p, 16, Palette.ATTACK)
				var txt := str(info["damage"])
				if int(info["times"]) > 1:
					txt += "x%d" % int(info["times"])
				draw_string_outline(f, p + Vector2(-40, 34), txt, HORIZONTAL_ALIGNMENT_CENTER, 80, 18, 4, Color(0, 0, 0, 0.8))
				draw_string(f, p + Vector2(-40, 34), txt, HORIZONTAL_ALIGNMENT_CENTER, 80, 18, Palette.TEXT)
			"defend":
				IconDraw.icon(self, "shield", p, 14, Palette.BLOCK)
			"buff":
				IconDraw.icon(self, "buff", p, 14, Palette.BUFF)
			"debuff":
				IconDraw.icon(self, "debuff", p, 14, Palette.DEBUFF)
		x += 44.0


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
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "modulate:a", 0.0, 0.6)
	tw.tween_property(self, "body_offset", Vector2(0, 30), 0.6)
