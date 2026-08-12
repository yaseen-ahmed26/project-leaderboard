extends Interactable

func on_interaction():
	call_owner_method()
	queue_free()
