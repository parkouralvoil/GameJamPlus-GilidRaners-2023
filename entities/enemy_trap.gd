extends CharacterBody2D
class_name Enemy

var hp := 40.0

@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	pass
	

func _physics_process(delta):
	if hp == 0:
		sprite.visible = false
		hitbox.set_deferred("disabled", true)
		queue_free()
		return
	
	move_and_slide()
	

func take_damage(damage):
	if hp - damage > 0:
		hp -= damage
	else:
		hp = 0


