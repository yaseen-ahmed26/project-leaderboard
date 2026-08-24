extends CharacterBody3D

@export var speed: float = 4.0
@export var flee_speed: float = 7.0
@export var flee_radius: float = 6.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var player: Node3D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node3D
	
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	
	await get_tree().physics_frame
	pick_random_target()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

	var is_fleeing: bool = player != null and global_position.distance_to(player.global_position) < flee_radius

	if is_fleeing:
		flee_from_player()
	elif nav_agent.is_navigation_finished():
		pick_random_target()

	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var move_dir: Vector3 = (next_pos - global_position).normalized()
	move_dir.y = 0.0 

	var target_speed: float = flee_speed if is_fleeing else speed
	var intended_velocity: Vector3 = move_dir * target_speed

	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(intended_velocity)
	else:
		_on_velocity_computed(intended_velocity)

	if move_dir.length_squared() > 0.001:
		look_at(global_position + move_dir, Vector3.UP)

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z
	move_and_slide()

func pick_random_target() -> void:
	var map: RID = get_world_3d().navigation_map
	nav_agent.target_position = NavigationServer3D.map_get_random_point(map, 1, false)

func flee_from_player() -> void:
	var away_dir: Vector3 = (global_position - player.global_position).normalized()
	var flee_pos: Vector3 = global_position + (away_dir * flee_radius)
	var map: RID = get_world_3d().navigation_map
	
	nav_agent.target_position = NavigationServer3D.map_get_closest_point(map, flee_pos)
