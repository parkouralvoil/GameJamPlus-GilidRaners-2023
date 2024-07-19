extends CanvasLayer
class_name MainMenu

signal pressed_play
signal pressed_select_level
signal pressed_options

var red := Color(0.74, 0.38, 0.5)
var blue := Color(0.3, 0.55, 0.6)

@onready var bg: ColorRect = $ColorRect
@onready var menu_initial: VBoxContainer = $VBoxContainerInitial
@onready var menu_play: VBoxContainer = $VBoxContainerPlay
@onready var credits: Control = $Credits

func _ready() -> void:
	visibility_changed.connect(_return_menu_initial)
	bg.color = red


func _return_menu_initial() -> void:
	menu_initial.show()
	menu_play.hide()
	bg.color = red


#region menu initial
func _on_button_play_pressed() -> void:
	menu_initial.hide()
	menu_play.show()
	bg.color = blue


func _on_button_options_pressed() -> void:
	pressed_options.emit()


func _on_button_exit_pressed() -> void:
	get_tree().quit() # Replace with function body.
#endregion

#region menu play
func _on_button_new_game_pressed() -> void:
	pressed_play.emit()


func _on_button_level_select_pressed() -> void:
	pressed_select_level.emit()


func _on_button_back_pressed() -> void:
	_return_menu_initial()

#endregion


func _on_button_credits_pressed() -> void:
	credits.show()


func _on_button_credits_back_pressed() -> void:
	credits.hide()
