extends CharacterBody3D

const TASK_SOURCES: Array = [
	Globals.TaskSources.PLAYER_ACTION
]

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
@onready var camera = $head/camera
@onready var hud: Control = $hud

var original_camera_transform: Transform3D
var on_terminal: bool = false
var camera_source: String

func _ready():	
	Signals.change_camera.connect(_on_change_camera)
	#Signals.day_started.connect(_on_main_menu_exit)
	#Signals.day_ended.connect(_on_day_ended)
	Signals.phase_changed.connect(_on_phase_changed)

func update_task_manager(update: Globals.Actions):
	var source: Globals.TaskSources = TaskManager.get_current_task_source()

	if TASK_SOURCES.has(source):
		TaskManager.report_task_update(update)

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * look_sensitivity)
		camera.rotate_x(-event.relative.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

	if Input.is_action_just_pressed("release_mouse"):
		if on_terminal:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			_restore_camera()
			
			if camera_source == "main_monitor":
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
		update_task_manager(Globals.Actions.PLAYER_JUMP)

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
func _on_change_camera(new_position: Transform3D, source: String):
	original_camera_transform = camera.transform
	camera_source = source
	
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "global_transform", new_position, 0.5)
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	on_terminal = true
	lock_movement = true

	if source == "main_monitor":
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

func _on_day_ended(_details):
	lock_movement = true
	hud.visible = false
	Input.set_mouse_mode.call_deferred(Input.MOUSE_MODE_VISIBLE)

func _on_phase_changed(new_phase: Globals.Phase):
	match new_phase:
		Globals.Phase.MORNING:
			lock_movement = false
			hud.visible = true
			Input.set_mouse_mode.call_deferred(Input.MOUSE_MODE_CAPTURED)
		Globals.Phase.NIGHT:
			if on_terminal:
				_restore_camera()
				on_terminal = false
