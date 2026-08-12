extends Node3D

@onready var day_end: Control = $day_end

@export var event_scenes: Dictionary[Globals.EventIDs, PackedScene]

var markers: Array[Node] = []

func _ready() -> void:
	markers = $event_placements.get_children()
	
	Signals.event_added.connect(_on_event_added)
	Signals.event_solved.connect(_on_event_solved)
	# Signals.day_ended.connect(_on_day_ended)
	pass

func _on_day_ended(_day_stats: Dictionary):
	day_end.visible = true

func _on_event_added(event_data: EventData):
	var scene = event_scenes.get(event_data.id)
	var clone: Node3D = scene.instantiate()
	clone.name = Globals.get_lower_event_id(event_data.id)
	add_child(clone)
	
	var random_marker: Marker3D = markers.pick_random()
	markers.erase(random_marker)
	
	clone.set_meta("marker_node", random_marker)
	clone.global_position = random_marker.global_position

func _on_event_solved(event_data: EventData):
	var scene = get_node_or_null(Globals.get_lower_event_id(event_data.id))

	if scene:
		var recovered_marker = scene.get_meta("marker_node") 
		markers.append(recovered_marker)
		
		scene.queue_free()
