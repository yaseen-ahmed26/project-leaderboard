extends Interactable

@export var camera_source: Constants.CameraSources

@onready var camera_marker: Marker3D = $Marker3D

func on_interaction():
	Signals.change_camera.emit(camera_marker.global_transform, camera_source)
