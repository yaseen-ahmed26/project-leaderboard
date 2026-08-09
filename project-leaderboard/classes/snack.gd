extends Interactable
class_name Snack

@export var id: String
@export var description: String

func _ready() -> void:
	super()

func on_interaction():
	if ConsumableManager.used_snack: 
		return
	
	hover_text = "Used"
	ConsumableManager.use_snack(id)
