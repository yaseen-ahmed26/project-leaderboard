extends Node

var used_snack: bool = false

func use_snack(id: String):
	if used_snack: return
	
	used_snack = true
	PlayerManager.parse_snack(id)
