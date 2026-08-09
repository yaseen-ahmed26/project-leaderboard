extends Interactable

func _ready() -> void:
	super()
	
func on_interaction():
	queue_free()
