extends CanvasLayer
class_name PauseMenuScreen

var can_pause: bool = false ## Main scene sets this, this becomes true when theres a level


func _unhandled_input(event: InputEvent) -> void:
	if not can_pause:
		return
	
	if event.is_action_pressed("pause"):
		if not visible:
			show()
			get_tree().paused = true
		else:
			hide()
			get_tree().paused = false
	
