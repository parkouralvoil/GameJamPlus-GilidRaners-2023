extends CanvasLayer
class_name WinScreen

signal menu_pressed

func _on_button_pressed() -> void:
	menu_pressed.emit()
