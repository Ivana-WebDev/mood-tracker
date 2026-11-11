class_name PauseMenu
extends Overlay
## Back-button menu: resume, settings, save & quit, abandon.

var _confirming := false
var _box: VBoxContainer


func _ready() -> void:
	super._ready()
	var p := UI.panel()
	p.custom_minimum_size = Vector2(440, 0)
	_box = UI.vbox(14)
	p.add_child(_box)
	content.add_child(p)
	_build()


func _build() -> void:
	for c in _box.get_children():
		c.queue_free()
	_box.add_child(UI.label("Paused", 34, Palette.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	_box.add_child(UI.button("Resume", close, Vector2(360, 64)))
	var prof := SaveManager.profile
	_box.add_child(UI.button("Fast Combat: %s" % ("On" if prof["fast_combat"] else "Off"), _toggle.bind("fast_combat"), Vector2(360, 64)))
	_box.add_child(UI.button("Screen Shake: %s" % ("On" if prof["screen_shake"] else "Off"), _toggle.bind("screen_shake"), Vector2(360, 64)))
	if GameManager.has_run():
		_box.add_child(UI.button("Save & Main Menu", _save_quit, Vector2(360, 64)))
		var ab := UI.accent_button("Abandon Run" if not _confirming else "Tap again to confirm", _abandon, Palette.BAD, Vector2(360, 64))
		_box.add_child(ab)


func _toggle(key: String) -> void:
	SaveManager.profile[key] = not SaveManager.profile[key]
	SaveManager.save_profile()
	_build()


func _save_quit() -> void:
	SaveManager.save_run()
	GameManager.run = {}
	GameManager.goto("menu")


func _abandon() -> void:
	if not _confirming:
		_confirming = true
		_build()
		return
	GameManager.abandon_run()
