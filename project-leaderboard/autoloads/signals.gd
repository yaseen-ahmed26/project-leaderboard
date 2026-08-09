extends Node

signal change_camera(position: Vector3)
signal stats_changed(new_stats: Dictionary)
signal autoclicker_decayed(new_rate)
signal day_started()
signal phase_changed(new_phase: String)
signal afternoon_timer(seconds_elapsed)
