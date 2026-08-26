extends Node

# DayManager
const AFTERNOON_LENGTH: float = 60.0

# EventManager
const MAX_ACTIVE_EVENTS: int = 3 
const INITAL_EVENT_SPAWN: int = 2
const INITAL_EVENT_SPAWN_TIME: int = 1

# Event Class
const TIME_TO_CORRUPT_MIN := 8
const TIME_TO_CORRUPT_MAX := 15

# tank.gd
const TURRET_DELAY_SPEED: float = 4.0

# player.gd, interaction.gd
const CAMERA_TWEEN_TIME: float = 0.5
const THROW_FORCE: float = 7.0
const THROW_SPIN_MIN: float = 0.1
const THROW_SPIN_MAX: float = 0.3
const DROP_SPEED: float = 1.0
const DROP_DISTANCE: float = 0.2
const TERMINAL_FLASHLIGHT_BRIGHTNESS: float = 0.3

# UI
const HOVER_TEXT_FORMAT: String = "[color=green][E] [color=white]%s"
const COOKIE_COUNTER_FORMAT: String = "COOKIES: [color=green]%.1f"
const TASK_FORMAT: String = "Task: [color=green]%s\n[color=white]%s\nProgress: [color=green]%d/%d"
const TASK_COMPLETE_FORMAT: String = "Task: [color=green]%s\n[color=white]%s\n[color=gold]COMPLETE!"
const CONTROLS_FORMAT: Dictionary[String, String] = {
	"use": "[color=white]Use [color=green][LMB]",
	"throw": "[color=white]Throw [color=green][R]",
	"drop": "[color=white]Drop [color=green][T]"
}
const FELL_VOID_FORMAT: String = "[color=white]Fell into the Void [color=green]%d [color=white]%s"
const ITEM_VOID_FOMRAT: String = "[color=green]%d [color=white]%s thrown into the Void"

# Global
const GAME_TITLE: String = "Yes, I'm on Vacation"

# Enums
enum Phase {
	MORNING,
	AFTERNOON,
	NIGHT,
	MIDNIGHT
}

enum EventIDs {
	CABIN_ISLAND,
	DUCK_ISLAND,
	THIEF_ISLAND
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

enum CameraSources {
	PLAYER,
	TANK,
	CLICKER_MONITOR,
	UPGRADE_MONITOR,
	CANNON
}

func get_lower_event_id(event_id: EventIDs):
	return EventIDs.keys()[event_id].to_lower()

func get_lower_phase(phase: Phase):
	return Phase.keys()[phase].to_lower()

func get_lower_stat(stat: Stats):
	return Stats.keys()[stat].to_lower()
