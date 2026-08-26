extends Node3D
class_name Event

enum State {
	UNSOLVED,
	GENERATING,
	CORRUPTED
}

@export var event_data: EventData

var respawn_marker: Marker3D

var seconds_elapsed: int = 0
var state: State = State.UNSOLVED:
	set(new_state):
		if state == new_state: return
		state = new_state
		_on_state_changed(state)

var lifecycle_timer: Timer
var time_to_corrupt: float
var is_destroyed: bool = false

func _ready() -> void:
	respawn_marker = $respawn_marker
	
	lifecycle_timer = Timer.new()
	lifecycle_timer.one_shot = false
	lifecycle_timer.wait_time = 1.0
	
	add_child(lifecycle_timer)
	
	lifecycle_timer.timeout.connect(_on_corruption_timeout)

func get_current_state():
	return State.keys()[state]

func _on_state_changed(new_state: State):
	match new_state:
		State.UNSOLVED:
			pass
		State.GENERATING:
			EventManager.event_solved(event_data)
			
			seconds_elapsed = 0
			time_to_corrupt = randi_range(Constants.TIME_TO_CORRUPT_MIN, Constants.TIME_TO_CORRUPT_MAX)
			lifecycle_timer.start()
			
			var label = get_node_or_null("Label3D")
			if label:
				label.text = "GENERATING: 1 Cookie/s"
		State.CORRUPTED:
			lifecycle_timer.stop()
			var label = get_node_or_null("Label3D")
			if label:
				label.text = "CORRUPTED"

func _on_corruption_timeout():
	seconds_elapsed += 1
	ClickerManager.click_cookie()
	
	if seconds_elapsed >= time_to_corrupt:
		state = State.CORRUPTED
		
func solve_event():
	EventManager.event_solved(event_data)

func clean_up():
	pass

func on_tank_hit():
	if state != State.CORRUPTED: return
	if is_destroyed: return
	
	is_destroyed = true
	solve_event()
	
	queue_free()
