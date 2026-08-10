extends Node

var runtime_stats: Dictionary = {
	"cookies": 20.0,
	"cookies_per_click": 1.0,
	"click_multiplier": 1.0,
	"multiplier": 1.0,
	"left_desk": 0,
	"leaderboard_position": 0,
	"distractions_solved": [],
	"upgrades": []
}

var milestone_click = 3
var click_count = 0

var default_multipler: float = 1

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
	var amount: float = runtime_stats["cookies_per_click"] * runtime_stats["click_multiplier"]
	
	amount = _apply_upgrades(amount)
	amount *= runtime_stats["multiplier"]
	
	runtime_stats["cookies"] += amount
	Signals.stats_changed.emit(runtime_stats)

func entered_desk():
	ClickerManager.deactivate_decay()
	runtime_stats["multiplier"] = default_multipler
	
func left_desk():
	runtime_stats["multiplier"] = 1.2
	runtime_stats["left_desk"] += 1
	ClickerManager.activate_decay()

func edit_stat(effect: Dictionary, snack_id: String):
	if not runtime_stats.has(effect.get("stat")):
		print("No stat found '%s' requested by Snack %s" % [effect.get("stat"), snack_id]) 
		return

	match effect.get("operation"):
		"add": runtime_stats[effect.get("stat")] += effect.get("value")
		"subtract": runtime_stats[effect.get("stat")] -= effect.get("value")
		"multiply": runtime_stats[effect.get("stat")] *= effect.get("value")
		"divide": runtime_stats[effect.get("stat")] /= effect.get("value")
		"set":runtime_stats[effect.get("stat")] = effect.get("value")

func purchase(cost: float):
	if runtime_stats["cookies"] >= cost:
		runtime_stats["cookies"] -= cost
		return true
		
	return false

func solved_distraction(details: Dictionary):
	runtime_stats["distractions_solved"].append(details.get("name"))
	
func get_runtime_stats():
	if runtime_stats["upgrades"].has("bonus"):
		runtime_stats["cookies"] += 5
		
	return runtime_stats
