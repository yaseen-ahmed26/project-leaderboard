extends Event

var entities: Array[CharacterBody3D] = []

func _ready() -> void:
	super()
	
	entities.append($entity)
	entities.append($entity2)
	
	Signals.item_entered_void.connect(_on_item_entered_void)

func _on_item_entered_void(body: Node3D):
	if entities.is_empty(): return
	if body in entities:
		entities.erase(body)
		body.queue_free()
		
		if entities.is_empty():
			state = State.GENERATING
