extends CharacterBody3D
class_name Player

const TASK_SOURCES: Array = [
	Constants.TaskSources.PLAYER_ACTION
]
const FIREABLE_ACTIONS: Array = [
	Constants.CameraSources.TANK,
	Constants.CameraSources.CANNON
]

var input_direction : Vector2
var speed : float

@export var island_respawn: Marker3D
@export var look_sensitivity: float = 0.005
@export var walk_speed = 5.0
@export var sprint_speed = 10.0
@export var sneak_speed = 2.0
@export var acceleration = 60.0
@export var jump_velocity = 4.5
@export var air_control = 5.0
@export var air_resistance = 2.0
@export var lock_movement: bool = false
# Headbob & Sway Settings
@export var bob_frequency: float = 2.45
@export var bob_amplitude: float = 0.13
@export var idle_sway_frequency: float = 0.8
@export var idle_sway_amplitude: float = 0.015
@export var bob_lerp_speed: float = 10.0

# Hand Sway & Bob Settings
@export var hand_bob_amount: float = 0.025
@export var hand_sway_amount: float = 0.04
@export var hand_sway_rotation: float = 0.04
@export var hand_lerp_speed: float = 12.0

var default_hand_pos: Vector3 = Vector3.ZERO
var default_hand_rot: Vector3 = Vector3.ZERO
var mouse_input: Vector2 = Vector2.ZERO

var bob_time: float = 0.0
var default_camera_pos: Vector3 = Vector3.ZERO

@onready var head = $head
@onready var camera = $head/camera
@onready var hud: Control = $CanvasLayer/hud
@onready var flashlight: SpotLight3D = $head/camera/flashlight
@onready var hand_marker: Marker3D = $head/camera/hand_marker

var original_camera_transform: Transform3D
var on_terminal: bool = false
var camera_source: Constants.CameraSources

func _ready():
	PlayerManager.player = self
	
	default_camera_pos = camera.position
	default_hand_pos = hand_marker.position
	default_hand_rot = hand_marker.rotation
	camera_source = Constants.CameraSources.PLAYER
	
	Signals.change_camera.connect(_on_change_camera)
	Signals.phase_changed.connect(_on_phase_changed)
	Signals.day_ended.connect(_on_day_ended)
	Signals.restore_camera.connect(_restore_camera)

func update_task_manager(update: Constants.Actions):
	var source: Constants.TaskSources = TaskManager.get_current_task_source()

	if TASK_SOURCES.has(source):
		TaskManager.report_task_update(update)

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if camera_source == Constants.CameraSources.TANK:
			camera.rotation.y -= event.relative.x * look_sensitivity
			camera.rotation.x -= event.relative.y * look_sensitivity
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
			camera.rotation.z = 0.0
		else:
			head.rotate_y(-event.relative.x * look_sensitivity)
			camera.rotate_x(-event.relative.y * look_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

	if Input.is_action_just_pressed("release_mouse"):
		if on_terminal:
			if camera_source == Constants.CameraSources.CLICKER_MONITOR:
				PlayerManager.left_desk()
			
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			_restore_camera()

	if Input.is_action_just_pressed("action_shoot") and FIREABLE_ACTIONS.has(camera_source):
		fire_tank()
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_input = event.relative

func _physics_process(delta):
	if lock_movement: return
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_pressed("move_sprint") and is_on_floor():
		speed = sprint_speed
	elif Input.is_action_pressed("move_sneak"):
		speed = sneak_speed
	else:
		speed = walk_speed
	
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = jump_velocity
		update_task_manager(Constants.Actions.PLAYER_JUMP)

	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	var direction = (head.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	var target_velocity = direction * speed
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)

	if is_on_floor():
		horizontal_velocity = horizontal_velocity.move_toward(target_velocity, acceleration * delta)
		
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z
	else:
		if direction:
			horizontal_velocity = horizontal_velocity.move_toward(target_velocity, air_control * delta)
		
		horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, air_resistance * delta)
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z
	
	move_and_slide()
	_process_headbob(delta, horizontal_velocity)
	_process_hand_sway(delta, horizontal_velocity)

# Signals
func _on_change_camera(new_position: Transform3D, source: Constants.CameraSources):
	original_camera_transform = camera.transform
	camera_source = source
	
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "global_transform", new_position, Constants.CAMERA_TWEEN_TIME)
	
	on_terminal = true
	lock_movement = true
	
	head.drop_held_item()
	
	if source == Constants.CameraSources.TANK:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		var flashlight_tween: Tween = create_tween()
		flashlight_tween.tween_property(
			flashlight,
			"light_energy",
			Constants.TERMINAL_FLASHLIGHT_BRIGHTNESS,
			0.2
		)
		
	if source == Constants.CameraSources.CLICKER_MONITOR:
		PlayerManager.entered_desk()

