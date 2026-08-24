extends Node3D

# Onready
@onready var raycast: RayCast3D = $camera/raycast
@onready var hud: Control = $"../CanvasLayer/hud"
@onready var hand_marker: Marker3D = $camera/hand_marker
@onready var camera: Camera3D = $camera

# The current object being looked at
var current_interactable_object: Interactable 
# The current item being held
var current_held_item: Holdable = null

func _physics_process(_delta: float) -> void:
	# Check if the raycast is hitting anything
	if raycast.is_colliding():
		# Get the CollisionObject3D the Raycast is hitting
		var interactable_object = raycast.get_collider()
		
		# If there is none, do nothing
		if not interactable_object or interactable_object == null: return
		if not interactable_object.get_interact_status(): return
		
		# If the item we're looking at is an Interactable
		if interactable_object.is_in_group("Interactables"):
			# If it cannot be interacted with, do nothing
			if not interactable_object.get_interact_status(): return
			
			# Set the object we're looking at to the current object
			current_interactable_object = interactable_object
			
			# If we're holding an item and that is the one the object we're looking at needs
			if current_held_item and current_interactable_object.get_item_needed() == current_held_item.id:
				hud.call("show_hover_prompt", "[LMB] Use %s on %s" % [
					current_held_item.display_name, 
					current_interactable_object.display_name
				])
			# Otherwise just show the normal prompt
			else:
				hud.call("show_hover_prompt", current_interactable_object.get_hover_text())
	else:
		# Hide the HUD and clear current object
		current_interactable_object = null
		hud.call("hide_hover_prompt")
	
func _unhandled_input(event: InputEvent) -> void:
	# If the player clicks E
	if event.is_action_pressed("interact"):
		# If we're not looking at anything, do nothing
		if not current_interactable_object: return
		if not current_interactable_object.get_interact_status(): return
		
		# If the current object we're looking at can be picked up and we're not holding anything
		if current_interactable_object is Holdable and current_held_item == null:
			pick_up_item(current_interactable_object as Holdable)
		# Otherwise just call the interaction function on the object
		elif current_interactable_object.has_method("on_interaction"):
			current_interactable_object.call("on_interaction")
	
	# If the player left clicks
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not current_held_item: return
		if not current_held_item.get_use_status(): return
		
		use_held_item()
			
	# Drop item
	if event.is_action_pressed("action_drop") and current_held_item:
		drop_held_item()
		
	# Throw item
	if event.is_action_pressed("action_throw") and current_held_item:
		throw_held_item()

func pick_up_item(item: Holdable) -> void:
	# Set the item we're picking up as the current
	current_held_item = item
	
	# Disable collisions if the item has one
	if item is CollisionObject3D:
		item.process_mode = PROCESS_MODE_DISABLED
		
		if (item as Node) is RigidBody3D:
			item.freeze = true
			
	if item.has_method("on_interaction"):
		item.on_interaction()
	
	item.get_parent().remove_child(item)
	hand_marker.add_child(item)
	item.transform = Transform3D.IDENTITY
	
	hud.call("show_controls", item.display_name)

func use_held_item() -> void:
	var item_consumed: bool = false
	
	# If we're looking at an object and we're holding the item it needs
	if current_interactable_object and current_interactable_object.get_item_needed() == current_held_item.id:
		# Check whether to destroy the item once used.
		item_consumed = current_interactable_object.on_item_used(current_held_item)
	else:
		item_consumed = current_held_item.use_self()
		
	if item_consumed:
		consume_held_item()

func consume_held_item() -> void:
	if current_held_item:
		current_held_item.queue_free()
		current_held_item = null
		hud.call("hide_controls")

func drop_held_item() -> void:
	var item = current_held_item
	current_held_item = null
	hud.call("hide_controls")
	
	hand_marker.remove_child(item)
	get_tree().current_scene.add_child(item)
	
	item.global_position = hand_marker.global_position
	
	_enable_item_physics(item)
	
	var forward: Vector3 = -camera.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	
	var rb: RigidBody3D = (item as Node) as RigidBody3D
	if rb:
		rb.linear_velocity = owner.velocity + (forward * Constants.DROP_SPEED)

func throw_held_item() -> void:
	var item = current_held_item
	current_held_item = null
	hud.call("hide_controls")
	
	hand_marker.remove_child(item)
	get_tree().current_scene.add_child(item)
	
	item.global_position = hand_marker.global_position
	_enable_item_physics(item)
	
	var rb: RigidBody3D = (item as Node) as RigidBody3D
	
	if rb:
		var throw_direction = -camera.global_transform.basis.z.normalized()
		
		rb.linear_velocity = owner.velocity
		rb.apply_central_impulse(throw_direction * Constants.THROW_FORCE)
		
		var spin: Vector3 = camera.global_transform.basis.x * randf_range(Constants.THROW_SPIN_MIN, Constants.THROW_SPIN_MAX)
		rb.apply_torque_impulse(spin)

func _enable_item_physics(item: Holdable) -> void:
	item.process_mode = PROCESS_MODE_INHERIT
	
	if (item as Node) is RigidBody3D:
		item.freeze = false
		item.linear_velocity = Vector3.ZERO
		item.angular_velocity = Vector3.ZERO
