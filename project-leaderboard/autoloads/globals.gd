extends Node

enum Phase {
	MORNING,
	AFTERNOON,
	NIGHT,
	MIDNIGHT
}

enum EventIDs {
	TEST_2,
	CABIN_ISLAND,
	DUCK_ISLAND
}

enum TaskSources {
	NONE,
	PLAYER_ACTION,
	PLAYER_STAT,
	CLICKER_STAT,
	CLICKER_ACTION,
	SNACK,
	UPGRADE_PURCHASE
}

enum Stats {
	COOKIES_PER_CLICK,
	CLICK_MULTIPLIER,
	PASSIVE_GENERATION,
	DECAY_MULTIPLIER,
	AUTO_DECAY,
	COOKIES,
	CRUMBS,
	LEFT_DESK
}

enum Actions {
	PLAYER_JUMP,
	PLAYER_MOVE,
	UPGRADE_BOUGHT
}

func get_lower_event_id(event_id: EventIDs):
	return EventIDs.keys()[event_id].to_lower()

func get_lower_phase(phase: Phase):
	return Phase.keys()[phase].to_lower()

func get_lower_stat(stat: Stats):
	return Stats.keys()[stat].to_lower()
