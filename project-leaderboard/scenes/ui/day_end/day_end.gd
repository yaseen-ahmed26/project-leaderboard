extends Control

func _ready() -> void:
	pass
	# Signals.day_ended.connect(setup)

func setup(details: Dictionary):
	$background/cookies_earnt.text = "Cookies Earnt: %.1f" % details.get("cookies")
	$background/left_desk.text = "Left Desk: %d %s" % [details.get("left_desk"), "time" if details.get("left_desk") == 1 else "times"] 
	$background/cookies_earnt3.text = "Distractions Solved:\n%s" % ", ".join(details.get("distractions_solved"))
