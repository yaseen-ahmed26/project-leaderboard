extends Event

@onready var pushable_crate: Interactable = $props/pushable_crate
@onready var cabin_interior: Area3D = $cabin_interior

var contained_items: Array = []

func _ready() -> void:
	super()
	
	cabin_interior.body_entered.connect(_on_body_entered)

func on_crate_push():
	pushable_crate.can_interact = false
	
	var top_edge_offset = Vector3(0.0, randf_range(0.8, 1.2), 0.0) 
	
	pushable_crate.apply_impulse(
		Vector3.BACK.normalized() * randf_range(3.0, 5.0), 
		top_edge_offset
	)

func _on_body_entered(body):
	if not body is Holdable: return
	
	if body and not contained_items.has(body):
		contained_items.append(body)

		if contained_items.size() == 5:
			state = State.GENERATING
			
func clean_up():
	print("called: cabin_island.tscn")
	for box in $boxes.get_children():
		print(box.name)
		box.queue_free()
