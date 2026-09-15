extends CharacterBody2D

## Босс забега: появляется один раз в конце (Main.gd решает когда и
## масштабирует max_health/contact_damage/ranged_damage под сложность забега,
## как это делает EnemySpawner для рядовых врагов).
##
## Помимо контактного удара умеет стрелять на дистанции (как EnemyShooter) —
## раньше босс бил только в упор, и дальнобойный игрок убивал его, ни разу
## не получив урона (баг баланса, отмеченный на плейтесте в Фазе 3-5).

@export var speed: float = 60.0
@export var max_health: int = 550
@export var contact_damage: int = 22
@export var contact_interval: float = 0.7
@export var contact_distance: float = 40.0
@export var ranged_damage: int = 14
@export var ranged_interval: float = 2.2
@export var ranged_min_distance: float = 90.0  # стреляет, только если игрок дальше контактной дистанции
@export var currency_drop: int = 15

const ENEMY_BULLET_SCENE := preload("res://scenes/EnemyBullet.tscn")

var health: int
var _player: Node2D = null
var _hit_timer: float = 0.0
var _ranged_timer: float = 1.2  # первый залп чуть позже, чтобы дать игроку сориентироваться

signal defeated


func _ready() -> void:
	add_to_group("enemies")  # чтобы оружие игрока видело босса как цель
	health = max_health
	_player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
		return

	var to_player := _player.global_position - global_position
	var dist := to_player.length()
	var dir := to_player.normalized() if dist > 0.001 else Vector2.ZERO
	velocity = dir * speed
	move_and_slide()

	_hit_timer -= delta
	if _hit_timer <= 0.0 and dist < contact_distance:
		if _player.has_method("take_damage"):
			_player.take_damage(contact_damage)
		_hit_timer = contact_interval

	_ranged_timer -= delta
	if _ranged_timer <= 0.0 and dist >= ranged_min_distance:
		_shoot()
		_ranged_timer = ranged_interval


func _shoot() -> void:
	var bullet := ENEMY_BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.setup(_player.global_position - global_position, ranged_damage)


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		Meta.add_currency(currency_drop)
		defeated.emit()
		queue_free()
