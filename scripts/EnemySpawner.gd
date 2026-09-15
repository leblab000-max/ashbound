extends Node2D

## Спавнит врагов по кругу вокруг игрока. Интервал спавна постепенно
## сокращается от initial_interval до min_interval за ramp_time секунд —
## это и есть "нарастающая сложность" забега (доделаем в Фазе 3).

const ENEMY_SCENE := preload("res://scenes/Enemy.tscn")

@export var spawn_radius: float = 420.0
@export var initial_interval: float = 1.6
@export var min_interval: float = 0.4
@export var ramp_time: float = 120.0

var _elapsed: float = 0.0
var _timer: float = 0.5  # первый враг появится почти сразу


func _process(delta: float) -> void:
	_elapsed += delta
	_timer -= delta
	if _timer <= 0.0:
		_spawn_enemy()
		var t: float = clamp(_elapsed / ramp_time, 0.0, 1.0)
		_timer = lerp(initial_interval, min_interval, t)


func _spawn_enemy() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var angle := randf() * TAU
	var offset := Vector2(cos(angle), sin(angle)) * spawn_radius
	var enemy := ENEMY_SCENE.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = player.global_position + offset
