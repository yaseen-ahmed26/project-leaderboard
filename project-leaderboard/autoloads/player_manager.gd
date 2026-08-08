extends Node

var runtime_stats: Dictionary = {
	"cookies": 0.0,
	"multiplier": 1
}
var autoclicker_decay: Dictionary = {
	5: 1,
	15: 0.5,
	30: 0.2,
	45: 0.1,
}

var seconds_away = 0
var timer: Timer = Timer.new()

func _ready() -> void:
	add_child(timer)
	timer.one_shot = false
	timer.wait_time = 1.0
	timer.timeout.connect(_on_timer_timeout)

func add_cookies():
	var amount = 1 * runtime_stats["multiplier"]
	
	runtime_stats["cookies"] += amount
	Signals.stats_changed.emit(runtime_stats)

func entered_desk():
	timer.stop()
	seconds_away = 0
	Signals.autoclicker_decayed.emit("NONE")
	runtime_stats["multiplier"] = 1
	
func left_desk():
	timer.start()
	seconds_away = 0
	runtime_stats["multiplier"] = 1.2
	Signals.autoclicker_decayed.emit(runtime_stats["multiplier"])
	
func _on_timer_timeout():
	add_cookies()
	seconds_away += 1
		
	if autoclicker_decay.has(seconds_away):
		runtime_stats["multiplier"] = autoclicker_decay.get(seconds_away)

		Signals.autoclicker_decayed.emit(runtime_stats["multiplier"])
	
	if seconds_away >= 45:
		timer.stop()
