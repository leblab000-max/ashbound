extends CharacterBody2D

## Враг: идёт напрямую к игроку, при контакте наносит урон раз в contact_interval
## секунд. При смерти с шансом drop_chance роняет предмет оружия для мерджа.

@export var speed: float = 90.0
@export var max_health: int = 30
@export var contact_damage: int = 8
@export var contact_interval: float = 1.0
@export var contact_distance: float = 26.0
@export var drop_chance: float = 0.5

const WEAPON_PICKUP_SCENE := preload("res://scenes/WeaponPickup.tscn")
const WeaponDB := preload("res://scripts/WeaponDB.gd")

var health: int
var _player: Node2D = null
var _hit_timer: float = 0.0


func _ready() -> void:
	add_to_group("enemies")
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
		_drop_weapon()
		queue_free()


func _drop_weapon() -> void:
	if randf() > drop_chance:
		return
	var pickup := WEAPON_PICKUP_SCENE.instantiate()
	pickup.setup(WeaponDB.random_id())
	get_tree().current_scene.add_child(pickup)
	pickup.global_position = global_position
