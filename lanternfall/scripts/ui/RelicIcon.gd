class_name RelicIcon
extends Control
## Small round relic badge. Tap to show its description.

signal tapped(id: String)

var relic_id: String = ""
var flash: float = 0.0


func _init(id: String = "", px: float = 44.0) -> void:
	relic_id = id
	custom_minimum_size = Vector2(px, px)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _ready() -> void:
	RelicManager.relic_triggered.connect(_on_trigger)


func _on_trigger(id: String) -> void:
	if id == relic_id:
		flash = 1.0
		var tw := create_tween()
		tw.tween_property(self, "flash", 0.0, 0.6)


func _process(_d: float) -> void:
	if flash > 0.0:
		queue_redraw()


func _draw() -> void:
	var r: Dictionary = RelicDatabase.get_relic(relic_id)
	var col := Color(r["color"])
	var c := size / 2.0
	var rad := minf(size.x, size.y) / 2.0 - 2.0
	draw_circle(c, rad + flash * 5.0, col.lerp(Color.WHITE, flash * 0.6).darkened(0.6))
	draw_arc(c, rad, 0, TAU, 32, Palette.RARITY.get(r["rarity"], Palette.LINE), 2.0, true)
	IconDraw.icon(self, r["icon"], c, rad * 0.62, col)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		var r: Dictionary = RelicDatabase.get_relic(relic_id)
		UI.tooltip(self, r["name"], r["desc"], get_global_rect().get_center())
		tapped.emit(relic_id)
		accept_event()
