extends Node

var runtime_stats: Dictionary = {
	"cookies": 0.0,
	"click_multiplier": 1,
	"multiplier": 1,
	"left_desk": 0,
	"leaderboard_position": 0,
	"distractions_solved": [],
	"upgrades": []
}

var milestone_click = 3
var click_count = 0

var default_multipler: float = 1

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

func _apply_upgrades(amount):
	if runtime_stats["upgrades"].has("increment"):
		amount += 0.5
		
	if runtime_stats["upgrades"].has("milestone"):
		click_count += 1
		if click_count >= milestone_click:
			amount += 1
			click_count = 0
	
	return amount

func add_cookies():
	var amount: float = 1.0
	
	amount = _apply_upgrades(amount)
	amount *= runtime_stats["multiplier"]
	
	runtime_stats["cookies"] += amount
	Signals.stats_changed.emit(runtime_stats)

func entered_desk():
	timer.stop()
	seconds_away = 0
	Signals.autoclicker_decayed.emit("NONE")
	runtime_stats["multiplier"] = default_multipler
	
func left_desk():
	timer.start()
	seconds_away = 0
	runtime_stats["multiplier"] = 1.2
	runtime_stats["left_desk"] += 1
	Signals.autoclicker_decayed.emit(runtime_stats["multiplier"])
	
func _on_timer_timeout():
	add_cookies()
	seconds_away += 1
		
	if autoclicker_decay.has(seconds_away):
		runtime_stats["multiplier"] = autoclicker_decay.get(seconds_away)

		Signals.autoclicker_decayed.emit(runtime_stats["multiplier"])
	
	if seconds_away >= 45:
		timer.stop()

func parse_snack(id: String):
	match id:
		"apple":
			for k in autoclicker_decay.keys():
				var v = autoclicker_decay.get(k)
				autoclicker_decay[k] = v + 0.1
		"orange":
			default_multipler = 1.2
			runtime_stats["multiplier"] = default_multipler

func parse_upgrade(upgrade_name: String, cost):
	runtime_stats["cookies"] -= cost
	runtime_stats["upgrades"].append(upgrade_name)
	
	Signals.stats_changed.emit(runtime_stats)

func can_buy_upgrade(cost: float):
	if runtime_stats["cookies"] >= cost:
		return true
		
	return false

func _on_phase_changed(new_phase: String):
	if new_phase == "night":
		timer.stop()

func solved_distraction(details: Dictionary):
	runtime_stats["distractions_solved"].append(details.get("name"))
	
func get_runtime_stats():
	if runtime_stats["upgrades"].has("bonus"):
		runtime_stats["cookies"] += 5
		
	return runtime_stats
