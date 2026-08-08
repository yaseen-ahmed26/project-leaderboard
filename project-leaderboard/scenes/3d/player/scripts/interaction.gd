extends Node3D

@onready var raycast: RayCast3D = $Camera3D/RayCast3D
@onready var hud: Control = $"../hud"

var current_raycast_hit: Interactable 

func _physics_process(_delta: float) -> void:
	if raycast.is_colliding():
		var hit_object = raycast.get_collider()
		var _hit_point = raycast.get_collision_point()
		
		var parent = hit_object.get_parent()
		
		if parent.is_in_group("Interactables"):
			current_raycast_hit = parent
			hud.call("show_hover_prompt", parent.get_hover_text())
	else:
		hud.call("hide_hover_prompt")
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if current_raycast_hit.name == "main_monitor": return
		
		if current_raycast_hit.has_method("on_interaction"):
			current_raycast_hit.call("on_interaction")
