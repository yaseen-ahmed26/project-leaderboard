extends Event

func finish_event():
	await get_tree().create_timer(4.0).timeout
	state = State.GENERATING
