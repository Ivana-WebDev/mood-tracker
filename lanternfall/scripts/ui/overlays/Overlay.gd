class_name Overlay
extends Control
## Full-screen modal with a dimmed backdrop. Subclasses fill `content`.

signal closed

var content: VBoxContainer
var dismissable: bool = true


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := UI.dim_layer()
	add_child(dim)
	dim.gui_input.connect(_on_dim_input)
	content = UI.vbox(16)
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.offset_top = 24
	content.offset_bottom = -24
	content.offset_left = 24
	content.offset_right = -24
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(content)
	# Panels and buttons placed directly in the column keep their natural width instead of
	# stretching edge to edge (anything that set EXPAND explicitly is left alone).
	content.child_entered_tree.connect(func(n):
		if (n is PanelContainer or n is Button) and n.size_flags_horizontal == Control.SIZE_FILL:
			n.size_flags_horizontal = Control.SIZE_SHRINK_CENTER)



func _ready() -> void:
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.15)


func _on_dim_input(event: InputEvent) -> void:
	if dismissable and event is InputEventMouseButton and not event.pressed:
		close()


func close() -> void:
	if is_queued_for_deletion():
		return
	closed.emit()
	queue_free()


static func open(from: Node, ov: Overlay) -> Overlay:
	var m := UI.main(from)
	if m != null:
		m.add_overlay(ov)
	else:
		from.add_child(ov)
	return ov
