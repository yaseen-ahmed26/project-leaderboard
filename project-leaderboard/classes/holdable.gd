extends Interactable
class_name Holdable

@export var delete_on_use: bool = true
@export var can_use: bool = true
@export var carry_root: Node3D

# Getters
func get_use_status():
	return can_use

func use_self():
	print("used: ", id)
