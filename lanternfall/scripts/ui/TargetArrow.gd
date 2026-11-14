class_name TargetArrow
extends Control
## Curved dotted targeting arrow drawn from a card to the finger.

var from := Vector2.ZERO
var to := Vector2.ZERO
var valid := false
var _t := 0.0


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	z_index = 60


func _process(delta: float) -> void:
	if visible:
		_t += delta
		queue_redraw()


func _draw() -> void:
	var ctrl := Vector2((from.x + to.x) / 2.0, minf(from.y, to.y) - 160.0)
	var col := Palette.BAD if valid else Palette.GOLD
	var steps := 18
	for i in range(1, steps + 1):
		var t := float(i) / steps
		var p := from.lerp(ctrl, t).lerp(ctrl.lerp(to, t), t)
		if i < steps:
			var r := 3.0 + t * 6.0
			draw_circle(p, r + 2.0, Color(0, 0, 0, 0.4))
			draw_circle(p, r, col)
	var t2 := 0.94
	var before := from.lerp(ctrl, t2).lerp(ctrl.lerp(to, t2), t2)
	var dir := (to - before).normalized()
	var n := Vector2(-dir.y, dir.x)
	draw_colored_polygon(PackedVector2Array([to + dir * 10.0, to - dir * 18.0 + n * 16.0, to - dir * 18.0 - n * 16.0]), col)
