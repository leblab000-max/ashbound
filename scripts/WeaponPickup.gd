extends Area2D

## Предмет оружия на земле. Игрок подбирает касанием — уходит в первый
## свободный слот инвентаря (Player.add_weapon). Если инвентарь полон,
## предмет остаётся лежать (просто попробует ещё раз при следующем касании).

const WeaponDB := preload("res://scripts/WeaponDB.gd")

var weapon_id: String = "blade"


func setup(id: String) -> void:
	weapon_id = id


func _ready() -> void:
	$Visual.color = WeaponDB.weapon_color(weapon_id)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("add_weapon"):
		if body.add_weapon(weapon_id):
			queue_free()
