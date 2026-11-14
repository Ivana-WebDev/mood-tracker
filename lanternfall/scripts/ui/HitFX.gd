class_name HitFX
extends Control
## One-shot combat effect drawn procedurally: slash, sparks, block ring, heal, zap.

var kind: String = "slash"
var color: Color = Color.WHITE
var life: float = 0.0
var duration: float = 0.45
var target_pos: Vector2 = Vector2.ZERO
var _sparks: Array = []


static func spawn(parent: Control, at: Vector2, fx_kind: String, col: Color, to: Vector2 = Vector2.ZERO) -> HitFX:
	var fx := HitFX.new()
	fx.kind = fx_kind
	fx.color = col
	fx.position = at
	fx.target_pos = to - at
	parent.add_child(fx)
	return fx


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 70
	var n := 14 if kind == "slash" else 10
	for i in n:
		var a := randf() * TAU
		_sparks.append({"dir": Vector2(cos(a), sin(a)), "speed": randf_range(120, 320), "size": randf_range(2.0, 4.5)})
	if kind == "zap":
		duration = 0.3
	elif kind == "heal":
		duration = 0.8
	elif kind == "burst":
		duration = 0.5


func _process(delta: float) -> void:
	life += delta
	if life >= duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var u := life / duration
	var a := 1.0 - u
	match kind:
		"slash":
			var ext := 70.0 * minf(1.0, u * 3.0)
			for k in 3:
				var off := Vector2(0, (k - 1) * 14.0)
				var p0 := off + Vector2(-ext, -ext * 0.6)
				var p1 := off + Vector2(ext, ext * 0.6)
				draw_line(p0, p1, Color(1, 1, 1, a * (0.9 - k * 0.2)), (6.0 - k * 1.5) * a + 1.0, true)
			# Impact flash + crescent arc.
			if u < 0.35:
				draw_circle(Vector2.ZERO, 46.0 * (1.0 - u * 2.0), Color(1, 1, 1, 0.25 * (1.0 - u * 2.8)))
			draw_arc(Vector2.ZERO, 50.0 + u * 20.0, -PI * 0.85, -PI * 0.15, 24, Color(color, a * 0.7), 5.0 * a + 0.5, true)
			for sp in _sparks:
				var p: Vector2 = sp["dir"] * sp["speed"] * u * 0.5
				draw_line(p, p - sp["dir"] * 12.0 * a, Color(color.lightened(0.3), a), sp["size"] * a, true)
				draw_circle(p, sp["size"] * a * 0.7, Color(1, 1, 1, a))
		"burst":
			var rr := 30.0 + u * 120.0
			draw_arc(Vector2.ZERO, rr, 0, TAU, 48, Color(color, a * 0.8), 6.0 * a + 1.0, true)
			draw_arc(Vector2.ZERO, rr * 0.7, 0, TAU, 48, Color(1, 1, 1, a * 0.5), 2.0, true)
			for i in 12:
				var ang := i * TAU / 12.0 + u * 0.6
				var d := Vector2(cos(ang), sin(ang))
				draw_line(d * rr * 0.55, d * (rr * 0.55 + 26.0 * a), Color(color.lightened(0.4), a), 3.0 * a + 0.5, true)
			for sp in _sparks:
				var p3: Vector2 = sp["dir"] * sp["speed"] * u * 0.6
				draw_circle(p3, sp["size"] * a, Color(color.lightened(0.3), a))
		"spark":
			for sp in _sparks:
				var p2: Vector2 = sp["dir"] * sp["speed"] * u * 0.4
				draw_line(p2, p2 - sp["dir"] * 10.0 * a, Color(color, a), 2.0, true)
		"block":
			draw_arc(Vector2.ZERO, 40.0 + u * 30.0, 0, TAU, 36, Color(color, a * 0.9), 4.0 * a + 1.0, true)
			draw_arc(Vector2.ZERO, 26.0 + u * 22.0, 0, TAU, 36, Color(color, a * 0.5), 2.0, true)
		"heal":
			for i in 6:
				var hp := Vector2(-40 + i * 16, 20 - u * 70 - (i % 2) * 14)
				draw_line(hp + Vector2(-5, 0), hp + Vector2(5, 0), Color(color, a), 3.0)
				draw_line(hp + Vector2(0, -5), hp + Vector2(0, 5), Color(color, a), 3.0)
		"zap":
			var pts := PackedVector2Array()
			var segs := 8
			for i in segs + 1:
				var f := float(i) / segs
				var jitter := Vector2(randf_range(-10, 10), randf_range(-10, 10)) if i > 0 and i < segs else Vector2.ZERO
				pts.append(target_pos * f + jitter)
			draw_polyline(pts, Color(color, a), 4.0, true)
			draw_polyline(pts, Color(1, 1, 1, a), 1.5, true)
			draw_circle(target_pos, 14.0 * a, Color(color, a * 0.6))
