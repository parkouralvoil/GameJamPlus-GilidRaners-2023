extends CharacterBody2D
class_name Bullet

const RED_TEXTURE: Texture = preload("res://assets_sprites/Ballpen_Projectile/Red_Ballpen.png")

var projectile_speed: float = 400
var direction: Vector2 = Vector2(0, 1)

var damage: int = 1
var lifespan: float = 3.0 ## seconds

var active_hitbox: bool = true
var from_enemy: bool = false ## by default,it assumes its from player

@onready var timer_range_lifespan: Timer = $Timer_Range_Lifespan


@onready var damage_hitbox: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D ## so other codes can reference it

func _ready() -> void:
	timer_range_lifespan.start(lifespan)
	if from_enemy:
		sprite.texture = RED_TEXTURE


func _physics_process(delta: float) -> void:
	velocity = direction.normalized() * projectile_speed * delta
	
	var collision_info: KinematicCollision2D = move_and_collide(velocity)
	if collision_info:
		queue_free()


func _on_timer_lifespan_timeout() -> void:
	queue_free()


func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if not from_enemy:
		if body is Enemy and active_hitbox:
			var enemy: Enemy = body
			enemy.take_damage(damage)
			queue_free()
	else:
		if body is Player and active_hitbox:
			var player: Player = body
			player.take_damage(damage)
			queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void: ## only affects player projectiles
	if !from_enemy and direction != Vector2.ZERO:
		queue_free()
