extends Screen
## Title screen.

var _t := 0.0
var _settings_box: VBoxContainer
var _logo: Control


func _ready() -> void:
	var col := UI.vbox(14)
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	col.offset_left = 0
	col.offset_top = 0
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(col)
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 186)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(spacer)
	_logo = Control.new()
	_logo.custom_minimum_size = Vector2(0, 120)
	_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_logo)
	var btns := UI.vbox(12)
	btns.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btns.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if SaveManager.has_run():
		btns.add_child(UI.accent_button("Continue Run", _continue, Palette.GOLD, Vector2(320, 64)))
	btns.add_child(UI.button("New Run", _new_run, Vector2(320, 64)))
	btns.add_child(UI.button("Settings & Stats", _settings, Vector2(320, 64)))
	btns.add_child(UI.button("Quit", func(): get_tree().quit(), Vector2(320, 56)))
	col.add_child(btns)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	draw_backdrop(Palette.GOLD, 0.7)
	var gy := size.y * 0.86
	IconDraw.creature(self, "clockwright", Vector2(size.x * 0.13, gy - 70), 70, Color(CharacterDatabase.CHARACTERS["clockwright"]["color"]), _t, 1.0)
	IconDraw.creature(self, "fatebinder", Vector2(size.x * 0.87, gy - 70), 70, Color(CharacterDatabase.CHARACTERS["fatebinder"]["color"]), _t + 1.0, -1.0)
	IconDraw.creature(self, "duskdancer", Vector2(size.x * 0.75, gy - 40), 50, Color(CharacterDatabase.CHARACTERS["duskdancer"]["color"]), _t + 2.0, -1.0)
	# Hanging lantern centrepiece.
	var c := Vector2(size.x / 2.0, 110 + sin(_t * 1.4) * 4.0)
	draw_line(Vector2(c.x, 0), c + Vector2(0, -40), Palette.LINE, 3.0)
	for i in 5:
		draw_circle(c, 70 - i * 10 + sin(_t * 2.0) * 3.0, Color(Palette.GOLD, 0.05 + i * 0.03))
	var pts := PackedVector2Array([c + Vector2(0, -42), c + Vector2(28, 0), c + Vector2(0, 42), c + Vector2(-28, 0)])
	draw_colored_polygon(pts, Palette.GOLD)
	var inner := PackedVector2Array([c + Vector2(0, -24), c + Vector2(15, 0), c + Vector2(0, 24), c + Vector2(-15, 0)])
	draw_colored_polygon(inner, Color("fff4d6"))
	if _logo != null and _logo.is_visible_in_tree():
		_draw_logo(_logo.get_global_rect())
	# Drifting embers
	for i in 18:
		var x := fmod(i * 137.0 + _t * (8 + i % 5 * 3), size.x)
		var y := size.y - fmod(i * 59.0 + _t * (20 + i % 7 * 6), size.y)
		draw_circle(Vector2(x, y), 1.5 + (i % 3), Color(Palette.GOLD, 0.25))


