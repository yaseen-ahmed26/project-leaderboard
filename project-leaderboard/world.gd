extends Node3D

@onready var day_end: Control = $day_end

func _ready() -> void:
	Signals.day_ended.connect(_on_day_ended)

func _on_day_ended(_day_stats: Dictionary):
	day_end.visible = true
