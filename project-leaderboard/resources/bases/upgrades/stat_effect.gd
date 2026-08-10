extends UpgradeEffect
class_name StatEffect

enum Operation {ADD, SUBTRACT, DIVIDE, MULTIPLY, SET} 

@export var operation: Operation = Operation.ADD
@export var stat: String
@export_range(0, 10, 0.1) var value: float

func get_operation():
	return Operation.keys()[operation].to_lower()
