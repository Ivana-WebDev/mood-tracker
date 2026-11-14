class_name DeckViewer
extends Overlay
## Scrollable grid of cards. In pick mode, the player selects one card and confirms.

signal picked(uid: int)

var cards: Array = []
var mode: String = "view" # view | upgrade | remove | pick
var title_text: String = ""
var _selected_uid: int = -1
var _confirm: Button
var _views: Array = []


func _init(card_list: Array = [], title: String = "Deck", pick_mode: String = "view") -> void:
	super._init()
	cards = card_list
	title_text = title
	mode = pick_mode
	dismissable = pick_mode == "view"


func _ready() -> void:
	super._ready()
	var head := UI.hbox(20)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(UI.label(title_text, 30, Palette.GOLD))
	head.add_child(UI.label("(%d cards)" % cards.size(), 20, Palette.TEXT_DIM))
	content.add_child(head)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.scroll_deadzone = 12
	content.add_child(scroll)
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll.add_child(margin)
	var grid := HFlowContainer.new()
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.alignment = FlowContainer.ALIGNMENT_CENTER
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 18)
	grid.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.add_child(grid)
	var sorted := cards.duplicate()
	sorted.sort_custom(func(a, b):
		var da: Dictionary = CardDatabase.CARDS[a["id"]]
		var db: Dictionary = CardDatabase.CARDS[b["id"]]
		if da["type"] != db["type"]:
			return da["type"] < db["type"]
		return da["name"] < db["name"])
	if sorted.is_empty():
		grid.add_child(UI.label("No cards here.", 22, Palette.TEXT_DIM))
	for c in sorted:
		var v := CardView.new(c)
		v.mouse_filter = Control.MOUSE_FILTER_PASS
		v.show_glow = false
		v.tapped.connect(_on_card_tapped)
		grid.add_child(v)
		_views.append(v)
	var foot := UI.hbox(24)
	foot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if mode == "view":
		foot.add_child(UI.button("Close", close))
	else:
		foot.add_child(UI.button("Cancel", close))
		_confirm = UI.accent_button("Confirm", _on_confirm, Palette.GOOD)
		_confirm.disabled = true
		foot.add_child(_confirm)
	content.add_child(foot)


func _on_card_tapped(v: CardView) -> void:
	if mode == "view":
		return
	for o in _views:
		var ov: CardView = o
		if ov.selected and ov != v:
			ov.selected = false
			if mode == "upgrade":
				ov.inst = ov.inst.duplicate()
				ov.inst["upgraded"] = false
			ov.refresh()
	v.selected = not v.selected
	if mode == "upgrade":
		v.inst = v.inst.duplicate()
		v.inst["upgraded"] = v.selected
	v.refresh()
	_selected_uid = int(v.inst["uid"]) if v.selected else -1
	_confirm.disabled = _selected_uid < 0


func _on_confirm() -> void:
	if _selected_uid < 0:
		return
	picked.emit(_selected_uid)
	close()
