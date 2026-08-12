extends Node3D
class_name Event

@export var event_data: EventData

func event_solved():
	EventManager.event_solved(event_data)
