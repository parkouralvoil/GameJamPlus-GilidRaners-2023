extends Node2D
class_name Level

signal level_exit_reached

@onready var p: Player = $Player ## for Main to access player
@onready var exit: LevelExit = $Exit

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if exit.player_can_leave:
			level_exit_reached.emit()
