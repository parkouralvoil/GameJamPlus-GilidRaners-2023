extends CanvasLayer
class_name GameOverScreen

signal restart_pressed

func _on_button_pressed() -> void:
	restart_pressed.emit()
