extends Snack

func _ready() -> void:
	super()
	$Label3D.text = self.description
