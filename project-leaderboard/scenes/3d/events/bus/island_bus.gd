extends Node3D

func _ready() -> void:
	$AnimationPlayer.play("bus_enter")
	# play SFX
	
func lampost_moved():
	$AnimationPlayer.play("bus_leave")
