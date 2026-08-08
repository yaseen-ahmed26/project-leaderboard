extends CollisionObject3D
class_name Interactable

@export var hover_text: String = "None Set"

func _ready() -> void:
	self.add_to_group("Interactables")

func get_hover_text():
	return hover_text

func on_interaction():
	print(self.name)
