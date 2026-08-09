extends Control

@onready var hover_prompt: RichTextLabel = $hover_prompt
@onready var cookie_counter: RichTextLabel = $cookie_counter

func _ready() -> void:
	Signals.stats_changed.connect(_on_stats_changed)
	Signals.autoclicker_decayed.connect(_on_autoclicker_decayed)
	Signals.day_started.connect(_on_day_started)
	Signals.phase_changed.connect(_on_phase_changed)
	Signals.afternoon_timer.connect(_on_afternoon_timer)

func show_hover_prompt(new_text: String):
	hover_prompt.text = new_text
	hover_prompt.visible = true

func hide_hover_prompt():
	hover_prompt.visible = false

func _on_stats_changed(new_stats: Dictionary):
	cookie_counter.text = "COOKIES: %.1f" % new_stats.get("cookies")

func _on_autoclicker_decayed(new_rate):
	$decay.text = "AUTOCLICKER DECAY: %s" % str(new_rate)

func _on_day_started():
	$phase.text = "DAY 1: PHASE Morning"

func _on_phase_changed(new_phase: String):
	$phase.text = "DAY 1: PHASE %s" % new_phase.capitalize()
	
	if new_phase == "afternoon":
		$afternoon_timer.visible = true
		$afternoon_timer.text = "00:00"
	else:
		$afternoon_timer.visible = false

func _on_afternoon_timer(seconds_elapsed: int):
	var total_secs: int = int(seconds_elapsed)
	var minutes: int = (total_secs % 3600) / 60
	var seconds: int = total_secs % 60
	
	$afternoon_timer.text = "%02d:%02d" % [minutes, seconds]
