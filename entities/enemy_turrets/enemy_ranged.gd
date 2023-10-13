extends Enemy

var bullet_path = load("res://entities/projectiles/projectile_arrow.tscn")

@onready var turret_aim = $Node2D_Aim
@onready var marker = $Node2D_Aim/Marker2D

@onready var fire_rate_CD: Timer = $Timer_FireRateCD
@onready var reload_CD: Timer = $Timer_Reload

@onready var RC_player: RayCast2D = $RayCast2D_Player
@onready var hitbox_playerNearby: Area2D = $Area2D_PlayerNearby

var player_in_sight: bool = false
var burst_started: bool = false

# vision stuff:
var angle_to: float = 100
@export var initial_rotation: float = 0

# projectile info:
var max_ammo: int = 2
var ammo: int = max_ammo
var projectile_speed: float = 300.0
var rotation_speed: float = 3.4

func _ready():
	max_hp = 30.0
	hp = max_hp
	atk = 5.0
	anim_sprite.rotation_degrees = initial_rotation

func _process(delta):
	if hp <= 0:
		die()
		fire_rate_CD.stop()
		reload_CD.stop()
		ammo = max_ammo
		return
	display_hp = hp
	
	player_vision()
	turret_aim.rotation = anim_sprite.rotation
	
	if target != null and player_in_sight:
		#turret_aim.look_at(target.global_position)
		rotate_char(delta)

		if fire_rate_CD.is_stopped() and ammo > 0 and abs(angle_to) < 0.3: 
			if target.hp > 0:
				fire_rate_CD.start() # shoot bullet is located here
		elif ammo <= 0 and reload_CD.is_stopped():
			if !fire_rate_CD.is_stopped(): 
				fire_rate_CD.stop()
			reload_CD.start()

	else:
		anim_sprite.play("idle")
		if !fire_rate_CD.is_stopped(): 
			fire_rate_CD.stop()
	

func _physics_process(delta):
	pass
	

func rotate_char(input_delta):
	var direction := target.global_position - global_position
	angle_to = anim_sprite.transform.x.angle_to(direction)
	anim_sprite.rotate(sign(angle_to) * min(input_delta * rotation_speed, abs(angle_to)))

func shoot_bullet():
	var bullet = bullet_path.instantiate()
	
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = marker.global_position - bullet.global_position
	bullet.rotation = turret_aim.rotation
	bullet.projectile_speed = projectile_speed
	
	bullet.damage = atk
	bullet.from_enemy = true

func player_vision():
	if get_node("/root/test_level/player") in hitbox_playerNearby.get_overlapping_bodies():
		target = get_node("/root/test_level/player")
		RC_player.target_position = target.global_position - global_position
		if RC_player.get_collider() == target:
			player_in_sight = true
		else:
			player_in_sight = false
	else:
		target = null
		player_in_sight = false

func _on_timer_fire_rate_cd_timeout():
	ammo -= 1
	shoot_bullet()
	#print((angle_to), anim_sprite.rotation_degrees)
	if !anim_sprite.is_playing():
		anim_sprite.play("fire")


func _on_timer_reload_timeout():
	ammo = max_ammo
	
func respawn():
	hp = max_hp
	anim_sprite.visible = true
	display_hp.visible = true
	hitbox.set_deferred("disabled", false)
