extends StaticBody3D

@export var snack_pool: Array[PackedScene]

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var snack_placements: Node = $snack_placements
@onready var added_snacks: Node = $added_snacks

var open: bool = false

func _ready() -> void:	
	_add_snacks()
	
func _add_snacks():
	var pool_clone: Array[PackedScene] = snack_pool.duplicate(true)
	
	for marker in snack_placements.get_children():
		var chosen_snack: PackedScene = pool_clone.pick_random()
		pool_clone.erase(chosen_snack)
		
		var clone = chosen_snack.instantiate()
		added_snacks.add_child(clone)
		
		clone.global_position = marker.global_position
		
		if clone is RigidBody3D:
			clone.freeze = true
