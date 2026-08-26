extends Interactable

@onready var animation_player: AnimationPlayer = $"../../../../AnimationPlayer"

var open: bool = false
	
func on_interaction():
	if open:
		animation_player.play_backwards("door_open")
		hover_text = "Open Fridge"
	else:
		animation_player.play("door_open")
		hover_text = "Close Fridge"
	
	open = not open
