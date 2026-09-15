extends Area2D

## Снаряд врага-стрелка (EnemyShooter): летит по прямой, наносит урон
## игроку при попадании. Отдельный от Bullet.gd файл — чтобы случайно
## не перепутать "чей" это снаряд (враг бьёт по группе "player").

const SPEED := 260.0
const LIFETIME := 3.0

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
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(_damage)
		queue_free()


func _on_screen_exited() -> void:
	queue_free()
