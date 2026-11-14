extends Node
## JSON persistence for the active run and long-term profile (stats + settings).

const RUN_PATH := "user://run_save.json"
const PROFILE_PATH := "user://profile.json"

var profile: Dictionary = {}


func _ready() -> void:
	load_profile()


func has_run() -> bool:
	return FileAccess.file_exists(RUN_PATH)


func save_run() -> void:
	if GameManager.run.is_empty():
		return
	var data: Dictionary = GameManager.run.duplicate(true)
	# 64-bit RNG values do not survive JSON floats, so store them as strings.
	data["rng_state"] = str(GameManager.rng.state)
	data["seed"] = str(GameManager.rng.seed)
	_write(RUN_PATH, data)


func load_run() -> bool:
	var data = _read(RUN_PATH)
	if typeof(data) != TYPE_DICTIONARY or not data.has("character"):
		return false
	data = _fix_numbers(data)
	GameManager.rng.seed = str(data.get("seed", "0")).to_int()
	GameManager.rng.state = str(data.get("rng_state", "0")).to_int()
	data.erase("rng_state")
	data.erase("seed")
	GameManager.run = data
	return true


func clear_run() -> void:
	if FileAccess.file_exists(RUN_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RUN_PATH))


func load_profile() -> void:
	var data = _read(PROFILE_PATH)
	if typeof(data) == TYPE_DICTIONARY:
		profile = _fix_numbers(data)
	var defaults := {"runs": 0, "wins": 0, "best_floor": 0, "wins_by_char": {}, "fast_combat": false, "screen_shake": true, "fullscreen": false, "music_vol": 0.7, "sfx_vol": 0.8}
	for k in defaults:
		if not profile.has(k):
			profile[k] = defaults[k]


func save_profile() -> void:
	_write(PROFILE_PATH, profile)


func record_run_end(victory: bool) -> void:
	var run: Dictionary = GameManager.run
	profile["runs"] = int(profile["runs"]) + 1
	var floors := int(run.get("stats", {}).get("floors", 0))
	profile["best_floor"] = maxi(int(profile["best_floor"]), floors)
	if victory:
		profile["wins"] = int(profile["wins"]) + 1
		var ch: String = run.get("character", "")
		var wbc: Dictionary = profile["wins_by_char"]
		wbc[ch] = int(wbc.get(ch, 0)) + 1
	save_profile()


func _write(path: String, data: Dictionary) -> void:
	var tmp := path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_warning("Save failed: %s" % FileAccess.get_open_error())
		return
	f.store_string(JSON.stringify(data))
	f.close()
	# Atomic-ish replace so a crash mid-write never corrupts the save.
	var dir := DirAccess.open("user://")
	if dir != null:
		if FileAccess.file_exists(path):
			dir.remove(path.get_file())
		dir.rename(tmp.get_file(), path.get_file())


func _read(path: String):
	if not FileAccess.file_exists(path):
		return null
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	var txt := f.get_as_text()
	f.close()
	var json := JSON.new()
	if json.parse(txt) != OK:
		push_warning("Corrupt save at %s" % path)
		return null
	return json.data


## JSON turns every number into a float; convert whole numbers back into ints.
func _fix_numbers(v):
	match typeof(v):
		TYPE_FLOAT:
			if is_equal_approx(v, round(v)):
				return int(v)
			return v
		TYPE_DICTIONARY:
			var out := {}
			for k in v:
				out[k] = _fix_numbers(v[k])
			return out
		TYPE_ARRAY:
			var arr: Array = []
			for x in v:
				arr.append(_fix_numbers(x))
			return arr
	return v
