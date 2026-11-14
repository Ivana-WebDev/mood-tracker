extends Control
## Root of the app: swaps screens, hosts global overlays (tooltip, toast, pause) and handles Android lifecycle.

const SCREENS := {
	"menu": "res://scripts/ui/screens/MainMenu.gd",
	"char_select": "res://scripts/ui/screens/CharacterSelect.gd",
	"map": "res://scripts/ui/screens/MapScreen.gd",
	"combat": "res://scripts/ui/screens/CombatScreen.gd",
	"reward": "res://scripts/ui/screens/RewardScreen.gd",
	"rest": "res://scripts/ui/screens/RestScreen.gd",
	"shop": "res://scripts/ui/screens/ShopScreen.gd",
	"event": "res://scripts/ui/screens/EventScreen.gd",
	"treasure": "res://scripts/ui/screens/TreasureScreen.gd",
	"game_over": "res://scripts/ui/screens/EndScreen.gd",
	"victory": "res://scripts/ui/screens/EndScreen.gd",
}

var current: Control
var current_name: String = ""
var screen_layer: Control
var overlay_layer: Control
var low_hp: LowHPOverlay
var _tooltip: PanelContainer
var _tooltip_timer: SceneTreeTimer
var _toast_box: VBoxContainer


func _ready() -> void:
	theme = Palette.make_theme()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg := ColorRect.new()
	bg.color = Palette.BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	screen_layer = Control.new()
	screen_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(screen_layer)
	low_hp = LowHPOverlay.new()
	add_child(low_hp)
	overlay_layer = Control.new()
	overlay_layer.name = "Overlays"
	overlay_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Hand cards, FX and the targeting arrow use z_index up to ~70; keep every overlay above them.
	overlay_layer.z_index = 200
	add_child(overlay_layer)
	_build_tooltip()
	_toast_box = UI.vbox(8)
	_toast_box.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_toast_box.offset_top = 80
	_toast_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_box.z_index = 300
	add_child(_toast_box)
	GameManager.screen_requested.connect(_on_screen_requested)
	get_tree().set_auto_accept_quit(false)
	if is_desktop():
		DisplayServer.window_set_min_size(Vector2i(960, 540))
		apply_display()
	_swap("menu", {})


func _on_screen_requested(screen: String, params: Dictionary) -> void:
	# Deferred so the caller (often inside a signal from the old screen) finishes first.
	call_deferred("_swap", screen, params)


func _swap(screen: String, params: Dictionary) -> void:
	hide_tooltip()
	for o in overlay_layer.get_children():
		o.queue_free()
	if current != null:
		var old := current
		old.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var tw_out := old.create_tween()
		tw_out.tween_property(old, "modulate:a", 0.0, 0.12)
		tw_out.tween_callback(old.queue_free)
	var script: Script = load(SCREENS.get(screen, SCREENS["menu"]))
	var s: Control = script.new()
	s.set("screen_name", screen)
	s.set("params", params)
	s.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	s.modulate.a = 0.0
	screen_layer.add_child(s)
	var tw := s.create_tween()
	tw.tween_property(s, "modulate:a", 1.0, 0.2)
	current = s
	current_name = screen
	ScreenWipe.play(self)
	AudioManager.play_music(AudioManager.music_for_screen(screen, params))
	if screen == "victory":
		AudioManager.play("victory")
	elif screen == "game_over":
		AudioManager.play("defeat")


# ------------------------------------------------------------------ overlays

func add_overlay(node: Control) -> void:
	overlay_layer.add_child(node)


func has_overlay() -> bool:
	for o in overlay_layer.get_children():
		if not o.is_queued_for_deletion():
			return true
	return false


func close_top_overlay() -> bool:
	var kids := overlay_layer.get_children().filter(func(o): return not o.is_queued_for_deletion())
	if kids.is_empty():
		return false
	var top: Node = kids[-1]
	if top.has_method("close"):
		top.close()
	else:
		top.queue_free()
	return true


