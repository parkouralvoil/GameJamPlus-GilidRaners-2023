extends Enemy
class_name EnemyRanged

const BulletPath: PackedScene = preload("res://entities/projectiles/projectile_arrow.tscn")

var player_in_sight: bool = false
var burst_started: bool = false

## vision stuff:
var angle_to: float = 100

## projectile info:
var projectile_speed: float = 350.0


@onready var turret_aim: Node2D = $TurretAim
@onready var marker: Marker2D = $TurretAim/Marker2D

@onready var fire_rate_CD: Timer = $Timer_FireRateCD
@onready var anim_player: AnimationPlayer = $AnimationPlayer

@onready var RC_player: RayCast2D = $RayCast2D_Player
@onready var hitbox_playerNearby: Area2D = $Area2D_PlayerNearby

@onready var sprite_body: Sprite2D = $sprite_body
@onready var neutral_eye: Sprite2D = $sprite_body/eye
@onready var neutral_mouth: Sprite2D = $sprite_body/mouth
@onready var hostile_mouth: Sprite2D = $sprite_body/fire

@onready var iris: Marker2D = $sprite_body/eye/Marker2D

func _ready() -> void:
	super()
	hostile_mouth.hide()


func _process(_delta: float) -> void:
	if hp <= 0:
		fire_rate_CD.stop()
		sprite_body.hide()
		return
	
	player_vision()
	
	var can_shoot: bool = (target != null and player_in_sight)
	if can_shoot:
		turret_aim.look_at(target.global_position)
	
	if can_shoot and fire_rate_CD.is_stopped(): 
		fire_rate_CD.start() ## shoots bullet at fire_rate timeout
	
	iris_movement()


func iris_movement() -> void:
	if target != null and player_in_sight:
		var direction := Vector2.ZERO.direction_to(target.global_position - global_position)
		var distance: float = (target.global_position - global_position).length()
		iris.position = Vector2(-5.5, -10) + direction * min(distance, 2)
	else:
		iris.position = Vector2(-5.5, -10)


func shoot_bullet() -> void:
	var bullet: Bullet = BulletPath.instantiate()
	
	get_tree().root.add_child(bullet)
	bullet.global_position = global_position
	bullet.sprite.self_modulate = Color(1, 0, 0, 1)
	bullet.direction = marker.global_position - bullet.global_position
	bullet.rotation = turret_aim.rotation
	bullet.projectile_speed = projectile_speed
	
	bullet.damage = 1
	bullet.from_enemy = true


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
	t.tween_property(sprite_body, "self_modulate", color_default, 0.1).from(color_red)


func _on_area_2d_player_nearby_body_entered(body: CharacterBody2D) -> void:
	if body is Player:
		target = body


func _on_area_2d_player_nearby_body_exited(body: CharacterBody2D) -> void:
	if body is Player:
		target = null


func _on_timer_fire_rate_cd_timeout() -> void:
	shoot_bullet()
	if !anim_player.is_playing():
		anim_player.play("fire")
