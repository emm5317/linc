extends Node2D

@export var asteroid_scene: PackedScene
@export var pickup_scene: PackedScene
@export var bullet_scene: PackedScene
@export var max_asteroids := 30

@onready var player: Node2D = get_node_or_null("Player")
@onready var hud: Node = get_node_or_null("HUD")
@onready var spawn_timer: Timer = get_node_or_null("SpawnTimer")
@onready var asteroid_container: Node = get_node_or_null("Asteroids")
@onready var bullet_container: Node = get_node_or_null("Bullets")
@onready var pickup_container: Node = get_node_or_null("Pickups")
@onready var spawn_controller: Node = get_node_or_null("SpawnController")
@onready var save_system: Node = get_node_or_null("SaveSystem")

var score := 0
var best_score := 0
var running := false

func _ready() -> void:
	randomize()
	if save_system and save_system.has_method("load_best_score"):
		best_score = int(save_system.call("load_best_score"))
	if hud and hud.has_method("set_best"):
		hud.call("set_best", best_score)
	start_run()

func start_run() -> void:
	running = true
	score = 0
	_clear_container(asteroid_container)
	_clear_container(bullet_container)
	_clear_container(pickup_container)

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

	var asteroid := asteroid_scene.instantiate()
	asteroid_container.add_child(asteroid)
	asteroid.global_position = _random_spawn_position()
	asteroid.set("size_tier", randi() % 3)
	asteroid.set("drift_velocity", Vector2.RIGHT.rotated(randf() * TAU) * randf_range(50.0, 130.0))
	if asteroid.has_signal("popped"):
		asteroid.connect("popped", Callable(self, "_on_asteroid_popped"))

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
		end_run()

func _on_asteroid_popped(global_pos: Vector2, _size_tier: int, score_value: int) -> void:
	score += score_value
	_sync_score_ui()

	if pickup_scene and pickup_container:
		var pickup := pickup_scene.instantiate()
		pickup_container.add_child(pickup)
		pickup.global_position = global_pos
		if pickup.has_method("set_tractor_target") and player:
			pickup.call("set_tractor_target", player)
		if pickup.has_signal("collected"):
			pickup.connect("collected", Callable(self, "_on_pickup_collected"))

func _on_pickup_collected(value: int) -> void:
	score += value
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
