extends Area2D

signal popped(global_pos: Vector2, size_tier: int, score_value: int)

@export_range(0, 2, 1) var size_tier := 0
@export var drift_velocity := Vector2.ZERO
@export var wrap_padding := -1.0
@export var debug_wrap_log := false

@onready var hit_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")

func _ready() -> void:
	add_to_group(GameGlobals.GROUP_ASTEROID)

func _physics_process(delta: float) -> void:
	global_position += drift_velocity * delta
	_wrap_self()

func pop() -> void:
	emit_signal("popped", global_position, size_tier, _score_for_tier(size_tier))
	queue_free()

func _score_for_tier(tier: int) -> int:
	match tier:
		0:
			return GameGlobals.SCORE_ASTEROID_LARGE
		1:
			return GameGlobals.SCORE_ASTEROID_MEDIUM
		_:
			return GameGlobals.SCORE_ASTEROID_SMALL

func _wrap_self() -> void:
	var viewport_size := get_viewport_rect().size
	var pad := _effective_wrap_padding()
	var before := global_position
	var shifted := before + Vector2(pad, pad)
	var wrapped := GameGlobals.wrap_position(shifted, viewport_size.x + pad * 2.0, viewport_size.y + pad * 2.0) - Vector2(pad, pad)
	global_position = wrapped
	if debug_wrap_log and wrapped.distance_to(before) > 0.01:
		print("Asteroid wrapped from %s to %s" % [before, wrapped])

func _effective_wrap_padding() -> float:
	if wrap_padding >= 0.0:
		return wrap_padding
	if hit_shape and hit_shape.shape is CircleShape2D:
		return (hit_shape.shape as CircleShape2D).radius
	if hit_shape and hit_shape.shape is RectangleShape2D:
		var rect := hit_shape.shape as RectangleShape2D
		return max(rect.size.x, rect.size.y) * 0.5
	return 0.0
