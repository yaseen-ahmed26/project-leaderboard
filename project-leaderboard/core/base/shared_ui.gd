extends Control
class_name SharedUI

var total_cookies: Panel
var task: Panel

func _ready() -> void:
	total_cookies = $left_hud/total_cookies
	task = $left_hud/task

	Signals.stats_changed.connect(_on_stats_changed)
	Signals.task_progress.connect(_on_task_progress)
	Signals.task_completed.connect(_on_task_completed)

func _on_stats_changed(new_stats: Dictionary):
	if not total_cookies: 
		push_warning("No total_cookies panel set")
		return
	
	var label = total_cookies.get_node_or_null("label")
	label.text = Constants.COOKIE_COUNTER_FORMAT % new_stats.get("cookies")

func _on_task_progress(current_task: TaskData, progress: int):
	var label = task.get_node("label")
	label.text = Constants.TASK_FORMAT % [
		current_task.display_name,
		current_task.description,
		progress,
		current_task.target_amount
	]

func _on_task_completed(current_task: TaskData):
	var label = task.get_node("label")
	label.text = Constants.TASK_COMPLETE_FORMAT % [
		current_task.display_name,
		current_task.description,
	]
