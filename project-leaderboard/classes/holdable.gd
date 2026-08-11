extends Interactable
class_name Holdable

@export var delete_on_use: bool = true

func use_self():
	print("used: ", id)
