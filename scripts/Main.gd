extends Node2D

## Корневая сцена: связывает HUD (полоску здоровья) с сигналами игрока.

@onready var health_bar: ProgressBar = $HUD/HealthBar


func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)
		player.died.connect(_on_player_died)


func _on_health_changed(current: int, max_hp: int) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current


func _on_player_died() -> void:
	# Полноценный экран Game Over добавим в Фазе 3 (структура забега).
	print("Игрок погиб — Game Over экран будет в Фазе 3")
