class_name Screen
extends Control
## Base class for full-screen states.

var screen_name: String = ""
var params: Dictionary = {}
var top_bar: TopBar


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func add_top_bar() -> TopBar:
	top_bar = TopBar.new()
	add_child(top_bar)
	return top_bar


## Return true if the back button was handled by the screen.
func on_back() -> bool:
	return false


func _process(_d: float) -> void:
	queue_redraw()


func draw_backdrop(accent: Color, horizon: float = 0.62, lanterns: bool = true, moon_x: float = 0.82) -> void:
	Scenery.draw(self, size, accent, Time.get_ticks_msec() / 1000.0, horizon, lanterns, 0.0, moon_x)
