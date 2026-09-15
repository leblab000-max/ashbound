extends Area2D

## Снаряд оружия игрока: летит по прямой к точке, где был враг в момент
## выстрела. Поведение при попадании зависит от типа оружия (см. WeaponDB):
##   "single" — наносит урон одной цели и исчезает;
##   "pierce" — наносит урон и летит дальше, пока не кончится pierce_count;
##   "splash" — взрывается, наносит урон всем врагам в splash_radius.

const SPEED := 500.0
const LIFETIME := 2.0  # на случай, если ни во что не попал и не вышел за экран

var _velocity: Vector2 = Vector2.ZERO
var _damage: int = 10
var _life: float = LIFETIME
var _type: String = "single"
var _pierce_left: int = 1
var _splash_radius: float = 0.0
var _hit_enemies: Array = []  # чтобы pierce не бил одного и того же врага дважды


func setup(direction: Vector2, dmg: int, wtype: String = "single", pierce_count: int = 1, splash_radius: float = 0.0) -> void:
	_velocity = direction.normalized() * SPEED
	_damage = dmg
	_type = wtype
	_pierce_left = max(pierce_count, 1)
	_splash_radius = splash_radius
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	position += _velocity * delta
	_life -= delta
	if _life <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("enemies") or not body.has_method("take_damage"):
		return
	if body in _hit_enemies:
		return
	_hit_enemies.append(body)

	if _type == "splash":
		_apply_splash()
		queue_free()
		return

	body.take_damage(_damage)

	if _type == "pierce":
		_pierce_left -= 1
		if _pierce_left <= 0:
			queue_free()
		# иначе снаряд летит дальше и может пронзить ещё одного врага
	else:
		queue_free()


func _apply_splash() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if global_position.distance_to(enemy.global_position) <= _splash_radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(_damage)


func _on_screen_exited() -> void:
	queue_free()
