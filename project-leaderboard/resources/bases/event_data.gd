extends Resource
class_name EventData

@export var id: Globals.EventIDs
@export var display_name: String
@export var task: String
@export var blacklist: Array[Globals.EventIDs]
@export var has_background_task: bool = false
