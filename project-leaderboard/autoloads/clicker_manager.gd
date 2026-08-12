extends Node

"""
ClickerManager
Handles the main clicking calculations
Handles autoclicker decay when leaving desk
Handles passive generation during morning/night
"""

enum State {DISABLED, PASSIVE, DECAY}
var state: State = State.DISABLED

var rt_stats: Dictionary = {
	"cookies_per_click": 1.0,
	"click_multiplier": 1.0,
	"passive_generation": 0.1,
	"decay_multiplier": 1.2,
	"auto_decay": {}
}

var decay_seconds = 0
var passive_timer: Timer = Timer.new()

# Godot
func _ready() -> void:
	rt_stats["auto_decay"] = Constants.DEFAULT_AUTOCLICKER_DECAY.duplicate(true)

	add_child(passive_timer)
	passive_timer.one_shot = false
	passive_timer.wait_time = 1.0
	
	passive_timer.timeout.connect(_on_timer_timeout)
	Signals.phase_changed.connect(_on_phase_changed)

# Calculations
func calculate_click() -> float:
	return rt_stats["cookies_per_click"] * rt_stats["click_multiplier"]

func _calculate_passive():
	return rt_stats["passive_generation"]

func _calculate_decay():
	return calculate_click() * rt_stats["decay_multiplier"]

# Logic
func click_cookie():
	var amount: float = calculate_click()
	PlayerManager.add_cookies(amount)

func enable_decay():
	state = State.DECAY

func disable_decay():
	state = State.DISABLED
	decay_seconds = 0
	Signals.autoclicker_decayed.emit("None")

# Connections
func _on_timer_timeout():
	# State is disabled
	if state == 0: return
	
	var amount: float
	
	if state == 1:
		amount = _calculate_passive()
	else:
		amount = _calculate_decay()
		decay_seconds += 1
		
	PlayerManager.add_cookies(amount)
	
	if rt_stats["auto_decay"].has(decay_seconds):
		rt_stats["decay_multiplier"] = rt_stats["auto_decay"].get(decay_seconds)
		Signals.autoclicker_decayed.emit(rt_stats["auto_decay"].get(decay_seconds))
	
func _on_phase_changed(new_phase: Globals.Phase):
	match new_phase:
		Globals.Phase.MORNING, Globals.Phase.NIGHT:
			passive_timer.start()
			state = State.PASSIVE
		Globals.Phase.AFTERNOON:
			state = State.DISABLED
		Globals.Phase.MIDNIGHT:
			passive_timer.stop()
			
	decay_seconds = 0

func edit_stat(effect: Dictionary):
	if not rt_stats.has(effect.get("stat")):
		print("No stat found '%s'" % effect.get("stat")) 
		return

	match effect.get("operation"):
		"add": rt_stats[effect.get("stat")] += effect.get("value")
		"subtract": rt_stats[effect.get("stat")] -= effect.get("value")
		"multiply": rt_stats[effect.get("stat")] *= effect.get("value")
		"divide": rt_stats[effect.get("stat")] /= effect.get("value")
		"set":rt_stats[effect.get("stat")] = effect.get("value")

# Snacks
# Apple
func edit_autoclick_decay(value: float):
	for k in rt_stats["auto_decay"].keys():
		var v = rt_stats["auto_decay"].get(k)
		rt_stats["auto_decay"][k] = v + value
