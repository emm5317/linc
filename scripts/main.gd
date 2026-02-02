extends Node2D

@export var asteroid_scene: PackedScene
@export var pickup_scene: PackedScene
@export var bullet_scene: PackedScene
@export var max_asteroids := 26
@export var split_count := 2

@onready var player: Node2D = get_node_or_null("Player")
@onready var hud: Node = get_node_or_null("HUD")
@onready var menu: CanvasItem = get_node_or_null("Menu")
@onready var spawn_timer: Timer = get_node_or_null("SpawnTimer")
@onready var asteroid_container: Node = get_node_or_null("Asteroids")
@onready var bullet_container: Node = get_node_or_null("Bullets")
@onready var pickup_container: Node = get_node_or_null("Pickups")
@onready var spawn_controller: Node = get_node_or_null("SpawnController")
@onready var save_system: Node = get_node_or_null("SaveSystem")
@onready var game_camera: Camera2D = get_node_or_null("GameCamera")

var score := 0
var best_score := 0
var running := false
var camera_base_offset := Vector2.ZERO
var shake_duration := 0.0
var shake_elapsed := 0.0
var shake_strength := 0.0

func _ready() -> void:
	randomize()
	if game_camera:
		camera_base_offset = game_camera.offset
	if save_system and save_system.has_method("load_best_score"):
		best_score = int(save_system.call("load_best_score"))
	if hud and hud.has_method("set_best"):
		hud.call("set_best", best_score)
	if menu:
		_show_menu()
	else:
		start_run()

func _process(delta: float) -> void:
	_update_camera_shake(delta)

func _unhandled_input(event: InputEvent) -> void:
	if menu and menu.visible:
		return
	if event.is_action_pressed("restart"):
		restart_run()

func start_run() -> void:
	if menu:
		menu.visible = false
	running = true
	score = 0
	_clear_container(asteroid_container)
	_clear_container(bullet_container)
	_clear_container(pickup_container)
	if player and player.has_method("reset_for_run"):
		player.call("reset_for_run")

	if spawn_controller and spawn_controller.has_method("reset"):
		spawn_controller.call("reset")
		_apply_spawn_interval()

	if hud and hud.has_method("set_score"):
		hud.call("set_score", score)
	if hud and hud.has_method("set_best"):
		hud.call("set_best", best_score)
	if hud and hud.has_method("show_game_over"):
		hud.call("show_game_over", false)
	if spawn_timer:
		spawn_timer.start()

func end_run() -> void:
	running = false
	if spawn_timer:
		spawn_timer.stop()
	if hud and hud.has_method("show_game_over"):
		hud.call("show_game_over", true)
	if player and player.has_method("set_controls_enabled"):
		player.call("set_controls_enabled", false)

func restart_run() -> void:
	end_run()
	start_run()

func _on_spawn_timer_timeout() -> void:
	if not running:
		return
	if asteroid_scene == null or asteroid_container == null:
		return
	if asteroid_container.get_child_count() >= max_asteroids:
		return

	_spawn_asteroid(
		_random_spawn_position(),
		0,
		Vector2.RIGHT.rotated(randf() * TAU) * randf_range(50.0, 130.0)
	)

func _on_player_shot_requested(spawn_position: Vector2, direction: Vector2) -> void:
	if not running:
		return
	if bullet_scene == null or bullet_container == null:
		return

	var bullet := bullet_scene.instantiate()
	bullet_container.add_child(bullet)
	bullet.global_position = spawn_position
	if bullet.has_method("setup"):
		bullet.call("setup", direction)

func _on_player_hit() -> void:
	if running:
		if player:
			_spawn_explosion_particles(player.global_position, 14, Color(1.0, 0.45, 0.2, 1.0))
		_trigger_camera_shake(0.16, 7.0)
		end_run()

func _on_asteroid_popped(global_pos: Vector2, size_tier: int, score_value: int) -> void:
	score += score_value
	_sync_score_ui()
	_spawn_explosion_particles(global_pos, 8, Color(1.0, 0.75, 0.28, 1.0))
	_trigger_camera_shake(0.07, 2.6)
	_spawn_split_asteroids(global_pos, size_tier)

	if pickup_scene and pickup_container:
		var pickup := pickup_scene.instantiate()
		pickup_container.add_child(pickup)
		pickup.global_position = global_pos
		if pickup.has_method("set_pickup_type"):
			var pickup_type := GameGlobals.PICKUP_TYPE_SCRAP
			if randf() <= GameGlobals.PICKUP_COOLANT_DROP_CHANCE:
				pickup_type = GameGlobals.PICKUP_TYPE_COOLANT
			pickup.call("set_pickup_type", pickup_type)
		if pickup.has_method("set_tractor_target") and player:
			pickup.call("set_tractor_target", player)
		if pickup.has_signal("collected"):
			pickup.connect("collected", Callable(self, "_on_pickup_collected"))

func _on_menu_start_pressed() -> void:
	start_run()

func _on_menu_quit_pressed() -> void:
	get_tree().quit()

func _on_pickup_collected(payload: Dictionary) -> void:
	var pickup_type := int(payload.get("type", GameGlobals.PICKUP_TYPE_SCRAP))
	var pickup_score := int(payload.get("score_value", 0))
	score += pickup_score
	if pickup_type == GameGlobals.PICKUP_TYPE_COOLANT and player and player.has_method("apply_instant_cool"):
		var grace_sec := float(payload.get("cooldown_grace_sec", GameGlobals.TRACTOR_COOLANT_GRACE_SEC))
		player.call("apply_instant_cool", grace_sec)
	_sync_score_ui()
	if spawn_controller and spawn_controller.has_method("register_score"):
		spawn_controller.call("register_score", score)
		_apply_spawn_interval()

