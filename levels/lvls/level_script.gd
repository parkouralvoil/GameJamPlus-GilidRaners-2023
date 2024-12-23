extends Node2D
class_name Level

signal level_exit_reached

var exit_pressed: bool = false

@onready var p: Player = $Player ## for Main to access player
@onready var exit: LevelExit = $Exit

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not exit_pressed:
		if exit.player_can_leave:
			level_exit_reached.emit()
			exit_pressed = true
