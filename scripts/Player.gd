extends CharacterBody2D

## Игрок: движение в 8 направлений (WASD или стрелки) + инвентарь оружия.
## Каждый предмет в инвентаре — отдельное авто-стреляющее оружие ("слот").
## Слияние (merge) двух одинаковых предметов происходит через InventoryUI (клик-swap).

@export var speed: float = 220.0
@export var max_health: int = 100

const INVENTORY_SIZE := 6

var health: int
var inventory: Array = []       # каждый элемент: null ИЛИ {"id": String, "tier": int}
var _slot_timers: Array = []    # таймер до следующего выстрела, параллельно inventory

signal health_changed(current: int, max_hp: int)
signal inventory_changed
signal died

const BULLET_SCENE := preload("res://scenes/Bullet.tscn")
const WeaponDB := preload("res://scripts/WeaponDB.gd")


func _ready() -> void:
	health = max_health
	add_to_group("player")
	health_changed.emit(health, max_health)

	inventory.resize(INVENTORY_SIZE)
	_slot_timers.resize(INVENTORY_SIZE)
	for i in INVENTORY_SIZE:
		inventory[i] = null
		_slot_timers[i] = 0.0

	add_weapon("blade")  # стартовое оружие


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
	for i in inventory.size():
		var item = inventory[i]
		if item == null:
			continue
		_slot_timers[i] -= delta
		if _slot_timers[i] > 0.0:
			continue
		var wrange: float = WeaponDB.weapon_range(item["id"], item["tier"])
		var target := _find_nearest_enemy(wrange)
		if target == null:
			continue
		_slot_timers[i] = WeaponDB.weapon_interval(item["id"], item["tier"])
		_fire_at(target, WeaponDB.weapon_damage(item["id"], item["tier"]))


func _find_nearest_enemy(max_range: float) -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nearest_dist := max_range
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist := global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest


func _fire_at(target: Node2D, damage: float) -> void:
	var bullet := BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.setup(target.global_position - global_position, int(round(damage)))


func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	health_changed.emit(health, max_health)
	if health <= 0:
		died.emit()
		queue_free()


## Добавляет оружие в первый свободный слот. Возвращает false, если инвентарь полон.
func add_weapon(id: String) -> bool:
	for i in INVENTORY_SIZE:
		if inventory[i] == null:
			inventory[i] = {"id": id, "tier": 1}
			_slot_timers[i] = 0.0
			inventory_changed.emit()
			return true
	return false


## Клик-swap: игрок выбрал слот from, потом слот to (см. InventoryUI.gd).
## Если оружие одинаковое и тир совпадает — сливаем в тир+1. Иначе — просто меняем местами.
func try_merge_or_move(from: int, to: int) -> void:
	if from == to:
		return
	var a = inventory[from]
	var b = inventory[to]
	if a == null:
		return

	if b == null:
		inventory[to] = a
		inventory[from] = null
		_slot_timers[to] = _slot_timers[from]
		_slot_timers[from] = 0.0
	elif b["id"] == a["id"] and b["tier"] == a["tier"] and b["tier"] < WeaponDB.MAX_TIER:
		inventory[to] = {"id": b["id"], "tier": b["tier"] + 1}
		inventory[from] = null
		_slot_timers[from] = 0.0
	else:
		inventory[from] = b
		inventory[to] = a
		var t = _slot_timers[from]
		_slot_timers[from] = _slot_timers[to]
		_slot_timers[to] = t

	inventory_changed.emit()
