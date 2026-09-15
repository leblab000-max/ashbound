extends CharacterBody2D

## Босс забега: появляется один раз в конце (Main.gd решает когда).
## Логика движения та же, что у обычных врагов, но отдельным файлом —
## так понятнее читать и проще менять баланс босса отдельно от рядовых.

@export var speed: float = 60.0
@export var max_health: int = 400
@export var contact_damage: int = 20
@export var contact_interval: float = 0.8
@export var contact_distance: float = 40.0
@export var currency_drop: int = 15

var health: int
var _player: Node2D = null
var _hit_timer: float = 0.0

signal defeated


func _ready() -> void:
	add_to_group("enemies")  # чтобы оружие игрока видело босса как цель
	health = max_health
	_player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
		return

	var dir := (_player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()

	_hit_timer -= delta
	if _hit_timer <= 0.0 and global_position.distance_to(_player.global_position) < contact_distance:
		if _player.has_method("take_damage"):
			_player.take_damage(contact_damage)
		_hit_timer = contact_interval


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		Meta.add_currency(currency_drop)
		defeated.emit()
		queue_free()
