extends Node2D

@export var player: Player
@export var camera: Camera2D
@export var hud: PlayerHud


func _process(_delta: float) -> void:
	if player:
		camera.global_position = player.global_position
