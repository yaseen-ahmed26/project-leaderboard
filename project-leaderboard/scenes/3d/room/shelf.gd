extends MeshInstance3D

func _ready():
	Signals.phase_changed.connect(_on_phase_changed)
	Signals.event_solved.connect(_on_event_solved)
	
func _on_event_solved(event_data: EventData):
	var lower_id: String = Globals.get_lower_event_id(event_data.id)
	
	var s = self.get_node_or_null(lower_id)
	if not s: return
	
	var label = s.get_node_or_null("info")
	if not label: return
	
	label.text = "%s\nSOLVED" % s.name.capitalize()
	
func _on_phase_changed(new_phase: Globals.Phase):
	match new_phase:
		Globals.Phase.MORNING, Globals.Phase.NIGHT:
			var stats: Dictionary = EventManager.get_event_stats()
			
			for s in self.get_children():
				var label = s.get_node_or_null("info")
				var amount = stats.get(s.name.to_lower())
				
				if label:
					label.text = "%s\nCompleted: %d %s" % [
						s.name.capitalize(),
						amount,
						"time" if amount == 1 else "times"
					]
		Globals.Phase.AFTERNOON:
			for s in self.get_children():
				var label = s.get_node_or_null("info")
				
				if label:
					label.text = "%s" % s.name.capitalize()
