extends Resource
class_name TaskData

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var target_source: Globals.TaskSources
@export var target_stat: String
@export var target_amount: int = 1
@export var cookie_reward: float = 10.0
