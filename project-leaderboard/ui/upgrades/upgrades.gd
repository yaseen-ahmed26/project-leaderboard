extends SharedUI

@onready var btn_holder: VBoxContainer = $VBoxContainer
@onready var template_btn: Button = $VBoxContainer/template_btn

func _ready() -> void:
	super()
	
	_setup_btns()
	
func _setup_btns():
	var pool: Array[UpgradeData] = UpgradeManager.get_upgrade_pool()	
	
	for upgrade in pool:
		var clone = template_btn.duplicate()
		clone.show()
		
		var current_level: int = UpgradeManager.get_upgrade_level(upgrade.id)
		
		clone.text = "[%d] %s: %s" % [
			current_level,
			upgrade.display_name,
			upgrade.level_effects.get(current_level).get("description")
		]
		
		clone.name = upgrade.id
		clone.pressed.connect(_on_upgrade_btn_pressed.bind(clone, upgrade))
		
		btn_holder.add_child(clone)

func _refresh_btn(btn, upgrade: UpgradeData):
	var current_level: int = UpgradeManager.get_upgrade_level(btn.name)
	
	if current_level >= upgrade.total_levels:
		btn.text = "[MAX] %s: Maxed Out" % upgrade.display_name
		btn.disabled = true
	else:
		var next_effect = upgrade.level_effects[current_level]
		btn.text = "[%d] %s: %s" % [current_level, upgrade.display_name, next_effect.description]

func _on_upgrade_btn_pressed(btn: Button, upgrade: UpgradeData):
	var details = UpgradeManager.buy_upgrade(upgrade)
	
	if details[0]:
		_refresh_btn(btn, upgrade)
