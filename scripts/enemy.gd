extends CharacterBody2D
class_name Enemy

var max_hp: float = 40.0
var hp: float = max_hp
var atk: float = 10.0

var target: Player = null

signal Died

@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

# healthbar:
@onready var display_hp = $Control/Label_HP:
	set(value):
		display_hp.text = "{0}/{1}".format([str(value), str(max_hp)])

func take_damage(damage):
	if hp - damage > 0:
		hp -= damage
		anim_sprite.self_modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.2).timeout
		anim_sprite.self_modulate = Color(1, 1, 1)
	else:
		hp = 0
		
func die():
	Died.emit()
	anim_sprite.visible = false
	display_hp.visible = false
	hitbox.set_deferred("disabled", true)
