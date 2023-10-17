extends CharacterBody2D

var projectile_speed: float = 600
var direction: Vector2 = Vector2(0, 1)

var damage: float = 10.0

@onready var timer_range_lifespan: Timer = $Timer_Range_Lifespan
@onready var timer_collision_lifespan: Timer = $Timer_Collision_Lifespan
@onready var timer_deactive_hitbox: Timer = $Timer_DeactivateHitbox

var lifespan: float = 3.0

@onready var damage_hitbox = $Area2D
@onready var sprite = $Sprite2D # so other codes can reference it

var active_hitbox: bool = true
var from_enemy: bool = false # by default,it assumes its from player

func _ready():
	timer_range_lifespan.start(lifespan)

func _physics_process(delta):
	velocity = direction.normalized() * projectile_speed * delta
	
	var collision_info: KinematicCollision2D = move_and_collide(velocity)
	if collision_info:
		direction = Vector2.ZERO
		timer_range_lifespan.paused = true
		
		if timer_range_lifespan.paused and timer_collision_lifespan.is_stopped():
			timer_collision_lifespan.start()
		
		if timer_deactive_hitbox.is_stopped():
			timer_deactive_hitbox.start()
		return


func _on_timer_lifespan_timeout():
	queue_free()

func _on_area_2d_body_entered(body):
	if !from_enemy:
		if body is Enemy and active_hitbox:
			var enemy = body
			enemy.take_damage(damage)
			queue_free()
	else:
		if body is Player and active_hitbox:
			var player = body
			player.take_damage(damage)
			queue_free()

func _on_timer_deactivate_hitbox_timeout():
	active_hitbox = false

func _on_timer_collision_lifespan_timeout():
	timer_range_lifespan.paused = false


func _on_visible_on_screen_notifier_2d_screen_exited():
	if !from_enemy and direction != Vector2.ZERO:
		queue_free()
