extends CharacterBody2D

signal shot_requested(spawn_position: Vector2, direction: Vector2)
signal player_hit()
signal tractor_heat_changed(current: float, max_value: float, overheated: bool)

@export var thrust_force := 480.0
@export var turn_speed := 3.0
@export var damping := 0.98
@export var fire_cooldown := 0.2
@export var tractor_pull_force := 600.0
@export var wrap_padding := -1.0
@export var debug_wrap_log := false

@onready var muzzle: Marker2D = get_node_or_null("Muzzle")
@onready var tractor_area: Area2D = get_node_or_null("TractorArea")
@onready var hit_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")

var controls_enabled := true
var heat := 0.0
var overheated := false
var fire_timer := 0.0
var spawn_position := Vector2.ZERO

func _ready() -> void:
	add_to_group(GameGlobals.GROUP_PLAYER)
	spawn_position = global_position
	emit_signal("tractor_heat_changed", heat, GameGlobals.TRACTOR_HEAT_MAX, overheated)

func _physics_process(delta: float) -> void:
	if not controls_enabled:
		return
	_handle_turn(delta)
	_handle_thrust(delta)
	_handle_fire(delta)
	_handle_tractor(delta)
	velocity *= damping
	move_and_slide()
	_wrap_self()

func set_controls_enabled(value: bool) -> void:
	controls_enabled = value

func apply_hit() -> void:
	emit_signal("player_hit")

func reset_for_run() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	heat = 0.0
	overheated = false
	fire_timer = 0.0
	controls_enabled = true
	emit_signal("tractor_heat_changed", heat, GameGlobals.TRACTOR_HEAT_MAX, overheated)

func _handle_turn(delta: float) -> void:
	var turn_input := Input.get_axis("turn_left", "turn_right")
	rotation += turn_input * turn_speed * delta

func _handle_thrust(delta: float) -> void:
	if Input.is_action_pressed("thrust"):
		velocity += Vector2.RIGHT.rotated(rotation) * thrust_force * delta

func _handle_fire(delta: float) -> void:
	fire_timer = max(fire_timer - delta, 0.0)
	if fire_timer > 0.0:
		return
	if Input.is_action_pressed("shoot"):
		fire_timer = fire_cooldown
		var spawn_pos := global_position if muzzle == null else muzzle.global_position
		emit_signal("shot_requested", spawn_pos, Vector2.RIGHT.rotated(rotation))

func _handle_tractor(delta: float) -> void:
	var active := Input.is_action_pressed("tractor") and not overheated
	if active:
		heat += GameGlobals.TRACTOR_HEAT_GAIN_PER_SEC * delta
		if tractor_area:
			for body in tractor_area.get_overlapping_bodies():
				if body and body.is_in_group(GameGlobals.GROUP_PICKUP):
					var dir := (global_position - body.global_position).normalized()
					if body is RigidBody2D:
						body.apply_central_force(dir * tractor_pull_force)
	else:
		var cool_rate := GameGlobals.TRACTOR_HEAT_COOL_PER_SEC
		if overheated:
			cool_rate = GameGlobals.TRACTOR_HEAT_COOL_OVERHEATED_PER_SEC
		heat -= cool_rate * delta

	heat = clamp(heat, 0.0, GameGlobals.TRACTOR_HEAT_MAX)
	if not overheated and heat >= GameGlobals.TRACTOR_HEAT_MAX:
		overheated = true
	elif overheated and heat <= GameGlobals.TRACTOR_HEAT_MAX * 0.35:
		overheated = false

	emit_signal("tractor_heat_changed", heat, GameGlobals.TRACTOR_HEAT_MAX, overheated)

func _wrap_self() -> void:
	var viewport_size := get_viewport_rect().size
	var pad := _effective_wrap_padding()
	var before := global_position
	var shifted := before + Vector2(pad, pad)
	var wrapped := GameGlobals.wrap_position(shifted, viewport_size.x + pad * 2.0, viewport_size.y + pad * 2.0) - Vector2(pad, pad)
	global_position = wrapped
	if debug_wrap_log and wrapped.distance_to(before) > 0.01:
		print("Player wrapped from %s to %s" % [before, wrapped])

func _effective_wrap_padding() -> float:
	if wrap_padding >= 0.0:
		return wrap_padding
	if hit_shape and hit_shape.shape is CircleShape2D:
		return (hit_shape.shape as CircleShape2D).radius
	if hit_shape and hit_shape.shape is RectangleShape2D:
		var rect := hit_shape.shape as RectangleShape2D
		return max(rect.size.x, rect.size.y) * 0.5
	return 0.0
