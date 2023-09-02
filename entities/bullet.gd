extends CharacterBody2D

var projectile_speed := 600
var direction := Vector2(0, 1)

@onready var timer_lifespan = $Timer_Lifespan

func _physics_process(delta):
	velocity = direction.normalized() * projectile_speed * delta
	
	var collision_info = move_and_collide(velocity)
	if collision_info:
		direction = Vector2.ZERO

func _on_timer_lifespan_timeout():
	queue_free()
