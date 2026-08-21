extends Terminal

func on_interaction():
	Signals.change_camera.emit(camera_marker.global_transform, camera_source)
	
	if DayManager.get_current_phase() != Globals.Phase.AFTERNOON:
		DayManager.change_phase(Globals.Phase.AFTERNOON)
		self.hover_text = "[E] Cookie Clicker"
