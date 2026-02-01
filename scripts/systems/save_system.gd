extends Node
class_name SaveSystem

const SAVE_PATH := "user://save.cfg"
const SECTION := "score"
const KEY_BEST := "best"

func load_best_score() -> int:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err != OK:
		return 0
	return int(cfg.get_value(SECTION, KEY_BEST, 0))

func save_best_score(value: int) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(SECTION, KEY_BEST, value)
	cfg.save(SAVE_PATH)
