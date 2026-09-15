extends Node2D

## Корневая сцена: таймер забега, появление босса в конце, экран
## Game Over / Победа со статистикой, кнопка "заново".

const BOSS_SCENE := preload("res://scenes/Boss.tscn")
const BOSS_TIME := 60.0  # через сколько секунд появляется босс (потом можно увеличить)

@onready var health_bar: ProgressBar = $HUD/HealthBar
@onready var timer_label: Label = $HUD/TimerLabel
@onready var end_screen: CanvasLayer = $EndScreen
@onready var end_title: Label = $EndScreen/Center/VBox/Title
@onready var end_stats: Label = $EndScreen/Center/VBox/Stats
@onready var end_currency: Label = $EndScreen/Center/VBox/CurrencyEarned
@onready var restart_button: Button = $EndScreen/Center/VBox/RestartButton
@onready var menu_button: Button = $EndScreen/Center/VBox/MenuButton
@onready var enemy_spawner: Node = $EnemySpawner

var _elapsed: float = 0.0
var _boss_spawned: bool = false
var _run_over: bool = false


func _ready() -> void:
	Meta.start_run()  # обнуляем счётчик валюты забега (на случай запуска сцены напрямую из редактора)
	end_screen.visible = false
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)
		player.died.connect(_on_player_died)


func _process(delta: float) -> void:
	if _run_over:
		return
	_elapsed += delta
	timer_label.text = _format_time(_elapsed)
	if not _boss_spawned and _elapsed >= BOSS_TIME:
		_spawn_boss()


func _format_time(t: float) -> String:
	var m := int(t) / 60
	var s := int(t) % 60
	return "%d:%02d" % [m, s]


func _spawn_boss() -> void:
	_boss_spawned = true
	enemy_spawner.enabled = false
	# убираем оставшихся рядовых врагов — бой с боссом должен быть честным один на один
	for e in get_tree().get_nodes_in_group("enemies"):
		e.queue_free()

	var boss := BOSS_SCENE.instantiate()
	get_tree().current_scene.add_child(boss)
	var player := get_tree().get_first_node_in_group("player")
	boss.global_position = (player.global_position + Vector2(0, -320)) if player else Vector2.ZERO
	boss.defeated.connect(_on_boss_defeated)


func _on_health_changed(current: int, max_hp: int) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current


func _on_player_died() -> void:
	_show_end_screen("Ты погиб")


func _on_boss_defeated() -> void:
	_show_end_screen("Победа!")


func _show_end_screen(title: String) -> void:
	_run_over = true
	end_title.text = title
	end_stats.text = "Время забега: %s" % _format_time(_elapsed)
	end_currency.text = "Заработано эссенции: %d (всего: %d)" % [Meta.run_currency, Meta.currency]
	Meta.save_data()
	end_screen.visible = true
	get_tree().paused = true


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
