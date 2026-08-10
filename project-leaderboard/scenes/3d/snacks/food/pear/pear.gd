extends Snack

func _ready() -> void:
	super()
	$Label3D.text = snack_data.description
