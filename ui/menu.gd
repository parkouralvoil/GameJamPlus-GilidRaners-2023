extends CanvasLayer
class_name MainMenu

signal pressed_play

func _ready() -> void:
	pass


func _on_button_play_pressed() -> void:
	pressed_play.emit()
	print("pressed play")


func _on_button_options_pressed() -> void:
	pass # Replace with function body.


func _on_button_exit_pressed() -> void:
	get_tree().quit() # Replace with function body.
