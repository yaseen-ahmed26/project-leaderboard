extends Control

@onready var hover_prompt: RichTextLabel = $hover_prompt
@onready var total_cookies: Panel = $total_cookies
@onready var task: Panel = $task
@onready var template: RichTextLabel = $event_list/holder/template
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var phase: Panel = $phase

# Godot
func _ready():
	Signals.cookes_changed.connect(_on_stats_changed)
	Signals.autoclicker_decayed.connect(_on_autoclicker_decayed)
	Signals.phase_changed.connect(_on_phase_changed)
	Signals.afternoon_timer.connect(_on_afternoon_timer)
	Signals.event_added.connect(_on_event_added)
	Signals.event_solved.connect(_on_event_solved)
	Signals.task_progress.connect(_on_task_progress)
	Signals.task_completed.connect(_on_task_completed)

# Interaction
func show_hover_prompt(new_text: String):
	hover_prompt.text = Constants.HOVER_TEXT_FORMAT % new_text
	hover_prompt.visible = true

func hide_hover_prompt():
	hover_prompt.visible = false
	
func show_controls(display_name: String):
	$controls.visible = true
	$controls.text = Constants.CONTROLS_FORMAT % display_name

func hide_controls():
	$controls.visible = false
	
# Signals
func _on_stats_changed(new_stats: Dictionary):
	var label = total_cookies.get_node_or_null("label")
	label.text = Constants.COOKIE_COUNTER_FORMAT % new_stats.get("cookies")

func _on_autoclicker_decayed(new_rate):
	$decay.text = "Decay Rate: %s" % new_rate

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

func _on_afternoon_timer(seconds_elapsed: int):
	var total_secs: int = int(seconds_elapsed)
	var minutes: int = (total_secs % 3600) / 60
	var seconds: int = total_secs % 60
	
	$afternoon_timer.text = "TIME SURVIVED: [color=green]%02d:%02d" % [minutes, seconds]

func _on_event_added(details: EventData):
	var clone: RichTextLabel = template.duplicate()
	
	clone.name = Globals.get_lower_event_id(details.id)
	clone.text = "[color=green]" + details.display_name
	
	var desc = clone.get_node("desc")
	desc.text = details.task
	
	clone.visible = true
	
	$event_list/holder.add_child(clone)

func _on_event_solved(details: EventData):
	var lower_id = Globals.get_lower_event_id(details.id)
	var label = $event_list/holder.get_node_or_null(lower_id)
	
	if label:
		label.queue_free()
		
func _on_phase_changed(new_phase: Globals.Phase):
	var label = phase.get_node("label")
	label.text = "[color=green]" + Globals.get_lower_phase(new_phase).to_upper()
	
	match new_phase:
		Globals.Phase.AFTERNOON:
			animation_player.play("afternoon_start")
		Globals.Phase.NIGHT:
			animation_player.play_backwards("afternoon_start")
