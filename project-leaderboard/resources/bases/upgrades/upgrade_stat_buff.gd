extends UpgradeEffect
class_name UpgradeStatBuff

enum Manager {
	PLAYER, 
	CLICKER
}
enum Operation {
	ADD, 
	SUBTRACT, 
	DIVIDE, 
	MULTIPLY, 
	SET
}

@export var target: Manager
@export var operation: Operation
@export var stat_name: Globals.Stats
@export var value: float

func apply_effect() -> void:
	var package: Dictionary = {
		"operation": get_operation(),
		"value": value,
		"stat": Globals.get_lower_stat(stat_name)
	}
	
	match target:
		Manager.PLAYER:
			PlayerManager.edit_stat(package)
		Manager.CLICKER:
			ClickerManager.edit_stat(package)
			
func get_operation():
	return Operation.keys()[operation].to_lower()