## Hand-drawn animated logo: per-letter wave, glowing layered outline, a shimmer sweep and an ornamental subtitle bar.
func _draw_logo(r: Rect2) -> void:
	var f := UI.font()
	var title := "LANTERNFALL"
	var fs := 76
	var total := f.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + (title.length() - 1) * 4.0
	var x := r.get_center().x - total / 2.0
	var base_y := r.position.y + 70.0
	var sweep := fmod(_t * 0.35, 1.6) - 0.3
	for i in title.length():
		var ch := title[i]
		var w := f.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var u := (x + w * 0.5 - (r.get_center().x - total / 2.0)) / total
		var p := Vector2(x, base_y + sin(_t * 1.6 + i * 0.55) * 3.0)
		var shine := clampf(1.0 - absf(u - sweep) * 7.0, 0.0, 1.0)
		draw_string_outline(f, p, ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 22, Color(Palette.GOLD, 0.08))
		draw_string_outline(f, p + Vector2(0, 5), ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 10, Color(0.05, 0.03, 0.02, 0.9))
		draw_string_outline(f, p, ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 10, Color("2a1a0c"))
		draw_string_outline(f, p, ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 5, Color("a8681f"))
		draw_string(f, p + Vector2(0, 2), ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("d98a2b"))
		draw_string(f, p, ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("ffc95a").lerp(Color("fff6dc"), shine))
		x += w + 4.0
	# Ornamental bar with diamonds and the subtitle.
	var cy := base_y + 26.0
	var cx := r.get_center().x
	var half := total * 0.5
	for sgn in [-1.0, 1.0]:
		var sg: float = sgn
		draw_line(Vector2(cx + sg * 130, cy + 8), Vector2(cx + sg * half, cy + 8), Color(Palette.GOLD, 0.6), 2.0, true)
		CardFrame.gem(self, Vector2(cx + sg * (half + 10), cy + 8), 6.0, Palette.GOLD)
		CardFrame.four_star(self, Vector2(cx + sg * 118, cy + 8), 6.0, Color("ffe7a8"))
	draw_string_outline(f, Vector2(cx - 110, cy + 15), "A ROGUELIKE DECKBUILDER", HORIZONTAL_ALIGNMENT_CENTER, 220, 14, 4, Color(0, 0, 0, 0.7))
	draw_string(f, Vector2(cx - 110, cy + 15), "A ROGUELIKE DECKBUILDER", HORIZONTAL_ALIGNMENT_CENTER, 220, 14, Palette.TEXT_DIM.lightened(0.2))


func _continue() -> void:
	if not GameManager.continue_run():
		UI.toast(self, "Save could not be loaded.", Palette.BAD)


func _new_run() -> void:
	if SaveManager.has_run():
		# Starting over abandons the saved run.
		SaveManager.record_run_end(false)
		SaveManager.clear_run()
	GameManager.goto("char_select")


func _settings() -> void:
	var ov := Overlay.new()
	var p := UI.panel()
	p.custom_minimum_size = Vector2(480, 0)
	_settings_box = UI.vbox(12)
	p.add_child(_settings_box)
	ov.content.add_child(p)
	Overlay.open(self, ov)
	_fill_settings()


func _fill_settings() -> void:
	for c in _settings_box.get_children():
		c.queue_free()
	var prof := SaveManager.profile
	_settings_box.add_child(UI.label("Settings", 30, Palette.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	_settings_box.add_child(UI.button("Fast Combat: %s" % ("On" if prof["fast_combat"] else "Off"), _toggle.bind("fast_combat"), Vector2(400, 50)))
	_settings_box.add_child(UI.button("Screen Shake: %s" % ("On" if prof["screen_shake"] else "Off"), _toggle.bind("screen_shake"), Vector2(400, 50)))
	_settings_box.add_child(UI.volume_row("Music", "music_vol", 480, AudioManager.apply_volumes))
	_settings_box.add_child(UI.volume_row("Sound", "sfx_vol", 480, func(): AudioManager.play("click")))
	if UI.main(self) != null and UI.main(self).is_desktop():
		_settings_box.add_child(UI.button("Fullscreen: %s  (F11)" % ("On" if prof.get("fullscreen", false) else "Off"), _toggle_fullscreen, Vector2(400, 50)))
	_settings_box.add_child(UI.label("Statistics", 26, Palette.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	_settings_box.add_child(UI.label("Runs: %d    Wins: %d    Best floor: %d" % [int(prof["runs"]), int(prof["wins"]), int(prof["best_floor"])], 18, Palette.TEXT, HORIZONTAL_ALIGNMENT_CENTER))
	for id in CharacterDatabase.ORDER:
		var w := int(prof["wins_by_char"].get(id, 0))
		_settings_box.add_child(UI.label("%s wins: %d" % [CharacterDatabase.get_character(id)["name"], w], 16, Palette.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER))


func _toggle(key: String) -> void:
	SaveManager.profile[key] = not SaveManager.profile[key]
	SaveManager.save_profile()
	_fill_settings()


func _toggle_fullscreen() -> void:
	UI.main(self).toggle_fullscreen()
	_fill_settings()
