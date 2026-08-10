extends Interactable
class_name Snack

## The SnackData associated with this scene.
@export var snack_data: SnackData

func _ready() -> void:
	super()

func on_interaction():
	var success = ConsumableManager.use_snack(snack_data)
	
	if success:
		hover_text = "Used"
	else:
		hover_text = "Cannot use snack"
