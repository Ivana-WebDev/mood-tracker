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


func draw_backdrop(accent: Color) -> void:
	# Subtle vector backdrop: soft vignette rings + horizon.
	var s := size
	draw_rect(Rect2(Vector2.ZERO, s), Palette.BG)
	for i in 6:
		var r := s.x * (0.25 + i * 0.12)
		draw_circle(Vector2(s.x * 0.5, s.y * 1.15), r, Color(accent, 0.035))
	draw_line(Vector2(0, s.y * 0.62), Vector2(s.x, s.y * 0.62), Color(accent, 0.12), 2.0)
