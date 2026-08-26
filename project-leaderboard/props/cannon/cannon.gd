extends Interactable

@export var animation_player: AnimationPlayer
@export var player: CharacterBody3D

@onready var camera_marker: Marker3D = $camera_marker

var camera_source := Constants.CameraSources.CANNON
var is_aiming: bool = false

func _ready():
	super()
	
	Signals.camera_restored.connect(_on_camera_restored)

func on_interaction() -> void:
	if is_aiming: return
	
	is_aiming = true
	Signals.change_camera.emit(camera_marker.global_transform, camera_source)

func _on_camera_restored():
	is_aiming = false
