extends CanvasLayer
class_name PauseMenuScreen

signal pressed_options
signal pressed_return_to_menu
signal hide_options

var can_pause: bool = false ## Main scene sets this, this becomes true when theres a level

@onready var meme: Label = $Meme

func _input(event: InputEvent) -> void:
	if not can_pause:
		return
	
	if event.is_action_pressed("pause"):
		if not visible:
			show()
			get_tree().paused = true
			meme.hide()
		else:
			hide()
			get_tree().paused = false
			hide_options.emit()
	


func _on_resume_pressed() -> void:
	hide()
	get_tree().paused = false


func _on_options_pressed() -> void:
	pressed_options.emit()


func _on_difficulty_meme_pressed() -> void:
	meme.visible = not meme.visible


func _on_return_to_menu_pressed() -> void:
	pressed_return_to_menu.emit()
