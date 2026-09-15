extends RefCounted

## Общий справочник оружия: базовые характеристики + как они растут с тиром.
## 6 видов оружия с разным поведением снаряда (type):
##   "single" — обычный снаряд, поражает одну цель;
##   "pierce" — пронзает несколько врагов подряд (pierce_count);
##   "splash" — взрывается при попадании, задевает всех в радиусе (splash_radius).
##
## Названия функций начинаются с "weapon_", чтобы не пересекаться со
## встроенными методами движка (например, Object уже имеет get_name()).
##
## Специально БЕЗ class_name — подключается через preload() в каждом файле,
## который им пользуется. Так Godot не нужно переиндексировать глобальные
## классы при каждой правке (это и вызывало ошибки "not found in base").

const MAX_TIER := 3

const WEAPONS := {
	"blade":  {"name": "Клинок", "color": Color(0.85, 0.85, 0.92), "base_damage": 8.0,  "base_interval": 0.4,  "base_range": 140.0, "type": "single"},
	"wand":   {"name": "Посох",  "color": Color(0.42, 0.68, 1.0),  "base_damage": 14.0, "base_interval": 0.9,  "base_range": 260.0, "type": "single"},
	"axe":    {"name": "Топор",  "color": Color(1.0, 0.5, 0.2),    "base_damage": 22.0, "base_interval": 1.3,  "base_range": 90.0,  "type": "single"},
	"bow":    {"name": "Лук",    "color": Color(0.55, 0.85, 0.35), "base_damage": 10.0, "base_interval": 1.0,  "base_range": 300.0, "type": "pierce", "pierce_count": 3},
	"staff":  {"name": "Жезл",   "color": Color(0.85, 0.3, 0.85),  "base_damage": 9.0,  "base_interval": 1.1,  "base_range": 200.0, "type": "splash", "splash_radius": 70.0},
	"dagger": {"name": "Кинжал", "color": Color(0.95, 0.85, 0.2),  "base_damage": 4.0,  "base_interval": 0.22, "base_range": 100.0, "type": "single"},
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


static func weapon_type(id: String) -> String:
	return WEAPONS[id].get("type", "single")


static func weapon_pierce_count(id: String) -> int:
	return WEAPONS[id].get("pierce_count", 1)


static func weapon_splash_radius(id: String) -> float:
	return WEAPONS[id].get("splash_radius", 0.0)


static func random_id() -> String:
	var keys := WEAPONS.keys()
	return keys[randi() % keys.size()]
