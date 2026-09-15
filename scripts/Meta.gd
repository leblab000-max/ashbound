extends Node

## Автозагрузка (autoload-синглтон) "Meta": постоянная валюта и апгрейды,
## которые сохраняются МЕЖДУ забегами. Доступен из любого скрипта просто
## как "Meta" (без preload) — так работают автозагрузки в Godot.
## Сохранение — в user://save.json (обычный JSON-файл в папке пользователя).

signal currency_changed(total: int)

const SAVE_PATH := "user://save.json"

## Описание всех постоянных апгрейдов. per_level — либо доля (0.10 = +10%),
## либо абсолютное число (health/speed), в зависимости от апгрейда —
## смотри, где именно бонус применяется (Player.gd, Enemy.gd).
const UPGRADES := {
	"damage": {"name": "Урон", "desc": "+10% урона оружия", "base_cost": 20, "cost_growth": 1.6, "per_level": 0.10, "max_level": 5},
	"health": {"name": "Здоровье", "desc": "+20 макс. ХП", "base_cost": 15, "cost_growth": 1.5, "per_level": 20.0, "max_level": 5},
	"speed": {"name": "Скорость", "desc": "+15 скорости движения", "base_cost": 15, "cost_growth": 1.5, "per_level": 15.0, "max_level": 5},
	"range": {"name": "Дальность", "desc": "+8% дальности оружия", "base_cost": 20, "cost_growth": 1.6, "per_level": 0.08, "max_level": 5},
	"luck": {"name": "Удача", "desc": "+8% к шансу выпадения оружия", "base_cost": 15, "cost_growth": 1.5, "per_level": 0.08, "max_level": 5},
}

var currency: int = 0        # постоянная валюта, сохраняется на диск
var run_currency: int = 0    # заработано за ТЕКУЩИЙ забег (для экрана результатов)
var levels: Dictionary = {}  # {"damage": 0, "health": 0, ...}


func _ready() -> void:
	for key in UPGRADES.keys():
		levels[key] = 0
	load_data()


## Текущий суммарный бонус апгрейда key (level * per_level).
func get_bonus(key: String) -> float:
	var lvl: int = levels.get(key, 0)
	return UPGRADES[key]["per_level"] * lvl


func upgrade_cost(key: String) -> int:
	var lvl: int = levels.get(key, 0)
	var def = UPGRADES[key]
	return int(round(def["base_cost"] * pow(def["cost_growth"], lvl)))


func is_maxed(key: String) -> bool:
	return levels.get(key, 0) >= UPGRADES[key]["max_level"]


func buy_upgrade(key: String) -> bool:
	if is_maxed(key):
		return false
	var cost := upgrade_cost(key)
	if currency < cost:
		return false
	currency -= cost
	levels[key] += 1
	currency_changed.emit(currency)
	save_data()
	return true


## Вызывается при убийстве врага/босса — пополняет и постоянную валюту,
## и счётчик текущего забега (для итогового экрана).
func add_currency(amount: int) -> void:
	currency += amount
	run_currency += amount
	currency_changed.emit(currency)


## Сбрасывает счётчик забега. Main.gd вызывает это в начале каждого забега.
func start_run() -> void:
	run_currency = 0


func save_data() -> void:
	var data := {"currency": currency, "levels": levels}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()


func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	currency = int(parsed.get("currency", 0))
	var loaded_levels = parsed.get("levels", {})
	for key in UPGRADES.keys():
		if loaded_levels.has(key):
			levels[key] = int(loaded_levels[key])
