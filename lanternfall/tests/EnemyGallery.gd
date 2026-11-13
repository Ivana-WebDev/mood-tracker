extends Control
## Renders every enemy portrait into one screenshot (visual check only).
## Run: godot --path . res://tests/EnemyGallery.tscn -- --shots=<dir>

var _t := 0.0
var only_new := false


func _ready() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shots="):
			dir = a.substr(8)
		if a == "--new":
			only_new = true
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for k in 8:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	if dir != "":
		DirAccess.make_dir_recursive_absolute(dir)
		get_viewport().get_texture().get_image().save_png(dir.path_join("enemies_new.png" if only_new else "enemies.png"))
	get_tree().quit()


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Palette.BG)
	var ids: Array = EnemyDatabase.ENEMIES.keys()
	var cols := 9
	if only_new:
		ids = ids.filter(func(k): return EnemyArt.has(EnemyDatabase.ENEMIES[k]["shape"]))
		cols = 4
	var cw := size.x / cols
	var rh := size.y / ceilf(ids.size() / float(cols))
	for i in ids.size():
		var d: Dictionary = EnemyDatabase.ENEMIES[ids[i]]
		var cx := cw * (i % cols) + cw * 0.5
		var cy := rh * (i / cols) + rh * 0.55
		var s := minf(cw, rh) * 0.26 * float(d.get("size", 1.0))
		IconDraw.creature(self, d["shape"], Vector2(cx, cy), s, Color(d["color"]), 1.3 + i * 0.37, -1.0)
		draw_string(UI.font(), Vector2(cx - cw * 0.5, rh * (i / cols) + rh - 6), d["name"], HORIZONTAL_ALIGNMENT_CENTER, cw, 13, Palette.TEXT)
