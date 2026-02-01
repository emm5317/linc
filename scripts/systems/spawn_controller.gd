extends Node
class_name SpawnController

@export var start_interval := GameGlobals.SPAWN_INTERVAL_START
@export var min_interval := GameGlobals.SPAWN_INTERVAL_MIN
@export var step := GameGlobals.SPAWN_INTERVAL_STEP
@export var score_step := GameGlobals.SCORE_PER_RAMP_STEP

var _interval := GameGlobals.SPAWN_INTERVAL_START

func _ready() -> void:
	reset()

func reset() -> void:
	_interval = start_interval

func register_score(total_score: int) -> void:
	var steps := int(total_score / max(score_step, 1.0))
	_interval = max(min_interval, start_interval - (steps * step))

func get_interval() -> float:
	return _interval
