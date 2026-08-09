extends CharacterBody3D

var input_direction : Vector2
var speed : float

@export var look_sensitivity: float = 0.005
@export var walk_speed = 5.0
@export var sprint_speed = 10.0
@export var sneak_speed = 2.0
@export var acceleration = 60.0
@export var jump_velocity = 4.5
@export var air_control = 5.0
@export var air_resistance = 2.0
@export var lock_movement: bool = false

@onready var head = $head
@onready var camera = $head/Camera3D
@onready var hud: Control = $hud

var original_camera_transform: Transform3D
var on_terminal: bool = false

func _ready():	
	Signals.change_camera.connect(_on_change_camera)
	Signals.day_started.connect(_on_main_menu_exit)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * look_sensitivity)
		camera.rotate_x(-event.relative.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

	if Input.is_action_just_pressed("release_mouse"):
		if on_terminal:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			_restore_camera()
			PlayerManager.left_desk()

	# if event is InputEventMouseButton and event.pressed:
	#	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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

# Signals
func _on_change_camera(new_position: Transform3D):
	original_camera_transform = camera.transform
	
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "global_transform", new_position, 0.5)
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	on_terminal = true
	lock_movement = true
	PlayerManager.entered_desk()

func _restore_camera():
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "transform", original_camera_transform, 0.5)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	on_terminal = false
	lock_movement = false

func _on_main_menu_exit():
	lock_movement = false
	hud.visible = true
	Input.set_mouse_mode.call_deferred(Input.MOUSE_MODE_CAPTURED)
