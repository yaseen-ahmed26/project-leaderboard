extends Node3D

@onready var day_end: Control = $day_end
@onready var added_events: Node = $added_events

@export var event_scenes: Dictionary[Globals.EventIDs, PackedScene]

var markers: Array[Node] = []

func _ready() -> void:
	markers = $event_placements.get_children()
	
	Signals.event_added.connect(_on_event_added)
	Signals.event_solved.connect(_on_event_solved)
	Signals.phase_changed.connect(_on_phase_changed)
	Signals.day_ended.connect(_on_day_ended)
	
func _on_day_ended(_day_stats: Dictionary):
	day_end.visible = true

func _on_event_added(event_data: EventData):
	if markers.is_empty():
		push_warning("No event markers")
		return
	
	var scene = event_scenes.get(event_data.id)
	var clone: Node3D = scene.instantiate()
	clone.name = Globals.get_lower_event_id(event_data.id)
	added_events.add_child(clone)
	
	var random_marker: Marker3D = markers.pick_random()
	markers.erase(random_marker)
	
	clone.set_meta("marker_node", random_marker)
	clone.global_position = random_marker.global_position

func _on_event_solved(event_data: EventData):
	var scene = added_events.get_node_or_null(Globals.get_lower_event_id(event_data.id))

	if scene:
		var recovered_marker = scene.get_meta("marker_node") 
		markers.append(recovered_marker)
		
		scene.queue_free()

func _clear_all_events():
	for event in added_events.get_children():
		if event.has_meta("marker_node"):
			var recovered_marker = event.get_meta("marker_node")
			if not markers.has(recovered_marker):
				markers.append(recovered_marker)

		var tween: Tween = create_tween()
		tween.tween_property(
			event,
			"position",
			event.position - Vector3(0, 60, 0),
			3.0
		).set_ease(Tween.EASE_IN).set_trans(Tween.TransitionType.TRANS_SINE)
		
		tween.finished.connect(event.queue_free)

func _on_phase_changed(new_phase: Globals.Phase):
	match new_phase:
		Globals.Phase.NIGHT:
			_clear_all_events()
