extends Control

@onready var fade: ColorRect = $fade
@onready var background: ColorRect = $background

func _ready() -> void:
	Signals.day_ended.connect(setup)

func setup(details: Dictionary):
	$background/cookies_earnt.text = "[color=green]%.1f [color=white]Cookies Earnt" % details.get("cookies")
	$background/left_desk.text = "Left Desk: [color=green]%d [color=white]%s" % [details.get("left_desk"), "time" if details.get("left_desk") == 1 else "times"] 
	$background/task_completed.text = "Task [color=%s]%s" % [
		"green" if details.get("task_completed") else "red",
		"Completed" if details.get("task_completed") else "Failed"
	]
	$background/islands_solved.text = "Islands Solved\n[color=green]%s" % ", ".join(details.get("events_solved"))
	$background/items_in_void.text = Constants.ITEM_VOID_FOMRAT % [
		details.get("times_item_fell_void"),
		"item" if details.get("times_item_fell_void") == 1 else "items"
	]
	$background/fell_in_void.text = Constants.FELL_VOID_FORMAT % [
		details.get("times_player_fell_void"),
		"time" if details.get("times_player_fell_void") == 1 else "times"
	]
	
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
