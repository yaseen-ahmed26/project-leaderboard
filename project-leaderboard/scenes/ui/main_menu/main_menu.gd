extends Control

@onready var background: ColorRect = $background

func _on_play_btn_pressed():
	var tween: Tween = create_tween()
	tween.tween_property(
		background,
		"modulate:a",
		0.0,
		0.5
	)
	
	await tween.finished
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
