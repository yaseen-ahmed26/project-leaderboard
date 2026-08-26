extends Node

@export var base_available_upgrades: Array[UpgradeData]

var upgrade_levels: Dictionary = {}

func _ready():
	for upgrade in base_available_upgrades:
		upgrade_levels[upgrade.id] = 0

func buy_upgrade(upgrade: UpgradeData):
	var current_level = get_upgrade_level(upgrade.id)
	
	if current_level >= upgrade.total_levels: 
		print("Upgrade maxed or exceeds current max: ", current_level)
		return [false]
	
	var level_data: UpgradeEffect = upgrade.level_effects.get(current_level)

	if PlayerManager.purchase(level_data.cost):
		upgrade_levels[upgrade.id] += 1
		
		if level_data is UpgradeStatBuff:
			level_data.apply_effect()
		
		return [true, level_data]
	
	return [false]

func get_upgrade_pool():
	return base_available_upgrades

func get_upgrade_level(id: String):
	if not upgrade_levels.has(id): return 0
	
	return upgrade_levels.get(id)
