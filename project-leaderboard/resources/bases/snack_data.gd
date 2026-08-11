extends Resource
class_name SnackData

## The ID for the Snack. This must be unique as it may be used to store saves.
@export var id: String = ""
## The name of the Snack.
@export var display_name: String = ""
## What the Snack does.
@export var description: String = ""
## The stat change to display for UI.
@export var stat_change: String = ""
## The effects the Snack applies.
@export var effects: Array[SnackEffect] = []
