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
	"decay_multiplier": 1.5,
	"decay_rate": 0.01
}

var passive_timer: Timer = Timer.new()

# Godot
func _ready() -> void:
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
	rt_stats["decay_multiplier"] = 1.5

func disable_decay():
	state = State.DISABLED
	Signals.autoclicker_decayed.emit("[color=gold]NONE!")

# Connections
func _on_timer_timeout():
	if state == State.DISABLED: return
	
	var amount: float
	
	if state == State.PASSIVE:
		amount = _calculate_passive()
	elif state == State.DECAY:
		rt_stats["decay_multiplier"] -= rt_stats["decay_rate"]
		
		if rt_stats["decay_multiplier"] <= 0:
			DayManager.end_day()
			state = State.DISABLED
		
		amount = _calculate_decay()
		Signals.autoclicker_decayed.emit("%s" % (rt_stats["decay_multiplier"] * 100))
		
	PlayerManager.add_cookies(amount)
	
func _on_phase_changed(new_phase: Globals.Phase):
	match new_phase:
		Globals.Phase.MORNING, Globals.Phase.NIGHT:
			passive_timer.start()
			state = State.PASSIVE
		Globals.Phase.AFTERNOON:
			state = State.DISABLED
		Globals.Phase.MIDNIGHT:
			passive_timer.stop()

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

func get_rt_stats():
	return rt_stats

# Snacks
# Apple
func edit_autoclick_decay(value: float):
	print("DOES NOTHING YET")