func _sync_score_ui() -> void:
	if score > best_score:
		best_score = score
		if save_system and save_system.has_method("save_best_score"):
			save_system.call("save_best_score", best_score)
	if hud:
		if hud.has_method("set_score"):
			hud.call("set_score", score)
		if hud.has_method("set_best"):
			hud.call("set_best", best_score)

func _apply_spawn_interval() -> void:
	if spawn_timer == null or spawn_controller == null:
		return
	if spawn_controller.has_method("get_interval"):
		spawn_timer.wait_time = float(spawn_controller.call("get_interval"))

func _random_spawn_position() -> Vector2:
	var viewport := get_viewport_rect()
	var edge := randi() % 4
	match edge:
		0:
			return Vector2(0.0, randf_range(0.0, viewport.size.y))
		1:
			return Vector2(viewport.size.x, randf_range(0.0, viewport.size.y))
		2:
			return Vector2(randf_range(0.0, viewport.size.x), 0.0)
		_:
			return Vector2(randf_range(0.0, viewport.size.x), viewport.size.y)

func _clear_container(container: Node) -> void:
	if container == null:
		return
	for child in container.get_children():
		child.queue_free()

func _spawn_asteroid(at_position: Vector2, size_tier: int, drift_velocity: Vector2) -> void:
	if asteroid_scene == null or asteroid_container == null:
		return
	var asteroid := asteroid_scene.instantiate()
	asteroid.set("size_tier", clamp(size_tier, 0, 2))
	asteroid.set("drift_velocity", drift_velocity)
	asteroid_container.add_child(asteroid)
	asteroid.global_position = at_position
	if asteroid.has_signal("popped"):
		asteroid.connect("popped", Callable(self, "_on_asteroid_popped"))

func _spawn_split_asteroids(global_pos: Vector2, size_tier: int) -> void:
	if size_tier >= 2:
		return
	if asteroid_container == null:
		return
	var next_tier := size_tier + 1
	var base_direction := Vector2.RIGHT.rotated(randf() * TAU)
	for i in range(split_count):
		if asteroid_container.get_child_count() >= max_asteroids:
			break
		var direction_sign := -1.0 if i == 0 else 1.0
		var dir := base_direction.rotated(direction_sign * randf_range(0.25, 0.6)).normalized()
		var speed := randf_range(85.0, 130.0) + (next_tier * 12.0)
		_spawn_asteroid(global_pos + (dir * 6.0), next_tier, dir * speed)

func _show_menu() -> void:
	if menu:
		menu.visible = true
	running = false
	_clear_container(asteroid_container)
	_clear_container(bullet_container)
	_clear_container(pickup_container)
	if spawn_timer:
		spawn_timer.stop()
	if player and player.has_method("set_controls_enabled"):
		player.call("set_controls_enabled", false)
	if hud and hud.has_method("set_score"):
		hud.call("set_score", 0)
	if hud and hud.has_method("set_best"):
		hud.call("set_best", best_score)
	if hud and hud.has_method("show_game_over"):
		hud.call("show_game_over", false)

func _update_camera_shake(delta: float) -> void:
	if game_camera == null:
		return
	if shake_duration > 0.0 and shake_elapsed < shake_duration:
		shake_elapsed = min(shake_elapsed + delta, shake_duration)
		var progress: float = shake_elapsed / maxf(shake_duration, 0.001)
		var current_strength: float = shake_strength * pow(1.0 - progress, 2.0)
		game_camera.offset = camera_base_offset + Vector2(
			round(randf_range(-current_strength, current_strength)),
			round(randf_range(-current_strength, current_strength))
		)
	else:
		game_camera.offset = camera_base_offset
		shake_duration = 0.0
		shake_elapsed = 0.0
		shake_strength = 0.0

func _trigger_camera_shake(duration: float, strength: float) -> void:
	if duration <= 0.0 or strength <= 0.0:
		return
	if duration > shake_duration:
		shake_duration = duration
		shake_elapsed = 0.0
	shake_strength = max(shake_strength, strength)

func _spawn_explosion_particles(at_position: Vector2, amount: int, tint: Color) -> void:
	var particles := GPUParticles2D.new()
	var particle_material := ParticleProcessMaterial.new()
	particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	particle_material.emission_sphere_radius = 1.0
	particle_material.gravity = Vector3.ZERO
	particle_material.initial_velocity_min = 65.0
	particle_material.initial_velocity_max = 140.0
	particle_material.scale_min = 0.9
	particle_material.scale_max = 1.4
	particle_material.angle_min = -180.0
	particle_material.angle_max = 180.0
	particle_material.linear_accel_min = -20.0
	particle_material.linear_accel_max = 10.0
	particle_material.color = tint

	particles.position = at_position
	particles.amount = amount
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.lifetime = 0.22
	particles.process_material = particle_material
	particles.local_coords = false
	add_child(particles)
	particles.restart()
	particles.emitting = true

	var cleanup_timer := Timer.new()
	cleanup_timer.one_shot = true
	cleanup_timer.wait_time = 0.45
	particles.add_child(cleanup_timer)
	cleanup_timer.timeout.connect(func() -> void:
		particles.queue_free()
	)
	cleanup_timer.start()
