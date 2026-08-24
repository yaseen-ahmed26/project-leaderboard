extends Node

"""
TaskManager
Tracks daily microtask
Tracks weekly task
"""

@export var base_task_pool: Array[TaskData] = []

var current_source: Globals.TaskSources = Globals.TaskSources.NONE
var current_task: TaskData
var progress: int = 0
var target: int

var rt_stats = {
	"task_completed": false
}

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

func report_task_update(stat_name):
	if rt_stats["task_completed"]: return
	
	var add_progress: bool = false
	
	if current_task.mode == TaskData.Mode.STAT:
		var stat_enum: Globals.Stats = current_task.target as Globals.Stats
		
		if stat_enum == stat_name:
			add_progress = true
	elif current_task.mode == TaskData.Mode.ACTION:
		var stat_enum: Globals.Actions = current_task.target as Globals.Actions
		
		if stat_enum == stat_name:
			add_progress = true
	
	if add_progress:
		progress += 1
		Signals.task_progress.emit(current_task, progress)
	
	if progress == target:
		rt_stats["task_completed"] = true
		current_source = Globals.TaskSources.NONE
		PlayerManager.add_cookies(current_task.cookie_reward)
		Signals.task_completed.emit(current_task)

# Getters
func get_current_task_source():
	return current_source
	
func get_rt_stats():
	return rt_stats

# Connections
func _on_phase_changed(new_phase: Globals.Phase):
	match new_phase:
		Globals.Phase.MORNING:
			generate_task()
