extends RigidBody2D

signal collected(score_value: int)

@export var score_value := GameGlobals.SCORE_PICKUP
@export var tractor_accel := 8.0

var _tractor_target: Node2D

func _ready() -> void:
	add_to_group(GameGlobals.GROUP_PICKUP)
	body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	if _tractor_target:
		var dir := (_tractor_target.global_position - global_position).normalized()
		linear_velocity += dir * tractor_accel

func set_tractor_target(target: Node2D) -> void:
	_tractor_target = target

func _on_body_entered(body: Node) -> void:
	if body and body.is_in_group(GameGlobals.GROUP_PLAYER):
		emit_signal("collected", score_value)
		queue_free()
