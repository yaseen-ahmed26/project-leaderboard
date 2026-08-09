extends Interactable

var details = {
	"name": "delivery",
	"hud_description": "Get the delivery"
}

func _ready() -> void:
	super()
	
func on_interaction():
	queue_free()
	Signals.event_removed.emit(details)
