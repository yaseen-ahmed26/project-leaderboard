extends Node

var snacks_used: Dictionary[int, String] = {}

var has_used_snack: bool = false

func _use_custom_effect(snack_data: SnackData):
	match snack_data.id:
		"snack_apple":
			# would go in a ClickManager, not made yet.
			# Could also make everything a resource, like custom resources for events like these.
			PlayerManager.edit_autoclick_decay(snack_data.effect_info.get("value"))

func use_snack(snack_data: SnackData) -> bool:
	if has_used_snack: return false
	
	snacks_used[snacks_used.size() + 1] = snack_data.id
	has_used_snack = true
	
	match snack_data.effect:
		SnackData.Effect.NONE:
			return false
		SnackData.Effect.STAT_BUFF:
			PlayerManager.edit_stat(snack_data.effect_info, snack_data.id)
		SnackData.Effect.REDUCE_EVENT:
			# Will go in the EventManager
			# Not made yet
			return false
		SnackData.Effect.CUSTOM:
			_use_custom_effect(snack_data)
	
	return true
