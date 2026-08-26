extends SnackEffect
class_name SnackCallMethod

@export var autoload_name: String
@export var method_name: String
@export var arguments: Array

func apply_effect() -> void:
	# Get the Autoload from the scene tree
	var target = Engine.get_main_loop().root.get_node_or_null(autoload_name)
	
	if target and target.has_method(method_name):
		# callv calls the method and unpacks the array into arguments
		target.callv(method_name, arguments)
	else:
		push_warning("Snack Error: Could not call '%s' on '%s'" % [method_name, autoload_name])
