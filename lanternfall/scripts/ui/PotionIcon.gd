class_name PotionIcon
extends Control
## A potion slot in the top bar. Click a filled slot to drink or discard it.

var index: int = 0
var potion_id: String = ""
var _t := 0.0


func _init(slot: int = 0, id: String = "", px: float = 40.0) -> void:
	index = slot
	potion_id = id
	custom_minimum_size = Vector2(px, px)
	mouse_filter = Control.MOUSE_FILTER_STOP
	tooltip_text = ""


func _ready() -> void:
	if potion_id != "":
		var tip := UI.potion_tip(potion_id)
		UI.hover_tip(self, tip[0], tip[1] + ("\nClick to drink or discard." if index >= 0 else ""))


func _process(d: float) -> void:
	if potion_id != "":
		_t += d
		queue_redraw()


func _draw() -> void:
	# Freshly created icons can draw once before layout gives them a size.
	if size.x < 8.0 or size.y < 8.0:
		return
	var c := size / 2.0
	var rad := minf(size.x, size.y) / 2.0 - 2.0
	if potion_id == "":
		draw_arc(c, rad, 0, TAU, 28, Color(Palette.LINE, 0.9), 1.5, true)
		IconDraw.potion(self, c, rad * 0.62, Color(Palette.LINE, 0.25))
		return
	var p := PotionDatabase.get_potion(potion_id)
	var col := Color(p["color"])
	draw_circle(c, rad, col.darkened(0.7))
	draw_arc(c, rad, 0, TAU, 28, Palette.RARITY.get(p["rarity"], Palette.LINE), 2.0, true)
	IconDraw.potion(self, c + Vector2(0, sin(_t * 2.0) * 1.0), rad * 0.68, col)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		accept_event()
		if potion_id == "":
			UI.tooltip(self, "Empty potion slot", "Potions drop after fights and are sold in shops. You can carry %d." % PotionDatabase.MAX_SLOTS, get_global_rect().get_center())
			return
		Overlay.open(self, PotionMenu.new(index))
