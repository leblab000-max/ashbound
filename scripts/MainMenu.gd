extends Control

## Главное меню: показывает постоянную валюту, список апгрейдов для покупки
## (динамически строится из Meta.UPGRADES) и кнопку "Начать забег".

@onready var currency_label: Label = $Center/VBox/CurrencyLabel
@onready var upgrades_box: VBoxContainer = $Center/VBox/UpgradesBox
@onready var start_button: Button = $Center/VBox/StartButton

var _upgrade_rows: Dictionary = {}  # key -> {"label": Label, "button": Button}


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	Meta.currency_changed.connect(_on_currency_changed)
	_build_upgrades()
	_refresh_all()


func _build_upgrades() -> void:
	for key in Meta.UPGRADES.keys():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)

		var label := Label.new()
		label.custom_minimum_size = Vector2(300, 0)
		row.add_child(label)

		var button := Button.new()
		button.custom_minimum_size = Vector2(140, 36)
		button.pressed.connect(_on_buy_pressed.bind(key))
		row.add_child(button)

		upgrades_box.add_child(row)
		_upgrade_rows[key] = {"label": label, "button": button}


func _refresh_all() -> void:
	currency_label.text = "Эссенция: %d" % Meta.currency
	for key in Meta.UPGRADES.keys():
		_refresh_row(key)


func _refresh_row(key: String) -> void:
	var def = Meta.UPGRADES[key]
	var lvl: int = Meta.levels.get(key, 0)
	var row = _upgrade_rows[key]
	row["label"].text = "%s (ур. %d/%d) — %s" % [def["name"], lvl, def["max_level"], def["desc"]]
	if Meta.is_maxed(key):
		row["button"].text = "Макс."
		row["button"].disabled = true
	else:
		var cost := Meta.upgrade_cost(key)
		row["button"].text = "Купить (%d)" % cost
		row["button"].disabled = Meta.currency < cost


func _on_buy_pressed(key: String) -> void:
	if Meta.buy_upgrade(key):
		_refresh_all()


func _on_currency_changed(_total: int) -> void:
	_refresh_all()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
