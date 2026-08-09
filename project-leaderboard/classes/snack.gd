extends Interactable
class_name Snack

@export var id: String
@export var description: String

func on_interaction():
	hover_text = "Used"
	ConsumableManager.use_snack(id)
