extends Node

"""
PlayerManager
Handles economy
Handles win condition
Handles leaderboard position
Checks if the player has lost at the end of the day
"""

const TASK_SOURCES: Array = [
	Constants.TaskSources.PLAYER_STAT,
	Constants.TaskSources.UPGRADE_PURCHASE
]

var rt_stats: Dictionary = {
	"cookies": 20.0,
	"left_desk": 0,
	"times_player_fell_void": 0,
	"times_item_fell_void": 0
}

var player: Player

func _ready() -> void:
	Signals.item_entered_void.connect(_on_item_entered_void)

func update_task_manager(update):
	var source: Constants.TaskSources = TaskManager.get_current_task_source()

	if TASK_SOURCES.has(source):
		TaskManager.report_task_update(update)

func add_cookies(amount: float):
	rt_stats["cookies"] += amount
	update_task_manager(Constants.Stats.COOKIES)
	Signals.stats_changed.emit(rt_stats)

func entered_desk():
	ClickerManager.disable_decay()
	
func left_desk():
	ClickerManager.enable_decay()
	rt_stats["left_desk"] += 1
	update_task_manager(Constants.Stats.LEFT_DESK)

func edit_stat(effect: Dictionary):
	if not rt_stats.has(effect.get("stat")):
		print("No stat found '%s'" % effect.get("stat")) 
		return

	match effect.get("operation"):
		"add": rt_stats[effect.get("stat")] += effect.get("value")
		"subtract": rt_stats[effect.get("stat")] -= effect.get("value")
		"multiply": rt_stats[effect.get("stat")] *= effect.get("value")
		"divide": rt_stats[effect.get("stat")] /= effect.get("value")
		"set": rt_stats[effect.get("stat")] = effect.get("value")
		
	update_task_manager(Constants.Stats[effect.get("stat")])

func purchase(cost: float):
	if rt_stats["cookies"] >= cost:
		rt_stats["cookies"] -= cost
		
		# hardcoded to assume purchase is an upgrade
		update_task_manager(Constants.Actions.UPGRADE_BOUGHT)
		
		return true
		
	return false

func get_rt_stats():
	return rt_stats

func _on_item_entered_void(body: Node3D):
	if body.is_in_group("player"):
		rt_stats["times_player_fell_void"] += 1
	elif body.is_in_group("Interactables"):
		rt_stats["times_item_fell_void"] += 1
