extends Event

@onready var hoop_detection: Area3D = $basketball_hoop/hoop/hoop_detection
@onready var void_zone: Area3D = $void_zone

func _ready() -> void:
	super()
	
	hoop_detection.body_entered.connect(_on_hoop_body_entered)
	void_zone.body_entered.connect(_on_void_body_entered)

func _on_hoop_body_entered(body):
	if not body is Holdable: return
	if state == State.GENERATING: return
	
	if body:
		state = State.GENERATING

func _on_void_body_entered(body: Node3D):		
	if body is Player:
		PlayerManager.player.respawn()
	else:
		body.global_position = respawn_marker.global_position

func on_player_enter():
	pass
