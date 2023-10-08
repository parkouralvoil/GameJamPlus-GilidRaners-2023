extends StaticBody2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func open_door():
	if !anim_player.is_playing():
		anim_player.play("open")
