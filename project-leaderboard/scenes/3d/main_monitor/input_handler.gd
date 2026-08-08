extends Area3D

@export var sub_viewport: SubViewport
@export var mesh: MeshInstance3D

func _ready() -> void:
	# Enable mouse input collision detection on the Area3D
	input_ray_pickable = true

func _input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	# 1. Transform global 3D hit position into mesh local space
	var local_pos: Vector3 = mesh.global_transform.affine_inverse() * event_position
	var mesh_size: Vector2 = mesh.mesh.size
	
	# 2. Convert 3D local coordinates to 2D UV coordinates (range 0.0 to 1.0)
	var uv := Vector2(
		(local_pos.x / mesh_size.x) + 0.5,
		1.0 - ((local_pos.y / mesh_size.y) + 0.5) # Flip Y for screen space
	)
	
	# 3. Map UV coordinates to SubViewport pixel resolution
	var viewport_pos := Vector2(
		uv.x * sub_viewport.size.x,
		uv.y * sub_viewport.size.y
	)
	
	# 4. Clone event, update position, and send to the SubViewport
	var local_event := event.duplicate()
	if local_event is InputEventMouse:
		local_event.position = viewport_pos
		local_event.global_position = viewport_pos
		
	sub_viewport.push_input(local_event)
