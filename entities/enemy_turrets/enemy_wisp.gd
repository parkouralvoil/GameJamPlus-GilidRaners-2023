extends Enemy
class_name EnemyWisp

var ready_to_fire: bool = true
var player_in_sight: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hitbox_playerNearby: Area2D = $Area2D_PlayerNearby
@onready var explosion: DelayedExplosion = $delayed_aoe
@onready var explosion_line: Line2D = $Line2D

@onready var reload_CD: Timer = $Timer_Reload
@onready var reload_wait_time: float = 3.0
@onready var explosion_line_lifetime: Timer = $Timer_Line
@onready var rotater: Node2D = $Rotator
@onready var sprite_body: AnimatedSprite2D = $AnimatedSprite2D ## should really just be a sprite2d

@onready var RC_player: RayCast2D = $RayCast2D_Player

func _ready() -> void:
	super()
	explosion_line.points[1] = Vector2.ZERO
	
	explosion.hide()


func _process(_delta: float) -> void:
	if hp <= 0:
		explosion.can_explode = false
		return

func _physics_process(_delta: float) -> void:
	if hp <= 0:
		return
		
	player_vision()
	
	if target != null and ready_to_fire and target.hp > 0 and player_in_sight:
		rotater.look_at(target.global_position)
		collision_shape.rotation = rotater.rotation
		
		show_line()
		fire_explosion()


func fire_explosion() -> void:
	explosion.global_position = target.global_position
	explosion.start_aoe = true
	explosion.show()
	if reload_CD.is_stopped():
		var rng := RandomNumberGenerator.new()
		reload_CD.start(rng.randf_range(reload_wait_time, reload_wait_time + 2))
	ready_to_fire = false


func show_line() -> void:
	explosion_line.points[1] = target.global_position - global_position
	if explosion_line_lifetime.is_stopped():
		explosion_line_lifetime.start()


func player_vision() -> void:
	if not target:
		player_in_sight = false
		return
	
	RC_player.target_position = target.global_position - global_position
	if RC_player.get_collider() == target:
		player_in_sight = true
	else:
		player_in_sight = false


func show_damage_visual() -> void:
	var t: Tween = create_tween()
	t.tween_property(sprite_body, "self_modulate", color_default, 0.2).from(color_red)

func _on_area_2d_player_nearby_body_entered(body: CharacterBody2D) -> void:
	if body is Player:
		target = body


func _on_area_2d_player_nearby_body_exited(body: CharacterBody2D) -> void:
	if body is Player:
		target = null


func _on_timer_reload_timeout() -> void:
	ready_to_fire = true


func _on_timer_line_timeout() -> void:
	explosion_line.points[1] = Vector2.ZERO
