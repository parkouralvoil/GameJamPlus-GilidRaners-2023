extends Node2D

var previous_campfire: Area2D = null

func _ready():
	for child in get_children():
		if child.has_method("deactivate_campfire"):
			child.Campfire_Activated.connect(update_campfires)
	
func update_campfires(new_campfire: Area2D):
	if previous_campfire != null:
		previous_campfire.deactivate_campfire()
	previous_campfire = new_campfire
