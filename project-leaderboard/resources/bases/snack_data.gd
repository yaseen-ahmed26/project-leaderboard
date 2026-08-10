extends Resource
class_name SnackData

enum Effect {
	NONE, ## Default. No effect will be applied.
	STAT_BUFF, ## Changes the value of a player stat. 
	REDUCE_EVENT, ## Reduces the likelihood of event occurring. 
	CUSTOM ## Custom defined events that must be parsed through by ConsumableManager.
}

## The ID for the Snack. This must be unique as it may be used to store saves.
@export var id: String = ""
## The name of the Snack.
@export var display_name: String = ""
## What the Snack does.
@export var description: String = ""
## The stat change to display for UI.
@export var stat_change: String = ""
## What type of effect does the Snack provide.
@export var effect: Effect = Effect.NONE
## The details of the effect.
@export var effect_info: Dictionary
