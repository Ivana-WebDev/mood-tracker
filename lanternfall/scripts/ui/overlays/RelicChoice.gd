class_name RelicChoice
extends Overlay
## Pick one relic out of several (boss rewards).

signal chosen(id: String)

var options: Array = []
var _done := false


func _init(opts: Array = []) -> void:
	super._init()
	options = opts
	dismissable = false


func _ready() -> void:
	super._ready()
	content.add_child(UI.label("Choose a Boss Relic", 32, Palette.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var row := UI.hbox(28)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for id in options:
		var r: Dictionary = RelicDatabase.get_relic(id)
		var p := UI.panel(Palette.PANEL, 18, Color(r["color"]))
		p.custom_minimum_size = Vector2(300, 300)
		var v := UI.vbox(12)
		v.add_child(UI.center(RelicIcon.new(id, 96)))
		v.get_child(0).custom_minimum_size = Vector2(0, 110)
		v.add_child(UI.label(r["name"], 24, Palette.TEXT, HORIZONTAL_ALIGNMENT_CENTER))
		var d := UI.wrap_label(r["desc"], 17, Palette.TEXT_DIM)
		d.custom_minimum_size = Vector2(250, 0)
		v.add_child(d)
		v.add_child(UI.accent_button("Take", func(): _pick(id), Palette.GOLD, Vector2(160, 56)))
		p.add_child(v)
		row.add_child(p)
	content.add_child(row)
	content.add_child(UI.button("Skip", func(): _pick("")))


func _pick(id: String) -> void:
	if _done:
		return
	_done = true
	chosen.emit(id)
	close()
