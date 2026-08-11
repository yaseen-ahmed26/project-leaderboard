extends CollisionObject3D
class_name Interactable

## A unique ID for this interactable
@export var id: String
## The name for UI to display
@export var display_name: String
## The text shown on the HUD when hovering.
@export var hover_text: String = "None Set"
## If 'True', allows the item to be interacted with.
@export var can_interact: bool = true
## The item needed for the interaction of this item.
@export var item_needed: String = "ID here"
## Disable the Interactable at specific phases of the day. Bitmasks correspond to the flag, i.e. 'Morning' is 1, 'Afternoon' is 2 and 'Night' is 4.
@export_flags("Morning", "Afternoon", "Night") var disable_at: int

const MORNING_FLAG: int = 1
const AFTERNOON_FLAG: int = 2
const NIGHT_FLAG: int = 4

func _ready() -> void:
	self.add_to_group("Interactables")
	
	Signals.phase_changed.connect(_on_phase_changed)

# Getters
func get_hover_text():
	return hover_text
	
func get_interact_status():
	return can_interact

func get_item_needed():
	return item_needed

# Defaults
func on_interaction():
	print(self.name)

func _on_phase_changed(new_phase: Globals.Phase):
	var current_flag = 0
	
	match new_phase:
		Globals.Phase.MORNING: current_flag = MORNING_FLAG
		Globals.Phase.AFTERNOON: current_flag = AFTERNOON_FLAG
		Globals.Phase.NIGHT: current_flag = NIGHT_FLAG
	
	can_interact = not (disable_at & current_flag)
