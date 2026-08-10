extends Node

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
	
	Signals.phase_changed.connect(_on_phase_changed)
	
func _on_timer_timeout():
	PlayerManager.add_cookies()
	seconds_away += 1
		
	if autoclicker_decay.has(seconds_away):
		PlayerManager.edit_stat({
			"operation": "set",
			"value": autoclicker_decay.get(seconds_away),
			"stat": "multiplier"
		}, "")

		Signals.autoclicker_decayed.emit(autoclicker_decay.get(seconds_away))
	
	if seconds_away >= 45:
		timer.stop()
		Signals.autoclicker_decayed.emit("NONE")

# Custom Snack: Apple
func edit_autoclick_decay(value: float):
	for k in autoclicker_decay.keys():
		var v = autoclicker_decay.get(k)
		autoclicker_decay[k] = v + value

func _on_phase_changed(new_phase: String):
	if new_phase == "night":
		timer.stop()

func activate_decay():
	timer.start()
	Signals.autoclicker_decayed.emit(1.2)
	
func deactivate_decay():
	timer.stop()
	Signals.autoclicker_decayed.emit("NONE")
