extends CharacterBody2D
class_name Enemy ## BaseEnemy class

signal Died

@export var max_hp: int = 3

var target: Player = null
var color_red := Color(1, 0.2, 0.2)
var color_default := Color(1, 1, 1)

var _initial_pos: Vector2

@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var hp_label: Label = $Label_HP
@onready var hp: int = max_hp:
	set(value):
		hp_label.text = "{0}/{1}".format([str(value), str(max_hp)])
		hp = value


func _ready() -> void:
	hp = max_hp
	_initial_pos = global_position


func take_damage(damage: int) -> void:
	SoundManager.play_enemy_ouch(_initial_pos)
	ParticleManager.hit_trigger(_initial_pos)
	if hp - damage > 0:
		hp -= damage
		show_damage_visual()
	else:
		hp = 0
		die()


func show_damage_visual() -> void:
	pass ## handled by enemies themselves


func die() -> void:
	Died.emit()
	visible = false
	hp_label.visible = false
	hitbox.set_deferred("disabled", true)

## respawn unnecessary, since level scene is just restarted
#func respawn() -> void: 
	#hp = max_hp
	#visible = true
	#hp_label.visible = true
	#hitbox.set_deferred("disabled", false)
