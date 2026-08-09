extends CollisionObject3D
class_name Interactable

@export var hover_text: String = "None Set"
@export var can_interact: bool = true
## Disable the Interactable at specific phases of the day. Bitmasks correspond to the flag, i.e. 'Morning' is 1, 'Afternoon' is 2 and 'Night' is 4.
@export_flags("Morning", "Afternoon", "Night") var disable_at: int

const MORNING_FLAG: int = 1
const AFTERNOON_FLAG: int = 2
const NIGHT_FLAG: int = 4

func _ready() -> void:
	self.add_to_group("Interactables")
	
	Signals.phase_changed.connect(_on_phase_changed)

func get_hover_text():
	return hover_text
	
func get_interact_status():
	return can_interact

func on_interaction():
	print(self.name)

func _on_phase_changed(new_phase: String):
	var phase_lower = new_phase.to_lower()
	var current_flag = 0
	
	match phase_lower:
		"morning": current_flag = MORNING_FLAG
		"afternoon": current_flag = AFTERNOON_FLAG
		"night": current_flag = NIGHT_FLAG
	
	can_interact = not (disable_at & current_flag)
