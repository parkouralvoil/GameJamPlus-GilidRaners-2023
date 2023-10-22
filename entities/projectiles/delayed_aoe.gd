extends Area2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var explosion_anim_sprite: AnimatedSprite2D = $AnimatedSprite2D_Explosion
@onready var sprite_bluecircle: Sprite2D = $Sprite2D_BlueCircle
@onready var sprite_redcircle: Sprite2D = $Sprite2D_RedCircle

var start_aoe: bool = false
var target: Player = null

var damage: float = 10.0

func _ready():
	pass

func _process(delta):
	if start_aoe and !anim_player.is_playing():
		sprite_bluecircle.visible = true
		sprite_redcircle.visible = true
		anim_player.play("explode")

func explode():
	if target != null:
		target.take_damage(damage)
	start_aoe = false
	explosion_anim_sprite.play("explosion")
	sprite_bluecircle.visible = false
	sprite_redcircle.visible = false

func _on_body_entered(body):
	if body is Player:
		target = body

func _on_body_exited(body):
	if body is Player:
		target = null
