class_name ScreenWipe
extends Control
## Iris reveal played on every screen change: a dark veil with a glowing lantern-light ring
## that opens from the centre. Purely visual; it never blocks input.

var p: float = 0.0   # 0 = closed, 1 = fully open


static func play(parent: Node) -> void:
	var w := ScreenWipe.new()
	w.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	w.mouse_filter = Control.MOUSE_FILTER_IGNORE
	w.z_index = 250
	parent.add_child(w)
	var tw := w.create_tween()
	tw.tween_property(w, "p", 1.0, 0.42).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_callback(w.queue_free)


func _process(_d: float) -> void:
	queue_redraw()


func _draw() -> void:
	var c := size / 2.0
	var full := c.length() + 40.0
	var r := lerpf(18.0, full, p)
	# The mask: a ring whose inner edge is the opening and outer edge covers the screen.
	var thick := full * 2.0
	draw_arc(c, r + thick / 2.0, 0, TAU, 72, Color(0.02, 0.02, 0.04, 1.0 - p * 0.35), thick, true)
	# Soft glowing rim on the opening.
	for k in 4:
		draw_arc(c, r + k * 5.0, 0, TAU, 72, Color(Palette.GOLD, (0.22 - k * 0.05) * (1.0 - p)), 6.0, true)
