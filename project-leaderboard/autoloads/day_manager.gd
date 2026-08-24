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

var rt_stats = {
	"events_solved": []
}

# Godot
func _ready():
	self.add_child(afternoon_timer)
	afternoon_timer.one_shot = false
	afternoon_timer.autostart = false
	afternoon_timer.wait_time = 1
	
	afternoon_timer.timeout.connect(_on_timer_timeout)

	Signals.event_solved.connect(_on_event_solved)

# Main
func start_day():
	current_phase = Globals.Phase.MORNING
	Signals.phase_changed.emit(current_phase)
		
func start_afternoon():
	current_phase = Globals.Phase.AFTERNOON
	seconds_elapsed = 0
	afternoon_timer.start()
	Signals.phase_changed.emit(current_phase)
	
func end_afternoon():
	current_phase = Globals.Phase.NIGHT
	afternoon_timer.stop()
	Signals.phase_changed.emit(current_phase)
	
func end_day():
	print("END DAY DayManager")
	current_phase = Globals.Phase.MIDNIGHT
	
	var stats = [
		PlayerManager.get_rt_stats(),
		ClickerManager.get_rt_stats(),
		TaskManager.get_rt_stats(),
		rt_stats
	]
	var combined = {}
	
	for dict in stats:
		combined.merge(dict, true)
	
	Signals.day_ended.emit(combined)

# Getters
func get_current_phase():
	return current_phase

# Connections
func _on_timer_timeout():
	seconds_elapsed += 1
	Signals.afternoon_timer.emit(seconds_elapsed)
	
	if seconds_elapsed >= Constants.AFTERNOON_LENGTH:
		end_afternoon()

func _on_event_solved(event_data: EventData):
	rt_stats["events_solved"].append(event_data.display_name)
