extends Interactable
class_name Terminal

@export var camera_source: Globals.CameraSources

@onready var sub_viewport: SubViewport = $SubViewport
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var camera_marker: Marker3D = $Marker3D

func _ready() -> void:
	super()
	self.input_ray_pickable = true

func _input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	var local_pos: Vector3 = mesh.global_transform.affine_inverse() * event_position
	var mesh_size: Vector2 = mesh.mesh.size
	
	var uv := Vector2(
		(local_pos.x / mesh_size.x) + 0.5,
		1.0 - ((local_pos.y / mesh_size.y) + 0.5) # Flip Y for screen space
	)
	
	var viewport_pos := Vector2(
		uv.x * sub_viewport.size.x,
		uv.y * sub_viewport.size.y
	)
	
	var local_event := event.duplicate()
	
	if local_event is InputEventMouse:
		
		local_event.position = viewport_pos
		local_event.global_position = viewport_pos
		
	sub_viewport.push_input(local_event)
