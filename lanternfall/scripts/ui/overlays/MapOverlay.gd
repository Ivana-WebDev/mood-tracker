class_name MapOverlay
extends Overlay
## Read-only view of the current act's map, available from the top bar on any screen.


func _ready() -> void:
	super._ready()
	var head := UI.hbox(20)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(UI.label("Act %d Map" % int(GameManager.run.get("act", 1)), 30, Palette.GOLD))
	head.add_child(UI.label("(view only - drag to scroll)", 18, Palette.TEXT_DIM))
	content.add_child(head)
	var frame := PanelContainer.new()
	var sb := Palette.flat(Palette.BG, 16, Palette.GOLD, 2)
	sb.set_content_margin_all(4)
	frame.add_theme_stylebox_override("panel", sb)
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var view = load("res://scripts/ui/screens/MapScreen.gd").MapView.new()
	view.read_only = true
	frame.add_child(view)
	content.add_child(frame)
	content.add_child(UI.button("Close", close, Vector2(240, 56)))
