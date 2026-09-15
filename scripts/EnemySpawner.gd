extends Node2D

## Спавнит врагов по кругу вокруг игрока. Три вида с разными весами
## (грунт чаще всего, танк реже всего). Интервал спавна постепенно
## сокращается от initial_interval до min_interval за ramp_time секунд.
## Враги также становятся крепче и бьют больнее со временем (difficulty_mult) —
## иначе оружие игрока после пары слияний резко вырывается вперёд по силе.
## Main.gd выключает enabled, когда приходит время босса.

const ENEMY_SCENES := {
	"grunt": preload("res://scenes/Enemy.tscn"),
	"fast": preload("res://scenes/EnemyFast.tscn"),
	"tank": preload("res://scenes/EnemyTank.tscn"),
}
const WEIGHTS := {"grunt": 5, "fast": 3, "tank": 1}

@export var spawn_radius: float = 420.0
@export var initial_interval: float = 1.6
@export var min_interval: float = 0.4
@export var ramp_time: float = 60.0
@export var difficulty_per_minute: float = 0.7  # +70% к хп/урону врагов за минуту

var enabled: bool = true

var _elapsed: float = 0.0
var _timer: float = 0.5  # первый враг появится почти сразу


func _process(delta: float) -> void:
	if not enabled:
		return
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
	var scene: PackedScene = ENEMY_SCENES[_pick_weighted()]
	var enemy := scene.instantiate()

	var difficulty := 1.0 + (_elapsed / 60.0) * difficulty_per_minute
	enemy.max_health = int(round(enemy.max_health * difficulty))
	enemy.contact_damage = int(round(enemy.contact_damage * difficulty))

	get_tree().current_scene.add_child(enemy)
	enemy.global_position = player.global_position + offset


func _pick_weighted() -> String:
	var total := 0
	for w in WEIGHTS.values():
		total += w
	var roll := randi() % total
	var acc := 0
	for key in WEIGHTS.keys():
		acc += WEIGHTS[key]
		if roll < acc:
			return key
	return "grunt"
