extends Node

"""
DayManager
Handles the main day loop
Handles day start and end
Handles morning, afternoon, night phases
Handles the afternoon timings
Applies gameplay modifiers

The different phases are:
	Morning, Afternoon, Night, Midnight
	
"""

var current_phase: Globals.Phase = Globals.Phase.MIDNIGHT

var seconds_elapsed = 0
var afternoon_timer: Timer = Timer.new()

# Godot
func _ready():
	self.add_child(afternoon_timer)
	afternoon_timer.one_shot = false
	afternoon_timer.autostart = false
	afternoon_timer.wait_time = 1
	
	afternoon_timer.timeout.connect(_on_timer_timeout)

# Main
func start_day():
	change_phase(Globals.Phase.MORNING)
	
func end_day():
	Signals.day_end.emit()

func change_phase(new_phase: Globals.Phase):
	current_phase = new_phase
	
	match current_phase:
		Globals.Phase.MORNING:
			pass
		Globals.Phase.AFTERNOON:
			seconds_elapsed = 0
			afternoon_timer.start()
		Globals.Phase.NIGHT:
			end_day()
		Globals.Phase.MIDNIGHT:
			start_day()

	Signals.phase_changed.emit(current_phase)

# Getters
func get_current_phase():
	return current_phase

# Connections
func _on_timer_timeout():
	seconds_elapsed += 1
	Signals.afternoon_timer.emit(seconds_elapsed)
	
	if seconds_elapsed >= Constants.AFTERNOON_LENGTH:
		afternoon_timer.stop()
		change_phase(Globals.Phase.NIGHT)
