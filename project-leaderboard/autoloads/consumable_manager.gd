extends Node

var snacks_used: Dictionary[int, String] = {}
var has_used_snack: bool = false

func use_snack(snack_data: SnackData):
	if has_used_snack: 
		return false
	
	snacks_used[snacks_used.size() + 1] = snack_data.id
	has_used_snack = true
	Signals.snack_used.emit(snack_data)
	
	for effect in snack_data.effects:
		if effect:
			effect.apply_effect()
	
	return true
