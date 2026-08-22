extends Node

# DayManager
const AFTERNOON_LENGTH: float = 50.0

# EventManager
const MAX_ACTIVE_EVENTS: int = 3 
const INITAL_EVENT_SPAWN: int = 2
const INITAL_EVENT_SPAWN_TIME: int = 1

# tank.gd
const TURRET_DELAY_SPEED: float = 4.0

# player.gd, interaction.gd
const CAMERA_TWEEN_TIME: float = 0.5
const THROW_FORCE: float = 7.0
const THROW_SPIN_MIN: float = 0.2
const THROW_SPIN_MAX: float = 0.5
const DROP_SPEED: float = 1.0
const DROP_DISTANCE: float = 0.2

# UI
const HOVER_TEXT_FORMAT: String = "[color=green][E] [color=white]%s"
const COOKIE_COUNTER_FORMAT: String = "COOKIES: [color=green]%.1f"
const TASK_FORMAT: String = "Task: [color=green]%s\n[color=white]%s\nProgress: [color=green]%d/%d"
const TASK_COMPLETE_FORMAT: String = "Task: [color=green]%s\n[color=white]%s\n[color=gold]COMPLETE!"
const CONTROLS_FORMAT: String = "[color=gold]%s\n[color=green][LMB] [color=white]Use\n[color=green][R] [color=white]Drop\n[color=green][T] [color=white]Throw"

# Global
const GAME_TITLE: String = "Yes, I'm on Vacation"
