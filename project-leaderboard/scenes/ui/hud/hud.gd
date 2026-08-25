extends SharedUI

@onready var hover_prompt: RichTextLabel = $hover_prompt
@onready var template: RichTextLabel = $event_list/holder/template
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var phase: Panel = $left_hud/phase
@onready var left_hud: Control = $left_hud

const LEFT_HUD_HIDDEN_POSITION := Vector2(-516.0, 0.0)
const LEFT_HUD_SHOWN_POSITION := Vector2(0.0, 0.0)

# Godot
func _ready():
	super()
	
	Signals.autoclicker_decayed.connect(_on_autoclicker_decayed)
	Signals.phase_changed.connect(_on_phase_changed)
	Signals.afternoon_timer.connect(_on_afternoon_timer)
	Signals.event_added.connect(_on_event_added)
	Signals.event_solved.connect(_on_event_solved)
	Signals.change_camera.connect(_on_camera_change)
	Signals.camera_restored.connect(_on_camera_restored)
	Signals.day_ended.connect(_on_day_ended)

# Interaction
func show_hover_prompt(new_text: String):
	hover_prompt.text = Constants.HOVER_TEXT_FORMAT % new_text
	
	if owner.on_terminal:
		hide_hover_prompt()
	else:
		var fade_tween: Tween = create_tween()
		fade_tween.tween_property(
			hover_prompt,
			"modulate:a",
			1.0,
			0.15
		)

func hide_hover_prompt():
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(
		hover_prompt,
		"modulate:a",
		0.0,
		0.15
	)
	
func show_controls(item: Holdable):	
	var text = "[color=gold]%s\n%s"
	var controls_copy: Dictionary = Constants.CONTROLS_FORMAT.duplicate_deep()
	
	if not item.get_throw_status():
		controls_copy.erase("throw")
	elif not item.get_use_status():
		controls_copy.erase("use")
	
	$controls.visible = true
	$controls.text = text % [item.display_name, "\n".join(controls_copy.values())]

func hide_controls():
	$controls.visible = false
	
# Signals
func _on_autoclicker_decayed(new_rate):
	$decay.text = "Decay Rate: %s" % new_rate

func _on_afternoon_timer(seconds_elapsed: int):
	var total_secs: int = int(seconds_elapsed)
	var minutes: int = (total_secs % 3600) / 60
	var seconds: int = total_secs % 60
	
	$afternoon_timer.text = "[color=green]%02d:%02d" % [minutes, seconds]

func _on_event_added(details: EventData):
	var clone: RichTextLabel = template.duplicate()
	$event_list/holder.add_child(clone)
	
	clone.name = Globals.get_lower_event_id(details.id)
	clone.text = "[color=green][!] [color=white]" + details.display_name
	
	var desc = clone.get_node("desc")
	desc.text = "- " + details.task
	
	clone.visible = true
	
	var tween: Tween = create_tween()
	tween.tween_property(
		clone,
		"modulate:a",
		1.0,
		0.5
	)

func _on_event_solved(details: EventData):
	var lower_id = Globals.get_lower_event_id(details.id)
	var label = $event_list/holder.get_node_or_null(lower_id)
	
	if label:
		var tween: Tween = create_tween()
		tween.tween_property(
			label,
			"modulate:a",
			0.0,
			0.5
		)
		await tween.finished
		label.queue_free()
		
func _on_phase_changed(new_phase: Globals.Phase):
	var label = phase.get_node("label")
	label.text = Globals.get_lower_phase(new_phase).to_upper()
	
	match new_phase:
		Globals.Phase.AFTERNOON:
			animation_player.play("afternoon_start")
		Globals.Phase.NIGHT:
			animation_player.play_backwards("afternoon_start")

func _tween_hud(target_position: Vector2):
	var tween: Tween = create_tween()
	tween.tween_property(
		left_hud,
		"position",
		target_position,
		0.5
	).set_trans(Tween.TRANS_SINE)

func _on_camera_change(_position, _source):
	_tween_hud(LEFT_HUD_HIDDEN_POSITION)
	$crosshair.visible = false
	
func _on_camera_restored():
	_tween_hud(LEFT_HUD_SHOWN_POSITION)
	$crosshair.visible = true

func _on_day_ended(_stats):
	_tween_hud(LEFT_HUD_HIDDEN_POSITION)
	$crosshair.visible = false
