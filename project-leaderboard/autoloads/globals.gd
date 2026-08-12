extends Node

enum Phase {
	MORNING,
	AFTERNOON,
	NIGHT,
	MIDNIGHT
}

enum EventIDs {
	TEST_1,
	TEST_2,
	TEST_3,
	TEST_4,
	TEST_5,
	TEST_6
}

func get_lower_event_id(event_id: EventIDs):
	return EventIDs.keys()[event_id].to_lower()

func get_lower_phase(phase: Phase):
	return Phase.keys()[phase].to_lower()
