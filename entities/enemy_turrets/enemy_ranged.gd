extends Enemy

var bullet_path = load("res://entities/projectiles/projectile_arrow.tscn")

@onready var turret_aim = $Node2D_Aim
@onready var marker = $Node2D_Aim/Marker2D

@onready var fire_rate_CD: Timer = $Timer_FireRateCD
@onready var reload_CD: Timer = $Timer_Reload
@onready var anim_player: AnimationPlayer = $AnimationPlayer

@onready var RC_player: RayCast2D = $RayCast2D_Player
@onready var hitbox_playerNearby: Area2D = $Area2D_PlayerNearby

@onready var body: Sprite2D = $body
@onready var neutral_eye: Sprite2D = $body/eye
@onready var neutral_mouth: Sprite2D = $body/mouth
@onready var hostile_mouth: Sprite2D = $body/fire

@onready var iris: Marker2D = $body/eye/Marker2D

var player_in_sight: bool = false
var burst_started: bool = false

# vision stuff:
var angle_to: float = 100
@export var initial_rotation: float = 0

# projectile info:
var max_ammo: int = 1
var ammo: int = max_ammo
var projectile_speed: float = 350.0
var rotation_speed: float = 3.4

func _ready():
	hostile_mouth.hide()
	max_hp = 30.0
	hp = max_hp
	atk = 10.0

func _process(delta):
	if hp <= 0:
		die()
		fire_rate_CD.stop()
		reload_CD.stop()
		ammo = max_ammo
		body.hide()
		return
	display_hp = hp
	
	player_vision()

	if target != null and player_in_sight:
		#turret_aim.look_at(target.global_position)
		rotate_char(delta)

		if fire_rate_CD.is_stopped() and ammo > 0 and abs(angle_to) < 0.3: 
			if target.hp > 0:
				fire_rate_CD.start() # shoot bullet is located here
				if !anim_player.is_playing():
					anim_player.play("fire")
		elif ammo <= 0 and reload_CD.is_stopped():
			if !fire_rate_CD.is_stopped(): 
				fire_rate_CD.stop()
			reload_CD.start()
	else:
		if !fire_rate_CD.is_stopped(): 
			fire_rate_CD.stop()
		
	iris_movement()
	
func iris_movement():
	if target != null and player_in_sight:
		var direction = Vector2.ZERO.direction_to(target.global_position - global_position)
		var distance = (target.global_position - global_position).length()
		iris.position = Vector2(-5.5, -10) + direction * min(distance, 2)
	else:
		iris.position = Vector2(-5.5, -10)

func _physics_process(delta):
	pass
	

func rotate_char(input_delta):
	var direction := target.global_position - global_position
	angle_to = turret_aim.transform.x.angle_to(direction)
	turret_aim.rotate(sign(angle_to) * min(input_delta * rotation_speed, abs(angle_to)))

func shoot_bullet():
	var bullet = bullet_path.instantiate()
	
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.sprite.self_modulate = Color(1, 0, 0, 1)
	bullet.direction = marker.global_position - bullet.global_position
	bullet.rotation = turret_aim.rotation
	bullet.projectile_speed = projectile_speed
	
	bullet.damage = atk
	bullet.from_enemy = true

func player_vision():
	if target != null:
		RC_player.target_position = target.global_position - global_position
		if RC_player.get_collider() == target:
			player_in_sight = true
		else:
			player_in_sight = false
	else:
		player_in_sight = false
	
func take_damage(damage):
	if hp - damage > 0:
		hp -= damage
		anim_sprite.modulate = Color(1, 0, 0)
		body.modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.2).timeout
		anim_sprite.modulate = Color(1, 1, 1)
		body.modulate = Color(1, 1, 1)
	else:
		hp = 0

func _on_timer_fire_rate_cd_timeout():
	ammo -= 1
	#print((angle_to), anim_sprite.rotation_degrees)


func _on_timer_reload_timeout():
	ammo = max_ammo
	
func respawn():
	hp = max_hp
	anim_sprite.visible = true
	display_hp.visible = true
	hitbox.set_deferred("disabled", false)


func _on_area_2d_player_nearby_body_entered(body):
	if body is Player:
		target = body


func _on_area_2d_player_nearby_body_exited(body):
	if body is Player:
		target = null
