extends Area2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: Player = null
var activated: bool = false

func _process(delta):
	if player != null:
		if !activated:
			if Input.is_action_just_pressed("shoot"):
				pass
			pass
			# show text
	
	if activated and anim_sprite.animation != "activated":
		anim_sprite.play("activated")

func _on_body_entered(body):
	if body is Player:
		player = body

func _on_body_exited(body):
	if body is Player:
		player = null
