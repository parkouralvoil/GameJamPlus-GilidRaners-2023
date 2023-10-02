extends Area2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var press_e_label: Label = $Label

var player: Player = null
var activated: bool = false

signal Campfire_Activated

func _process(delta):
	if player != null:
		if !activated:
			press_e_label.visible = true
			if Input.is_action_just_pressed("interact"):
				player.respawn_point = global_position
				activated = true
				Campfire_Activated.emit(self)
	
	if activated and anim_sprite.animation != "activated":
		anim_sprite.play("activated")
		press_e_label.visible = false
	elif !activated and anim_sprite.animation != "off":
		anim_sprite.play("off")

func _on_body_entered(body):
	if body is Player:
		player = body

func _on_body_exited(body):
	if body is Player:
		press_e_label.visible = false
		player = null

func deactivate_campfire():
	activated = false
