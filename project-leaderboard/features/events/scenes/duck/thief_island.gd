extends Event

@onready var void_zone: Area3D = $void_zone

var entities: Array = []

func _ready() -> void:
	super()
	
	entities.append($entity)
	entities.append($entity2)
	
	void_zone.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):	
	if entities.has(body):
		entities.erase(body)
		body.queue_free()
		
		if entities.is_empty():
			state = State.GENERATING
	
	if body is Player:
		PlayerManager.player.respawn()
		# PlayerManager.player.teleport_to(respawn_marker.global_position)

func on_player_enter():
	for entity in entities:
		entity.is_active = true
