extends CharacterBody2D

## Дальний враг: держится на расстоянии preferred_distance от игрока
## (подходит, если слишком далеко, отступает, если слишком близко) и
## стреляет снарядом раз в contact_interval секунд. Первый враг, который
## реально угрожает игроку на дистанции — раньше все враги были только
## контактными, из-за чего оружие дальнего боя игрока не встречало сопротивления.

@export var speed: float = 70.0
@export var max_health: int = 20
@export var contact_damage: int = 10        # урон одного снаряда
@export var contact_interval: float = 1.6   # интервал стрельбы
@export var preferred_distance: float = 220.0
@export var drop_chance: float = 0.4
@export var currency_drop: int = 2

const WEAPON_PICKUP_SCENE := preload("res://scenes/WeaponPickup.tscn")
const ENEMY_BULLET_SCENE := preload("res://scenes/EnemyBullet.tscn")
const WeaponDB := preload("res://scripts/WeaponDB.gd")

var health: int
var _player: Node2D = null
var _hit_timer: float = 0.0


func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	_player = get_tree().get_first_node_in_group("player")
	drop_chance = clamp(drop_chance * (1.0 + Meta.get_bonus("luck")), 0.0, 1.0)


func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
		return

	var to_player := _player.global_position - global_position
	var dist := to_player.length()
	var dir := to_player.normalized() if dist > 0.001 else Vector2.ZERO

	if dist > preferred_distance + 20.0:
		velocity = dir * speed
	elif dist < preferred_distance - 20.0:
		velocity = -dir * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

	_hit_timer -= delta
	if _hit_timer <= 0.0 and dist <= preferred_distance + 40.0:
		_shoot()
		_hit_timer = contact_interval


func _shoot() -> void:
	var bullet := ENEMY_BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.setup(_player.global_position - global_position, contact_damage)


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		Meta.add_currency(currency_drop)
		_drop_weapon()
		queue_free()


func _drop_weapon() -> void:
	if randf() > drop_chance:
		return
	var pickup := WEAPON_PICKUP_SCENE.instantiate()
	pickup.setup(WeaponDB.random_id())
	get_tree().current_scene.add_child(pickup)
	pickup.global_position = global_position
