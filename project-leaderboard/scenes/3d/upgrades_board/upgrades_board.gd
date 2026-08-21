extends Terminal

func on_interaction():
	Signals.change_camera.emit(camera_marker.global_transform, camera_source)
