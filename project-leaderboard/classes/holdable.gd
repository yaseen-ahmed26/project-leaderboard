extends Interactable
class_name Holdable

@export var delete_on_use: bool = true
@export var can_use: bool = true
@export var can_throw: bool = true
@export var carry_root: Node3D
@export var respawnable: bool = true
@export var respawn_marker: Marker3D

func _ready() -> void:
	super()
	
	if not respawn_marker and respawnable:
		push_warning("%s does not have a Respawn Marker" % id)

# Getters
func get_use_status():
	return can_use

func get_throw_status():
	return can_throw

func use_self():
	print("used: ", id)