func _restore_camera():
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "transform", original_camera_transform, Constants.CAMERA_TWEEN_TIME)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	on_terminal = false
	lock_movement = false
	
	var flashlight_tween: Tween = create_tween()
	flashlight_tween.tween_property(
		flashlight,
		"light_energy",
		0.0,
		0.2
	)
	
	camera_source = Constants.CameraSources.PLAYER
	
	Signals.camera_restored.emit()

func _on_main_menu_exit():
	lock_movement = false
	hud.visible = true
	Input.set_mouse_mode.call_deferred(Input.MOUSE_MODE_CAPTURED)

func _on_day_ended(_details):
	lock_movement = true
	hud.visible = false
	Input.set_mouse_mode.call_deferred(Input.MOUSE_MODE_VISIBLE)

func _on_phase_changed(new_phase: Constants.Phase):
	match new_phase:
		Constants.Phase.MORNING:
			lock_movement = false
			hud.visible = true
			Input.set_mouse_mode.call_deferred(Input.MOUSE_MODE_CAPTURED)
		Constants.Phase.NIGHT:
			if on_terminal:
				_restore_camera()
				on_terminal = false

func fire_tank():
	print("--- FIRED ---")
	
	var space_state = get_world_3d().direct_space_state
	
	# Determine ray origin: mouse cursor if free, screen center if captured
	var screen_pos: Vector2
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		screen_pos = get_viewport().get_mouse_position()
	else:
		screen_pos = Vector2(get_viewport().size) / 2.0
	
	# Increase distance to 5000m to ensure distant islands are reached
	var origin = camera.project_ray_origin(screen_pos)
	var end = origin + (camera.project_ray_normal(screen_pos) * 5000.0)
	
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.exclude = [self.get_rid()]
	
	var result: Dictionary = space_state.intersect_ray(query)
	print("Raycast Result: ", result)

	if not result.is_empty() and result.has("collider"):
		var target: Node = result["collider"]
		print("Hit Collider: ", target.name)

		if camera_source == Constants.CameraSources.TANK:
			if target.has_method("on_tank_hit"):
				target.on_tank_hit()
		elif camera_source == Constants.CameraSources.CANNON:
			var island: Node = target.owner
			print("Cannon targeted island: ", island.name)
			
			if island:
				var marker = island.get_node_or_null("respawn_marker")
				
				if marker:
					self.global_position = marker.global_position
					_restore_camera()
				
				if island.has_method("on_player_enter"):
					island.on_player_enter()
			
func _process_headbob(delta: float, h_velocity: Vector3) -> void:
	if camera_source != Constants.CameraSources.PLAYER or on_terminal:
		return

	var target_pos: Vector3 = default_camera_pos

	if is_on_floor():
		var move_speed := h_velocity.length()
		
		# walking (bob)
		if move_speed > 0.2:
			bob_time += delta * move_speed * bob_frequency
			target_pos.y += sin(bob_time) * bob_amplitude
			target_pos.x += cos(bob_time * 0.5) * (bob_amplitude * 0.6)
		# idle (sway)
		else:
			bob_time += delta * idle_sway_frequency
			target_pos.y += sin(bob_time) * idle_sway_amplitude
			target_pos.x += cos(bob_time * 0.5) * (idle_sway_amplitude * 0.5)
	else:
		# airborne
		target_pos = default_camera_pos

	camera.position = camera.position.lerp(target_pos, delta * bob_lerp_speed)

func _process_hand_sway(delta: float, h_velocity: Vector3) -> void:
	if not hand_marker or camera_source != Constants.CameraSources.PLAYER:
		return

	var target_pos: Vector3 = default_hand_pos
	var target_rot: Vector3 = default_hand_rot

	# when looking around
	target_pos.x -= mouse_input.x * (hand_sway_amount * 0.001)
	target_pos.y += mouse_input.y * (hand_sway_amount * 0.001)
	target_rot.z += mouse_input.x * (hand_sway_rotation * 0.001)
	target_rot.x -= mouse_input.y * (hand_sway_rotation * 0.001)

	mouse_input = Vector2.ZERO

	#when walking
	if is_on_floor() and h_velocity.length() > 0.2:
		target_pos.y += sin(bob_time) * hand_bob_amount
		target_pos.x += cos(bob_time * 0.5) * (hand_bob_amount * 0.6)
		target_rot.z += cos(bob_time * 0.5) * (hand_bob_amount * 0.4)

	# back to default
	hand_marker.position = hand_marker.position.lerp(target_pos, delta * hand_lerp_speed)
	hand_marker.rotation.x = lerp_angle(hand_marker.rotation.x, target_rot.x, delta * hand_lerp_speed)
	hand_marker.rotation.y = lerp_angle(hand_marker.rotation.y, target_rot.y, delta * hand_lerp_speed)
	hand_marker.rotation.z = lerp_angle(hand_marker.rotation.z, target_rot.z, delta * hand_lerp_speed)

func teleport_to(new_position: Vector3):
	self.global_position = new_position

func respawn():
	self.global_position = island_respawn.global_position
