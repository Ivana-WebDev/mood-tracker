class_name CardChoice
extends Overlay
## "Choose one of these cards" (rewards, events).

signal chosen(card: Dictionary) # {id, upgraded}; empty dictionary if skipped

var options: Array = []
var title_text := "Choose a Card"
var allow_skip := true
var _done := false


func _init(opts: Array = [], title: String = "Choose a Card", skip: bool = true) -> void:
	super._init()
	options = opts
	title_text = title
	allow_skip = skip
	dismissable = false


func _ready() -> void:
	super._ready()
	content.add_child(UI.label(title_text, 32, Palette.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(UI.label("Tap a card to add it to your deck", 18, Palette.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER))
	var row := UI.hbox(36)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for o in options:
		var v := CardView.new({"uid": -1, "id": o["id"], "upgraded": o.get("upgraded", false)})
		v.show_glow = false
		v.scale = Vector2(1.2, 1.2)
		var holder := Control.new()
		holder.custom_minimum_size = CardView.CARD_SIZE * 1.25
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(v)
		v.position = (holder.custom_minimum_size - CardView.CARD_SIZE) / 2.0
		v.tapped.connect(func(_cv): _pick(o))
		row.add_child(holder)
	content.add_child(row)
	if allow_skip:
		content.add_child(UI.button("Skip", func(): _pick({})))


func _pick(o: Dictionary) -> void:
	if _done:
		return
	_done = true
	chosen.emit(o)
	close()


func close() -> void:
	if not _done:
		_done = true
		chosen.emit({})
	super.close()
