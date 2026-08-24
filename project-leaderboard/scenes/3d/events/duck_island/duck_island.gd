extends Event

@onready var hoop_detection: Area3D = $basketball_hoop/hoop/hoop_detection

func _ready() -> void:
	super()
	
	hoop_detection.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not body is Holdable: return
	if state == State.GENERATING: return
	
	if body:
		state = State.GENERATING
