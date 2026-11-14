extends Control
## Renders every card of each hero into a screenshot (one image per hero). Visual check only.

func _ready() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shots="):
			dir = a.substr(8)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Palette.BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	for owner in ["clockwright", "fatebinder", "duskdancer", "curse"]:
		var ids: Array = []
		for r in ["starter", "common", "uncommon", "rare", "special"]:
			ids += CardDatabase.pool(owner, r)
		var holder := Control.new()
		add_child(holder)
		for i in ids.size():
			var v := CardView.new({"uid": i, "id": ids[i], "upgraded": false})
			v.show_glow = false
			v.scale = Vector2(0.78, 0.78)
			v.pivot_offset = Vector2.ZERO
			v.position = Vector2(8 + (i % 10) * 127, 6 + int(i / 10) * 178)
			holder.add_child(v)
		for k in 6:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		if dir != "":
			get_viewport().get_texture().get_image().save_png(dir.path_join("gallery_%s.png" % owner))
		holder.queue_free()
		await get_tree().process_frame
	get_tree().quit()
