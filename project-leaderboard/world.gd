extends Node3D

@onready var day_end: Control = $CanvasLayer/day_end
@onready var added_events: Node = $added_events
@onready var player: CharacterBody3D = $player
@onready var void_zone: Area3D = $void_zone

@export var event_scenes: Dictionary[Globals.EventIDs, PackedScene]

var markers: Array[Node] = []

func _ready() -> void:
	markers = $event_placements.get_children()
	
	void_zone.body_entered.connect(_on_body_entered)
	
	Signals.event_added.connect(_on_event_added)
	# Signals.event_solved.connect(_on_event_solved)
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
		
		scene.clean_up()
		scene.queue_free()

func _clear_all_events():
	for event in added_events.get_children():
		# print(event.get_current_state())
		
		event.clean_up()
		
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
		Globals.Phase.MORNING:
			player.visible = true
			player.get_node("head/camera").current = true
		Globals.Phase.NIGHT:
			# void_zone.set_collision_mask_value(1, false)
			# void_zone.set_collision_mask_value(2, false)
			_clear_all_events()

func _on_body_entered(body: Node3D):
	print("Body Entered: " + body.name)
	Signals.item_entered_void.emit(body)
	
	if body.is_in_group("player"):
		body.global_position = $player_respawn.global_position
		return
		
	if body is CharacterBody3D:
		return
		
	if body is Node3D:
		return
	
	if body is not Holdable:
		return
		
	if body.respawn_marker and body.respawn_marker != null:
		body.global_position = body.respawn_marker.global_position
	else:
		body.global_position = $player_respawn.global_position
