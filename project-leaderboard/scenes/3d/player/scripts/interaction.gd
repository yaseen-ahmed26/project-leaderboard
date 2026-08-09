extends Node3D

@onready var raycast: RayCast3D = $Camera3D/RayCast3D
@onready var hud: Control = $"../hud"

var current_raycast_hit: Interactable 

func _physics_process(_delta: float) -> void:
	if raycast.is_colliding():
		var hit_object = raycast.get_collider()
		var _hit_point = raycast.get_collision_point()
		
		if not hit_object or hit_object == null: return
		
		if hit_object.is_in_group("Interactables"):
			if not hit_object.get_interact_status(): return
			
			current_raycast_hit = hit_object
			hud.call("show_hover_prompt", hit_object.get_hover_text())
	else:
		current_raycast_hit = null
		hud.call("hide_hover_prompt")
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):	
		if not current_raycast_hit: return
		
		if current_raycast_hit.has_method("on_interaction"):
			current_raycast_hit.call("on_interaction")
