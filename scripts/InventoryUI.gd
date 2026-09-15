extends Control

## Сетка инвентаря внизу слева. Клик-swap вместо мышиного drag&drop:
## кликаешь по предмету (выделяется), кликаешь по второму слоту —
## если оружие и тир совпадают, они сливаются в следующий тир,
## иначе просто меняются местами. Клик по тому же слоту — снять выделение.

const SLOT_SIZE := Vector2(56, 56)
const SLOT_GAP := 6.0
const COLUMNS := 3
const WeaponDB := preload("res://scripts/WeaponDB.gd")

var _player: Node = null
var _slots: Array = []  # Button-узлы
var _selected: int = -1


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	_build_slots()
	if _player:
		_player.inventory_changed.connect(_refresh)
		_refresh()


func _build_slots() -> void:
	var count: int = _player.INVENTORY_SIZE if _player else 6
	for i in count:
		var btn := Button.new()
		btn.custom_minimum_size = SLOT_SIZE
		var col := i % COLUMNS
		@warning_ignore("integer_division")
		var row := i / COLUMNS
		btn.position = Vector2(col * (SLOT_SIZE.x + SLOT_GAP), row * (SLOT_SIZE.y + SLOT_GAP))
		btn.pressed.connect(_on_slot_pressed.bind(i))
		add_child(btn)
		_slots.append(btn)


func _refresh() -> void:
	if _player == null:
		return
	for i in _slots.size():
		var item = _player.inventory[i]
		var btn: Button = _slots[i]
		var label: String
		if item == null:
			label = "—"
			btn.modulate = Color(1, 1, 1, 0.35)
		else:
			label = "%s\nT%d" % [WeaponDB.weapon_name(item["id"]), item["tier"]]
			btn.modulate = WeaponDB.weapon_color(item["id"])
		if i == _selected:
			label = "[%s]" % label
		btn.text = label


func _on_slot_pressed(i: int) -> void:
	if _selected == -1:
		if _player.inventory[i] != null:
			_selected = i
	elif _selected == i:
		_selected = -1
	else:
		_player.try_merge_or_move(_selected, i)
		_selected = -1
	_refresh()
