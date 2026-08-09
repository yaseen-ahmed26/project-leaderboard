extends Node

const AFTERNOON_LENGTH: int = 10
var seconds_away = 0

var current_phase: String = "morning"
var day_started: bool = false

var afternoon_timer: Timer = Timer.new()

func _ready() -> void:
	self.add_child(afternoon_timer)
	afternoon_timer.one_shot = false
	afternoon_timer.autostart = false
	afternoon_timer.wait_time = 1
	
	afternoon_timer.timeout.connect(_on_timer_timeout)

func start_day():
	day_started = true
	current_phase = "morning"
	Signals.day_started.emit()

func change_phase(new_phase: String):
	if new_phase == current_phase: return
		
	current_phase = new_phase

	if current_phase == "afternoon":
		seconds_away = 0
		afternoon_timer.start()
	
	Signals.phase_changed.emit(new_phase)

func end_day():
	day_started = false
	var runtime_stats = PlayerManager.get_runtime_stats()
	
	Signals.day_ended.emit(runtime_stats)

func get_current_phase():
	return current_phase

func _on_timer_timeout():
	seconds_away += 1
	Signals.afternoon_timer.emit(seconds_away)
	
	if seconds_away >= AFTERNOON_LENGTH:
		afternoon_timer.stop()
		change_phase("night")
