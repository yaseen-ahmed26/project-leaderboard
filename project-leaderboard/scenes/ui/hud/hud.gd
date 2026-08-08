extends Control

@onready var hover_prompt: RichTextLabel = $hover_prompt
@onready var cookie_counter: RichTextLabel = $cookie_counter

func _ready() -> void:
	Signals.stats_changed.connect(_on_stats_changed)

func show_hover_prompt(new_text: String):
	hover_prompt.text = new_text
	hover_prompt.visible = true

func hide_hover_prompt():
	hover_prompt.visible = false

func _on_stats_changed(new_stats: Dictionary):
	cookie_counter.text = "COOKIES: %d" % new_stats.get("cookies")
