extends Event

func finish_event():
	await get_tree().create_timer(4.0).timeout
	state = State.GENERATING

func on_tank_hit():
	print("EXPLOSION")
	queue_free()
