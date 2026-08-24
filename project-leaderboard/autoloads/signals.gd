extends Node

# DayManager
signal phase_changed(new_phase: Globals.Phase)
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

# player.gd
signal camera_restored()

"""signal change_camera(position: Vector3)
signal stats_changed(new_stats: Dictionary)
signal autoclicker_decayed(new_rate)
signal day_started()
signal phase_changed(new_phase: String)
signal afternoon_timer(seconds_elapsed)
signal event_added(details: Dictionary)
signal event_removed(details: Dictionary)
signal day_ended(stats)"""
