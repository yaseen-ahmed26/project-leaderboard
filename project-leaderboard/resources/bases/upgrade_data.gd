extends Resource 
class_name UpgradeData

enum Category {
	NONE, ## No category
	CLICKER, ## For the main clicker 
	EVENTS ## For events
}

## The ID of the uprgade, must be unique. Used for saving.
@export var id: String = ""
## The category the UI should place this upgrade in.
@export var category: Category = Category.NONE
## The display name, used by the UI.
@export var display_name: String = ""
## The description, used by the UI.
@export var description: String = ""
## The number of levels this upgrade has.
@export var total_levels: int = 5
## An array of the levels and their specific effects.
@export var level_effects: Array[UpgradeEffect]
