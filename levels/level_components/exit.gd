extends Area2D
class_name LevelExit

var player_can_leave: bool = false

@onready var control_exit: Control = $Panel


func _ready() -> void:
	control_exit.hide()


func _on_body_entered(_body: Node2D) -> void:
	player_can_leave = true
	control_exit.show()


func _on_body_exited(_body: Node2D) -> void:
	player_can_leave = false
	control_exit.hide()
