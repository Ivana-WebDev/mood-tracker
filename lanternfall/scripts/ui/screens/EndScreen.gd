extends Screen
## Game over / victory summary.

var _t := 0.0


func _ready() -> void:
	var win := screen_name == "victory"
	var run: Dictionary = params.get("run", {})
	var stats: Dictionary = run.get("stats", {})
	var v := UI.vbox(14)
	v.add_child(UI.label("VICTORY" if win else "DEFEAT", 64, Palette.GOLD if win else Palette.BAD, HORIZONTAL_ALIGNMENT_CENTER))
	var sub := "The Lantern Wyrm falls. The road is lit once more." if win else "Your lantern gutters out..."
	v.add_child(UI.label(sub, 22, Palette.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER))
	var ch: Dictionary = CharacterDatabase.get_character(run.get("character", "warden"))
	var p := UI.panel()
	p.custom_minimum_size = Vector2(520, 0)
	var g := GridContainer.new()
	g.columns = 2
	g.add_theme_constant_override("h_separation", 40)
	g.add_theme_constant_override("v_separation", 8)
	var rows := [
		["Hero", ch.get("name", "?")],
		["Act reached", str(run.get("act", 1))],
		["Floors climbed", str(stats.get("floors", 0))],
		["Enemies slain", str(stats.get("kills", 0))],
		["Elites defeated", str(stats.get("elites", 0))],
		["Bosses defeated", str(stats.get("bosses", 0))],
		["Cards played", str(stats.get("cards_played", 0))],
		["Gold earned", str(stats.get("gold_earned", 0))],
		["Deck size", str(run.get("deck", []).size())],
		["Relics", str(run.get("relics", []).size())],
	]
	for r in rows:
		g.add_child(UI.label(r[0], 19, Palette.TEXT_DIM))
		g.add_child(UI.label(r[1], 19, Palette.TEXT))
	p.add_child(g)
	v.add_child(p)
	var b := UI.hbox(20)
	b.add_child(UI.accent_button("New Run", _new_run, Palette.GOLD, Vector2(240, 64)))
	b.add_child(UI.button("Main Menu", _menu, Vector2(240, 64)))
	v.add_child(b)
	add_child(UI.center(v))


func _process(d: float) -> void:
	_t += d
	queue_redraw()


func _draw() -> void:
	draw_backdrop(Palette.GOLD if screen_name == "victory" else Palette.BAD)


func on_back() -> bool:
	GameManager.run = {}
	GameManager.goto("menu")
	return true


func _new_run() -> void:
	GameManager.run = {}
	GameManager.goto("char_select")


func _menu() -> void:
	GameManager.run = {}
	GameManager.goto("menu")
