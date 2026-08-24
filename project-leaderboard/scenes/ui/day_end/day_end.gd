extends Control

@onready var fade: ColorRect = $fade
@onready var background: ColorRect = $background

func _ready() -> void:
	Signals.day_ended.connect(setup)

func setup(details: Dictionary):
	$background/cookies_earnt.text = "Cookies Earnt: [color=green]%.1f" % details.get("cookies")
	$background/left_desk.text = "Left Desk: [color=green]%d [color=white]%s" % [details.get("left_desk"), "time" if details.get("left_desk") == 1 else "times"] 
	$background/task_completed.text = "Task: [color=%s]%s" % [
		"green" if details.get("task_completed") else "red",
		"Completed" if details.get("task_completed") else "Failed"
	]
	$background/islands_solved.text = "Islands Solved\n[color=green]%s" % ", ".join(details.get("events_solved"))
	
	var tween: Tween = create_tween()
	tween.tween_property(
		fade,
		"modulate:a",
		1,
		0.5
	)
	await tween.finished
	
	var bg_tween: Tween = create_tween()
	bg_tween.tween_property(
		background,
		"modulate:a",
		1,
		0.5
	)