func _build_tooltip() -> void:
	_tooltip = UI.panel(Palette.BG_2, 14, Palette.GOLD)
	_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tooltip.custom_minimum_size = Vector2(300, 0)
	var v := UI.vbox(6, BoxContainer.ALIGNMENT_BEGIN)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var t := UI.label("", 20, Palette.GOLD)
	t.name = "Title"
	var b := UI.wrap_label("", 16, Palette.TEXT, HORIZONTAL_ALIGNMENT_LEFT)
	b.name = "Body"
	b.custom_minimum_size = Vector2(300, 0)
	v.add_child(t)
	v.add_child(b)
	_tooltip.add_child(v)
	_tooltip.visible = false
	_tooltip.z_index = 300
	add_child(_tooltip)


func show_tooltip(title: String, body: String, at: Vector2) -> void:
	var t: Label = _tooltip.find_child("Title", true, false)
	var b: Label = _tooltip.find_child("Body", true, false)
	t.text = title
	b.text = body
	_tooltip.visible = true
	_tooltip.reset_size()
	await get_tree().process_frame
	var sz := _tooltip.size
	var vp := get_viewport_rect().size
	var pos := at + Vector2(-sz.x / 2.0, -sz.y - 30)
	if pos.y < 8:
		pos.y = at.y + 40
	pos.x = clampf(pos.x, 8, vp.x - sz.x - 8)
	pos.y = clampf(pos.y, 8, vp.y - sz.y - 8)
	_tooltip.position = pos
	_tooltip_timer = get_tree().create_timer(3.0)
	var my_timer := _tooltip_timer
	await my_timer.timeout
	if my_timer == _tooltip_timer:
		hide_tooltip()


func hide_tooltip() -> void:
	if _tooltip:
		_tooltip.visible = false


func show_toast(text: String, color: Color = Palette.TEXT) -> void:
	var p := UI.panel(Palette.BG_2, 12, color)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(UI.label(text, 20, color, HORIZONTAL_ALIGNMENT_CENTER))
	p.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_toast_box.add_child(p)
	var tw := p.create_tween()
	tw.tween_interval(1.6)
	tw.tween_property(p, "modulate:a", 0.0, 0.4)
	tw.tween_callback(p.queue_free)


func _input(event: InputEvent) -> void:
	# Any tap dismisses the tooltip (after the tap is processed).
	if _tooltip.visible and event is InputEventMouseButton and event.pressed:
		hide_tooltip()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_on_back()
		elif event.keycode == KEY_F11 or (event.keycode == KEY_ENTER and event.alt_pressed):
			toggle_fullscreen()


static func is_desktop() -> bool:
	return OS.has_feature("pc") or OS.has_feature("web")


func apply_display() -> void:
	if not is_desktop():
		return
	var fs: bool = SaveManager.profile.get("fullscreen", false)
	var mode := DisplayServer.window_get_mode()
	if fs and mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif not fs and mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func toggle_fullscreen() -> void:
	SaveManager.profile["fullscreen"] = not SaveManager.profile.get("fullscreen", false)
	SaveManager.save_profile()
	apply_display()


# ------------------------------------------------------------------ lifecycle

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			_on_back()
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT:
			if GameManager.has_run():
				SaveManager.save_run()
		NOTIFICATION_WM_CLOSE_REQUEST:
			if GameManager.has_run():
				SaveManager.save_run()
			get_tree().quit()


func _on_back() -> void:
	if close_top_overlay():
		return
	if current != null and current.has_method("on_back") and current.on_back():
		return
	if current_name == "menu":
		# Back on Android exits from the title screen; on PC, Esc there does nothing (use Quit).
		if OS.has_feature("mobile"):
			get_tree().quit()
		return
	if GameManager.has_run():
		open_pause()
	else:
		GameManager.goto("menu")


func open_pause() -> void:
	var o := load("res://scripts/ui/overlays/PauseMenu.gd").new() as Control
	add_overlay(o)
