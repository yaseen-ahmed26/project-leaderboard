extends Control

const COSTS = {
	"bonus": 5.0,
	"milestone": 3.0,
	"increment": 1.5,
}

func _ready() -> void:
	for btn in $VBoxContainer.get_children():
		btn.pressed.connect(_on_upgrade_btn_pressed.bind(btn))

func _on_upgrade_btn_pressed(btn: Button):
	PlayerManager.parse_upgrade(btn.name, COSTS.get(btn.name))
