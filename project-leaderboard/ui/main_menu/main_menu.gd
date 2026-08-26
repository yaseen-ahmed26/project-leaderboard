extends Control

@onready var background: ColorRect = $background
@onready var fade: ColorRect = $fade

func _on_play_btn_pressed():
	var tween: Tween = create_tween()
	tween.tween_property(
		fade,
		"modulate:a",
		1.0,
		0.5
	)
	
	await tween.finished
	
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.hide()
	
	DayManager.start_day()
	
	var tween_out: Tween = create_tween()
	tween_out.tween_property(
		fade,
		"modulate:a",
		0.0,
		0.5
	)
	await tween_out.finished
	self.hide()
