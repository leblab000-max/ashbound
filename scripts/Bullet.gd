extends Area2D

## Простой снаряд оружия игрока: летит по прямой к точке, где был враг
## в момент выстрела, при попадании наносит урон и исчезает.

const SPEED := 500.0
const LIFETIME := 2.0  # на случай, если ни во что не попал и не вышел за экран

var _velocity: Vector2 = Vector2.ZERO
var _damage: int = 10
var _life: float = LIFETIME


func setup(direction: Vector2, dmg: int) -> void:
	_velocity = direction.normalized() * SPEED
	_damage = dmg
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	position += _velocity * delta
	_life -= delta
	if _life <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(_damage)
		queue_free()


func _on_screen_exited() -> void:
	queue_free()
