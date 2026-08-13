extends Node3D
class_name Event

enum State {
	UNSOLVED,
	GENERATING,
	CORRUPTED
}

@export var event_data: EventData

var seconds_elapsed: int = 0
var state: State = State.UNSOLVED:
	set(new_state):
		if state == new_state: return
		state = new_state
		_on_state_changed(state)

var lifecycle_timer: Timer
var time_to_corrupt: float

func _ready() -> void:
	lifecycle_timer = Timer.new()
	lifecycle_timer.one_shot = false
	lifecycle_timer.wait_time = 1.0
	
	add_child(lifecycle_timer)
	
	lifecycle_timer.timeout.connect(_on_corruption_timeout)

func _on_state_changed(new_state: State):
	match new_state:
		State.UNSOLVED:
			pass
		State.GENERATING:
			seconds_elapsed = 0
			time_to_corrupt = randi_range(3, 7)
			lifecycle_timer.start()
			
			var label = get_node_or_null("Label3D")
			if label:
				label.text = "GENERATING: 1/s"
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
		
