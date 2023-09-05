extends CharacterBody2D

var projectile_speed: float = 600
var direction: Vector2 = Vector2(0, 1)

var damage: float = 10.0

@onready var timer_lifespan = $Timer_Lifespan
@onready var timer_deactive_hitbox = $Timer_DeactivateHitbox

var active_hitbox: bool = true

const bullet_path = preload("res://entities/bullet.tscn")

func _physics_process(delta):
	velocity = direction.normalized() * projectile_speed * delta
	
	var collision_info: KinematicCollision2D = move_and_collide(velocity)
	if collision_info:
		direction = Vector2.ZERO
		
		if timer_deactive_hitbox.is_stopped():
			timer_deactive_hitbox.start()

func _on_timer_lifespan_timeout():
	queue_free()

func _on_area_2d_body_entered(body):
	if body is Enemy and active_hitbox:
		var enemy = body
		enemy.take_damage(damage)
		queue_free()

func _on_timer_deactivate_hitbox_timeout():
	active_hitbox = false
