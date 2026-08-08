extends Control

@onready var hover_prompt: RichTextLabel = $hover_prompt

func show_hover_prompt(new_text: String):
	hover_prompt.text = new_text
	hover_prompt.visible = true

func hide_hover_prompt():
	hover_prompt.visible = false
