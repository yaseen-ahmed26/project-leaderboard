extends SharedUI

func _ready() -> void:
	super()

func _on_button_pressed() -> void:
	ClickerManager.click_cookie()
