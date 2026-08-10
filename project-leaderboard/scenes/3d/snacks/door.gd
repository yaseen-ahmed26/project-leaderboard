extends Interactable

@onready var animation_player: AnimationPlayer = $"../../../AnimationPlayer"

var open: bool = false

func _ready() -> void:
	super()
	
func on_interaction():
	if open:
		animation_player.play_backwards("door_open")
		hover_text = "[E] Close Fridge"
	else:
		animation_player.play("door_open")
		hover_text = "[E] Open Fridge"
	
	open = not open
