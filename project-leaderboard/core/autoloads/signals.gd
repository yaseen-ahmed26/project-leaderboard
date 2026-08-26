extends Node

# DayManager
signal phase_changed(new_phase: Constants.Phase)
signal afternoon_timer(seconds_elapsed)
signal day_ended()

# ClickManager
signal autoclicker_decayed(new_rate)

# PlayerManager
signal stats_changed(amount: float)

# ConsumableManager
signal snack_used(snack_data: SnackData)

# EventManager
signal event_added(details)
signal event_solved(details)

# TaskManager
signal task_progress(current_task: TaskData, progress: int)
signal task_completed(current_task: TaskData)

# Monitors
signal change_camera(position, source)
signal restore_camera()

# player.gd
signal camera_restored()

# world.gd
signal item_entered_void()
