extends SharedUI

@onready var click_effect: RichTextLabel = $click_effect

func _ready() -> void:
	super()

func _on_clicker_btn_pressed() -> void:
	ClickerManager.click_cookie()
	
	var clone: RichTextLabel = click_effect.duplicate()
	
	self.add_child(clone)
	var starting_position = Vector2(randf_range(100, 1700), 1080)
	var end_position = starting_position - Vector2(0, randf_range(200, 1000))

	clone.text = "+%d" % 1
	clone.position = starting_position
	
	var tween: Tween = create_tween()
	tween.tween_property(clone, "position", end_position, 0.4)
	
	await get_tree().create_timer(1.0).timeout
	
	var tween_fade: Tween = create_tween()
	tween_fade.tween_property(clone, "modulate:a", 0.0, 0.4)
	
	await tween_fade.finished
	clone.queue_free()
