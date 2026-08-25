extends Node3D

# Onready
@onready var raycast: RayCast3D = $camera/raycast
@onready var hud: Control = $"../CanvasLayer/hud"
@onready var hand_marker: Marker3D = $camera/hand_marker
@onready var camera: Camera3D = $camera

const OUTLINE_MAT: ShaderMaterial = preload("res://shaders/interactable_outline.tres")

# The current object being looked at
var current_interactable_object: Interactable 
# The current item being held
var current_held_item: Holdable = null

func _physics_process(_delta: float) -> void:
	if raycast.is_colliding():
		var interactable_object = raycast.get_collider()
		
		if not interactable_object:
			_clear_highlight_and_prompt()
			return
		
		# If the item we're looking at is a valid Interactable
		if interactable_object.is_in_group("Interactables") and interactable_object.get_interact_status():
			# If we started looking at a new object, switch the outline
			if current_interactable_object != interactable_object:
				_set_object_highlight(current_interactable_object, false)
				current_interactable_object = interactable_object
				_set_object_highlight(current_interactable_object, true)

			if current_held_item and current_interactable_object.get_item_needed() == current_held_item.id:
				hud.call("show_hover_prompt", "[LMB] Use %s on %s" % [
					current_held_item.display_name, 
					current_interactable_object.display_name
				])
			else:
				hud.call("show_hover_prompt", current_interactable_object.get_hover_text())
			return

	# Raycast hit nothing or an invalid object
	_clear_highlight_and_prompt()
	
func _unhandled_input(event: InputEvent) -> void:
	# If the player clicks E
	if event.is_action_pressed("interact"):
		# If we're not looking at anything, do nothing
		if not current_interactable_object: return
		if not current_interactable_object.get_interact_status(): return
		
		# If the current object we're looking at can be picked up and we're not holding anything
		if current_interactable_object is Holdable and current_held_item == null:
			pick_up_item(current_interactable_object as Holdable)
			current_interactable_object.call("on_interaction")
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
		if not current_held_item.get_throw_status(): return

		throw_held_item()

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

func pick_up_item(item: Holdable) -> void:
	current_held_item = item
	_set_object_highlight(item, false)
	var body: Node3D = item.carry_root if item.carry_root else item
	
	var original_scale: Vector3 = body.scale
	
	body.process_mode = PROCESS_MODE_DISABLED
	
	var rb := (body as Node) as RigidBody3D
	if rb:
		rb.freeze = true
	
	body.get_parent().remove_child(body)
	hand_marker.add_child(body)
	
	body.position = Vector3.ZERO
	body.rotation = Vector3.ZERO
	body.scale = original_scale
	
	hud.call("show_controls", item)

func drop_held_item() -> void:
	if not current_held_item or current_held_item == null: return
	
	var item = current_held_item
	current_held_item = null
	hud.call("hide_controls")
	
	var body: Node3D = item.carry_root if item.carry_root else item
	var original_scale: Vector3 = body.scale
	
	hand_marker.remove_child(body)
	get_tree().current_scene.add_child(body)
	
	body.global_position = hand_marker.global_position
	body.scale = original_scale
	
	_enable_item_physics(body)
	
	var forward: Vector3 = -camera.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	
	var rb := (body as Node) as RigidBody3D
	var cb := (body as Node) as CharacterBody3D
	
	if rb:
		rb.linear_velocity = owner.velocity + (forward * Constants.DROP_SPEED)
	elif cb:
		cb.velocity = owner.velocity + (forward * Constants.DROP_SPEED)
		if cb.has_method("on_thrown"):
			cb.call("on_thrown")

func throw_held_item() -> void:
	var item = current_held_item
	current_held_item = null
	hud.call("hide_controls")
	
	var body: Node3D = item.carry_root if item.carry_root else item
	var original_scale: Vector3 = body.scale
	
	hand_marker.remove_child(body)
	get_tree().current_scene.add_child(body)
	
	body.global_position = hand_marker.global_position
	body.scale = original_scale
	
	_enable_item_physics(body)
	
	var throw_direction := -camera.global_transform.basis.z.normalized()
	var rb := (body as Node) as RigidBody3D
	var cb := (body as Node) as CharacterBody3D
	
	if rb:
		rb.linear_velocity = owner.velocity
		rb.apply_central_impulse(throw_direction * Constants.THROW_FORCE)
		var spin: Vector3 = camera.global_transform.basis.x * randf_range(Constants.THROW_SPIN_MIN, Constants.THROW_SPIN_MAX)
		rb.apply_torque_impulse(spin)
	elif cb:
		# Launch the CharacterBody3D through the air
		cb.velocity = owner.velocity + (throw_direction * Constants.THROW_FORCE)
		if cb.has_method("on_thrown"):
			cb.call("on_thrown")

func _enable_item_physics(body: Node3D) -> void:
	body.process_mode = PROCESS_MODE_INHERIT
	
	var rb := (body as Node) as RigidBody3D
	if rb:
		rb.freeze = false
		rb.linear_velocity = Vector3.ZERO
		rb.angular_velocity = Vector3.ZERO

func _clear_highlight_and_prompt() -> void:
	if current_interactable_object:
		_set_object_highlight(current_interactable_object, false)
		current_interactable_object = null
		
	hud.call("hide_hover_prompt")

func _set_object_highlight(object: Node, enabled: bool) -> void:
	if not object: return
	
	# If this is a proxy entity (like an AI CharacterBody), outline the root body
	var target_node: Node = object
	if object is Holdable and (object as Holdable).carry_root:
		target_node = (object as Holdable).carry_root
		
	for mesh: MeshInstance3D in target_node.find_children("*", "MeshInstance3D", true, false):
		mesh.material_overlay = OUTLINE_MAT if enabled else null
