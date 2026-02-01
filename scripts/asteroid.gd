extends Area2D

signal popped(global_pos: Vector2, size_tier: int, score_value: int)

@export_range(0, 2, 1) var size_tier := 0
@export var drift_velocity := Vector2.ZERO
@export var wrap_padding := -1.0
@export var debug_wrap_log := false

@onready var hit_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")

func _ready() -> void:
	add_to_group(GameGlobals.GROUP_ASTEROID)
	_apply_tier_visuals()
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

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

func _on_body_entered(body: Node) -> void:
	if body and body.is_in_group(GameGlobals.GROUP_PLAYER) and body.has_method("apply_hit"):
		body.call("apply_hit")

func _on_area_entered(area: Area2D) -> void:
	if area and area.is_in_group(GameGlobals.GROUP_PLAYER) and area.has_method("apply_hit"):
		area.call("apply_hit")

func _apply_tier_visuals() -> void:
	match size_tier:
		0:
			scale = Vector2.ONE
			_set_collision_radius(22.0)
		1:
			scale = Vector2(0.7, 0.7)
			_set_collision_radius(15.0)
		_:
			scale = Vector2(0.45, 0.45)
			_set_collision_radius(10.0)

func _set_collision_radius(radius: float) -> void:
	if hit_shape == null:
		return
	if hit_shape.shape is CircleShape2D:
		var circle := (hit_shape.shape as CircleShape2D).duplicate()
		circle.radius = radius
		hit_shape.shape = circle
