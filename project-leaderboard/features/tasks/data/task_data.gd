@tool
extends Resource
class_name TaskData

enum Mode {
	ACTION,
	STAT
}

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var target_source: Constants.TaskSources
@export var target_amount: int = 1
@export var cookie_reward: float = 10.0
@export var mode: Mode = Mode.STAT:
	set(value):
		mode = value
		target = 0
		notify_property_list_changed()

var target: int = 0

func _get_property_list() -> Array[Dictionary]:
	var enum_keys := Constants.Stats.keys() if mode == Mode.STAT else Constants.Actions.keys()

	return [{
		"name": "target",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(enum_keys),
		"usage": PROPERTY_USAGE_DEFAULT
	}]
