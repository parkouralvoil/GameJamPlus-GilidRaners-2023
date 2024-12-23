extends Area2D
class_name DelayedExplosion

var start_aoe: bool = false
var target: Player = null

var _initial_pos: Vector2
var can_explode: bool = true ## HACK
var damage: int = 1

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var explosion_anim_sprite: AnimatedSprite2D = $AnimatedSprite2D_Explosion
@onready var sprite_bluecircle: Sprite2D = $Sprite2D_BlueCircle
@onready var sprite_redcircle: Sprite2D = $Sprite2D_RedCircle


func _process(_delta: float) -> void:
	if start_aoe and !anim_player.is_playing():
		_initial_pos = global_position
		sprite_bluecircle.visible = true
		sprite_redcircle.visible = true
		anim_player.play("explode")


func explode() -> void:
	if not can_explode:
		return ## dont explode when enemy alrdy dead
	
	if target != null:
		target.take_damage(damage)
	start_aoe = false
	SoundManager.play_hand_explosion(_initial_pos)
	explosion_anim_sprite.play("explosion")
	sprite_bluecircle.visible = false
	sprite_redcircle.visible = false


func _on_body_entered(body: CharacterBody2D) -> void:
	if body is Player:
		target = body


func _on_body_exited(body: CharacterBody2D) -> void:
	if body is Player:
		target = null
