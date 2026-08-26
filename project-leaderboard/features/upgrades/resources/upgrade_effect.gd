extends Resource
class_name UpgradeEffect

## How much the upgrade costs.
@export var cost: float
## What this upgrade level unlocks. Note that it unlocks this upgrade at level 1.
@export var unlocks: UpgradeData
## The per level description of the upgrade
@export var description: String
