extends Node3D

@onready var raycast: RayCast3D = $Camera3D/RayCast3D

var current_raycast_hit: Variant 

func _physics_process(delta: float) -> void:
	if raycast.is_colliding():
		var hit_object = raycast.get_collider()
		var hit_point = raycast.get_collision_point()
		var parent: MeshInstance3D = hit_object.get_parent()
		
		if parent.is_in_group("Interactables"):
			current_raycast_hit = parent

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if current_raycast_hit.has_method("on_interaction"):
			current_raycast_hit.call("on_interaction")
