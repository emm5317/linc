extends Area2D

signal expired()

@export var speed := 900.0
@export var lifetime := 1.2

var _direction := Vector2.RIGHT
var _age := 0.0

func _ready() -> void:
	add_to_group(GameGlobals.GROUP_BULLET)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	_age += delta
	global_position += _direction * speed * delta
	if _age >= lifetime:
		emit_signal("expired")
		queue_free()

func setup(direction: Vector2) -> void:
	_direction = direction.normalized()
	rotation = _direction.angle()

func _on_body_entered(body: Node) -> void:
	if body and body.is_in_group(GameGlobals.GROUP_ASTEROID) and body.has_method("pop"):
		body.call("pop")
	emit_signal("expired")
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area and area.is_in_group(GameGlobals.GROUP_ASTEROID) and area.has_method("pop"):
		area.call("pop")
	emit_signal("expired")
	queue_free()
