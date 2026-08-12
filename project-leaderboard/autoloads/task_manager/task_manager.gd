extends Node

"""
TaskManager
Tracks daily microtask
Tracks weekly task
"""

@export var base_task_pool: Array[TaskData] = []

var current_source: Globals.TaskSources = Globals.TaskSources.NONE
var current_task: TaskData
var task_completed: bool = false
var progress: int = 0
var target: int

func _ready() -> void:
	Signals.phase_changed.connect(_on_phase_changed)

func generate_task():
	if base_task_pool.is_empty(): 
		print("Task Pool is empty")
		return
		
	current_task = base_task_pool.pick_random()
	target = current_task.target_amount
	current_source = current_task.target_source
		
	Signals.task_progress.emit(current_task, 0)

func report_task_update(stat_name: String):
	if task_completed: return
	
	if stat_name == current_task.target_stat:
		progress += 1
		Signals.task_progress.emit(current_task, progress)
	
	if progress == target:
		task_completed = true
		current_source = Globals.TaskSources.NONE
		PlayerManager.add_cookies(current_task.cookie_reward)
		Signals.task_completed.emit(current_task)

# Getters
func get_current_task_source():
	return current_source

# Connections
func _on_phase_changed(new_phase: Globals.Phase):
	match new_phase:
		Globals.Phase.MORNING:
			generate_task()

"""


func get_current_stat_value(source: TaskData.TargetSource, stat_key: String) -> float:
	match source:
		TaskData.TargetSource.PLAYER:
			if PlayerManager.rt_stats.has(stat_key):
				return float(PlayerManager.rt_stats[stat_key])
		TaskData.TargetSource.CLICKER:
			if ClickerManager.rt_stats.has(stat_key):
				return float(ClickerManager.rt_stats[stat_key])
	
	return 0.0

# Called by Managers whenever their stats update
func report_stat_changed(source: TaskData.TargetSource, stat_key: String) -> void:
	if is_completed or not current_task:
		return
		
	if current_task.target_source == source and current_task.stat_name == stat_key:
		var current_value = get_current_stat_value(source, stat_key)
		var progress = current_value - initial_stat_value
		
		print("Task Progress Update [%s]: %.1f / %d" % [stat_key, progress, current_task.target_amount])
		
		if progress >= current_task.target_amount:
			complete_task()

func complete_task() -> void:
	is_completed = true
	print("Task Completed! Rewarding ", current_task.reward_cookies, " cookies.")
	PlayerManager.add_cookies(current_task.reward_cookies)

func _on_phase_changed(new_phase: Globals.Phase) -> void:
	if new_phase == Globals.Phase.MORNING:
		assign_daily_task()"""
