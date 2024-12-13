extends CanvasLayer
class_name SelectLevelMenu


signal selected_lvl_1
signal selected_lvl_2
signal selected_lvl_3
signal selected_lvl_4
signal selected_lvl_5


func _on_level_1_pressed() -> void:
	selected_lvl_1.emit()


func _on_level_2_pressed() -> void:
	selected_lvl_2.emit()


func _on_level_3_pressed() -> void:
	selected_lvl_3.emit()


func _on_level_4_pressed() -> void:
	selected_lvl_4.emit()


func _on_level_5_pressed() -> void:
	selected_lvl_5.emit()


func _on_back_button_pressed() -> void:
	hide()
