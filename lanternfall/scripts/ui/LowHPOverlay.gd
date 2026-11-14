class_name LowHPOverlay
extends Control
## Dramatic "near death" effects while the hero is below 25% HP:
## pulsing blood vignette, creeping veins, heartbeat rhythm (and sound in combat).

const THRESHOLD := 0.25

var danger: float = 0.0        # 0 = safe, 1 = at death's door (smoothed)
var in_combat: bool = false
var _t: float = 0.0
var _beat_clock: float = 0.0
var _flash: float = 0.0
var _was_low := false


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 150


## Pulse shape of a heartbeat: two quick beats then a rest (period ~0.86 s, ~70 bpm).
func heartbeat(t: float) -> float:
	var p := fmod(t, 0.86)
	var a := exp(-pow((p - 0.05) / 0.05, 2.0))
	var b := 0.7 * exp(-pow((p - 0.25) / 0.06, 2.0))
	return a + b


func _process(delta: float) -> void:
	_t += delta
	var frac := _hp_fraction()
	var target := 0.0
	if frac >= 0.0 and frac < THRESHOLD:
		target = clampf(1.0 - frac / THRESHOLD, 0.0, 1.0) * 0.75 + 0.25
	danger = move_toward(danger, target, delta * 1.5)
	var low := target > 0.0
	if low and not _was_low:
		_flash = 1.0
		_jolt()
	_was_low = low
	_flash = maxf(0.0, _flash - delta * 1.6)
	if danger > 0.01 and in_combat:
		var rate := lerpf(0.86, 0.62, danger)   # heart races as HP drops
		_beat_clock += delta
		if _beat_clock >= rate:
			_beat_clock = 0.0
			AudioManager.play("heartbeat", lerpf(-12.0, -4.0, danger), 0.0)
	visible = danger > 0.01 or _flash > 0.0
	if visible:
		queue_redraw()


func _hp_fraction() -> float:
	var m := get_parent()
	while m != null and not m.has_method("show_tooltip"):
		m = m.get_parent()
	if m == null or not GameManager.has_run():
		return -1.0
	var cur = m.current
	in_combat = cur != null and m.current_name == "combat" and cur.get("cm") != null and cur.cm.player != null
	if in_combat:
		if cur.cm.phase == "over":
			return -1.0
		return float(cur.cm.player.hp) / float(maxi(1, cur.cm.player.max_hp))
	if m.current_name in ["menu", "char_select", "victory", "game_over"]:
		return -1.0
	return float(GameManager.run.get("hp", 1)) / float(maxi(1, int(GameManager.run.get("max_hp", 1))))


func _jolt() -> void:
	var m := get_parent()
	if m == null or not SaveManager.profile.get("screen_shake", true):
		return
	var tw := m.create_tween()
	for i in 5:
		tw.tween_property(m, "position", Vector2(randf_range(-10, 10), randf_range(-7, 7)), 0.04)
	tw.tween_property(m, "position", Vector2.ZERO, 0.06)


func _draw() -> void:
	var s := size
	var strength := danger * (1.0 if in_combat else 0.55)
	var pulse := heartbeat(_t * lerpf(1.0, 1.4, danger))
	var a := strength * (0.38 + 0.32 * pulse)
	var red := Color(0.55, 0.0, 0.04)
	# Vignette: several inset frames, alpha falling off towards the centre.
	var bands := 14
	var depth := minf(s.x, s.y) * lerpf(0.18, 0.34, strength)
	for i in bands:
		var f := float(i) / bands
		var inset := depth * f
		var alpha := a * pow(1.0 - f, 1.8)
		var col := Color(red, alpha)
		var w := depth / bands + 1.0
		draw_rect(Rect2(inset, inset, s.x - inset * 2.0, w), col)
		draw_rect(Rect2(inset, s.y - inset - w, s.x - inset * 2.0, w), col)
		draw_rect(Rect2(inset, inset + w, w, s.y - inset * 2.0 - w * 2.0), col)
		draw_rect(Rect2(s.x - inset - w, inset + w, w, s.y - inset * 2.0 - w * 2.0), col)
	# Creeping veins from the corners.
	var vein := Color(0.35, 0.0, 0.03, strength * (0.55 + 0.35 * pulse))
	var corners := [Vector2.ZERO, Vector2(s.x, 0), Vector2(0, s.y), s]
	for ci in corners.size():
		var origin: Vector2 = corners[ci]
		var inward := (s / 2.0 - origin).normalized()
		for k in 4:
			var dir := inward.rotated((k - 1.5) * 0.32)
			var pts := PackedVector2Array([origin])
			var p := origin
			var length := depth * (0.9 + 0.5 * strength) * (0.6 + 0.15 * k)
			for j in 9:
				p += dir * (length / 9.0) + dir.orthogonal() * sin(j * 1.9 + ci * 3.1 + k) * 7.0
				pts.append(p)
			draw_polyline(pts, vein, maxf(1.5, 4.0 - k * 0.6) * (0.7 + strength), true)
	# Flash when first dropping into danger.
	if _flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, s), Color(0.8, 0.0, 0.05, _flash * 0.35))
	# Pulsing warning text in combat
	if in_combat and strength > 0.2:
		var f2 := UI.font()
		var txt := "LOW HEALTH"
		var col2 := Color(1.0, 0.35, 0.35, 0.35 + 0.45 * pulse)
		var ty := s.y * 0.63
		draw_string_outline(f2, Vector2(0, ty), txt, HORIZONTAL_ALIGNMENT_CENTER, s.x, 26, 7, Color(0, 0, 0, 0.6 * col2.a))
		draw_string(f2, Vector2(0, ty), txt, HORIZONTAL_ALIGNMENT_CENTER, s.x, 26, col2)
