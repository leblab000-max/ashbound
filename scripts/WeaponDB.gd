extends RefCounted
class_name WeaponDB

## Общий справочник оружия: базовые характеристики + как они растут с тиром.
## Пока 3 вида для проверки механики, остальные добавим в Фазе 5 (контент-пасс).
##
## Названия функций начинаются с "weapon_", чтобы не пересекаться со
## встроенными методами движка (например, Object уже имеет get_name()).

const MAX_TIER := 3

const WEAPONS := {
	"blade": {"name": "Клинок", "color": Color(0.85, 0.85, 0.92), "base_damage": 8.0, "base_interval": 0.4, "base_range": 140.0},
	"wand":  {"name": "Посох",  "color": Color(0.42, 0.68, 1.0),  "base_damage": 14.0, "base_interval": 0.9, "base_range": 260.0},
	"axe":   {"name": "Топор",  "color": Color(1.0, 0.5, 0.2),    "base_damage": 22.0, "base_interval": 1.3, "base_range": 90.0},
}

const TIER_DAMAGE_MULT := 1.7
const TIER_INTERVAL_MULT := 0.82
const TIER_RANGE_MULT := 0.15


static func weapon_damage(id: String, tier: int) -> float:
	return WEAPONS[id]["base_damage"] * pow(TIER_DAMAGE_MULT, tier - 1)


static func weapon_interval(id: String, tier: int) -> float:
	return WEAPONS[id]["base_interval"] * pow(TIER_INTERVAL_MULT, tier - 1)


static func weapon_range(id: String, tier: int) -> float:
	return WEAPONS[id]["base_range"] * (1.0 + TIER_RANGE_MULT * (tier - 1))


static func weapon_color(id: String) -> Color:
	return WEAPONS[id]["color"]


static func weapon_name(id: String) -> String:
	return WEAPONS[id]["name"]


static func random_id() -> String:
	var keys := WEAPONS.keys()
	return keys[randi() % keys.size()]
