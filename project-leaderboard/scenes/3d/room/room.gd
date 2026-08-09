extends Node3D

@onready var markers: Node = $markers

const EVENTS: Array[Dictionary] = [
	{
		"scene": preload("res://scenes/3d/events/delivery/delivery.tscn"),
		"name": "delivery"
	},
]
const TIMINGS: Array[int] = [5]

func _ready():
	Signals.afternoon_timer.connect(_on_afternoon_timer)

func _on_afternoon_timer(seconds_elapsed: int):
	if not TIMINGS.has(seconds_elapsed): return
	
	var v = EVENTS.pick_random()
	var clone = v["scene"].instantiate()
	self.add_child(clone)
	
	var positions = markers.get_node_or_null(v.get("name"))
	var pos: Marker3D = positions.get_children().pick_random()
	
	clone.global_transform = pos.global_transform
