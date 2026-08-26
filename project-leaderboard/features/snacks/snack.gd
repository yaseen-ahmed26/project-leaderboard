extends Holdable
class_name Snack

## The SnackData associated with this scene.
@export var snack_data: SnackData

func _ready() -> void:
	super()
	
	Signals.snack_used.connect(_on_snack_used)

func on_interaction():
	var label = get_node_or_null("Label3D")
	
	if label: label.visible = false

func use_self():
	var _success = ConsumableManager.use_snack(snack_data)
	return delete_on_use
	
func _on_snack_used(_snack_data: SnackData):
	can_interact = false
