extends Interactable

func on_interaction():	
	queue_free()
	owner.call("lampost_moved")
