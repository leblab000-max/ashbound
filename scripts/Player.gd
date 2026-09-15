extends CharacterBody2D

## Игрок: движение в 8 направлений (WASD или стрелки) + авто-атака ближайшего врага.
## Ничего не нужно нажимать для атаки — оружие само целится и стреляет по таймеру.

@export var speed: float = 220.0
@export var max_health: int = 100
@export var attack_interval: float = 0.6  # как часто атакуем, сек
@export var attack_damage: int = 10
@export var attack_range: float = 260.0

var health: int
var _attack_timer: float = 0.0

signal health_changed(current: int, max_hp: int)
signal died

const BULLET_SCENE := preload("res://scenes/Bullet.tscn")


func _ready() -> void:
	health = max_health
	add_to_group("player")
	health_changed.emit(health, max_health)


func _physics_process(delta: float) -> void:
	_handle_movement()
	_handle_auto_attack(delta)


func _handle_movement() -> void:
	var dir := _get_input_vector()
	velocity = dir.normalized() * speed
	move_and_slide()


# Читаем клавиши напрямую (WASD + стрелки), без настройки Input Map —
# так проще для прототипа. Позже можно перевести на project settings > Input Map.
func _get_input_vector() -> Vector2:
	var v := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		v.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		v.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		v.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		v.y += 1.0
	return v


func _handle_auto_attack(delta: float) -> void:
	_attack_timer -= delta
	if _attack_timer > 0.0:
		return
	var target := _find_nearest_enemy()
	if target == null:
		return
	_attack_timer = attack_interval
	_fire_at(target)


func _find_nearest_enemy() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nearest_dist := attack_range
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist := global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest


func _fire_at(target: Node2D) -> void:
	var bullet := BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.setup(target.global_position - global_position, attack_damage)


func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	health_changed.emit(health, max_health)
	if health <= 0:
		died.emit()
		queue_free()
