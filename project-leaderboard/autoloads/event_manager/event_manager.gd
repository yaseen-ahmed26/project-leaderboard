extends Node

"""
EventManager
Picks random events to setup
Handles blacklists between event
Handles the calender system
"""

@export var base_event_pool: Array[EventData] = []
var event_pool: Array[EventData] = []

var spawn_next_event_at: int = -1
var total_seconds: int

var active_events: int = 0
var has_done_initial_spawn: bool = false

var rt_stats: Dictionary = {
	"events": {}
}

func _ready():
	event_pool = base_event_pool.duplicate_deep()
	
	for k in Globals.EventIDs:
		rt_stats["events"][k.to_lower()] = 0
	
	Signals.phase_changed.connect(_on_phase_changed)
	Signals.afternoon_timer.connect(_on_afternoon_timer)

func spawn_event(amount_to_spawn: int):
	for i in amount_to_spawn:
		if event_pool.is_empty(): break	
		if active_events >= Constants.MAX_ACTIVE_EVENTS: break
		
		var random_event = event_pool.pick_random()
		event_pool.erase(random_event)
		
		active_events += 1
		
		Signals.event_added.emit(random_event)

func clear_events():
	pass

func event_solved(event_data: EventData):
	active_events -= 1
	
	var lower_id: String = Globals.get_lower_event_id(event_data.id)
	rt_stats["events"][lower_id] += 1
	
	Signals.event_solved.emit(event_data)

# Connections
func _on_phase_changed(new_phase: Globals.Phase):
	match new_phase:
		Globals.Phase.AFTERNOON:
			has_done_initial_spawn = false
			active_events = 0
			
			spawn_next_event_at = Constants.INITAL_EVENT_SPAWN_TIME			
		Globals.Phase.NIGHT:
			spawn_next_event_at = -1
			clear_events()

func _on_afternoon_timer(seconds_elapsed: int):
	total_seconds = seconds_elapsed

	if total_seconds == spawn_next_event_at:
		if not has_done_initial_spawn:
			spawn_event(Constants.INITAL_EVENT_SPAWN)
			has_done_initial_spawn = true
		else:
			spawn_event(1)
			
		spawn_next_event_at = total_seconds + randi_range(5, 14)

func get_event_stats():
	return rt_stats.get("events")
