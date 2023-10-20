class_name Player
extends CharacterBody2D

var bullet_path = load("res://entities/projectiles/projectile_arrow.tscn")

# g for ground variables
var g_speed: float = 200
var g_accel: float = 5000
var g_jump_speed: float = -350
var g_friction: float = 4000

# a for air variables
var a_speed: float = 250
var a_accel: float = 500
var a_jump_speed: float = -470
var a_friction: float = 500
var recoil_direction: Vector2 = Vector2.ZERO
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var max_hp: float = 80.0
var respawn_hp: float = 60.0
var hp: float = max_hp
var atk: float = 10.0
var max_energy: float = 20
var energy: float = max_energy
var max_ammo: int = 8
var ammo: int = max_ammo

@export var respawn_point: Vector2 = Vector2.ZERO

# projectile info
var projectile_speed: float = 750
var projectile_lifespan: float = 0.55

var stop_energy_regen: bool = false

@onready var jump_CD = $Timer_JumpCD
@onready var energy_start_CD = $Timer_EnergyStartCD
@onready var energy_regen_CD = $Timer_EnergyRegenCD
@onready var timer_is_firing = $Timer_IsFiring
var is_firing := false
@onready var fire_rate_CD = $Timer_FireRateCD
@onready var reload_timer = $Timer_Reload
@onready var respawn_CD = $Timer_Respawn
# for PlayerDead.gd
var just_respawned: bool = false

@onready var anim_sprite = $AnimatedSprite2D
@onready var jump_particles = $GPUParticles2D_Jump

@onready var bullet_aim = $Node2D_Aim
@onready var bullet_position = $Node2D_Aim/Marker2D

@onready var state_machine = $"State Machine"

signal PlayerRespawned

# input logic (when i add input buffers for jumping or cooldowns)
var x_movement: float
var y_movement: float

var fire_input: bool = false

func _ready():
	#print(state_machine.states)
	respawn_point = global_position
	pass
	
func _process(delta):
	if SceneManager.menu_open: 
		disable_controls()
		return
	
	bullet_aim.look_at(get_global_mouse_position())
	if hp <= 0:
		fire_input = false
		anim_sprite.self_modulate = Color(1, 0 ,0)
		return
		
	x_movement = Input.get_axis("move_left", "move_right")
	if Input.is_action_just_pressed("move_up"):
		y_movement = 1
	else:
		y_movement = 0
	
	fire_input = Input.is_action_pressed("shoot")
	
	if !is_firing and reload_timer.is_stopped() and ammo < max_ammo:
		reload_timer.start()

func _physics_process(delta):
	# energy regen
	if energy < max_energy and stop_energy_regen == false and energy_regen_CD.is_stopped():
		energy_regen_CD.start()
	elif energy >= max_energy:
		energy_regen_CD.stop()
		energy == max_energy
	
	move_and_slide()


func _on_timer_energy_start_cd_timeout():
	stop_energy_regen = false

func _on_timer_energy_regen_cd_timeout():
	pass
	#energy += 5

func _on_timer_is_firing_timeout():
	is_firing = false

func shoot_bullet():
	var bullet = bullet_path.instantiate()
	
	bullet.lifespan = projectile_lifespan
	get_parent().add_child(bullet)
	bullet.global_position = bullet_position.global_position
	bullet.direction = get_global_mouse_position() - bullet.global_position
	bullet.rotation = bullet_aim.rotation
	bullet.projectile_speed = projectile_speed
	
	bullet.damage = atk
	recoil_direction = -bullet.direction.normalized()
	
	ammo -= 1
	if !reload_timer.is_stopped():
		reload_timer.stop()

func take_damage(damage):
	if hp - damage > 0:
		anim_sprite.self_modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.2).timeout
		anim_sprite.self_modulate = Color(1, 1, 1)
		hp -= damage
	else:
		hp = 0


func flip_player():
	if get_global_mouse_position().x < global_position.x:
		anim_sprite.scale.x = 1
	else:
		anim_sprite.scale.x = -1
		
func fire():
	is_firing = true
	fire_rate_CD.start()
	timer_is_firing.start()
	
	shoot_bullet()
	flip_player()

func _on_timer_reload_timeout():
	ammo = max_ammo

#func _on_timer_respawn_timeout():
#	just_respawned = true
#	emit_signal("PlayerRespawned")
#	anim_sprite.self_modulate = Color(1, 1, 1)

func respawn_player():
	just_respawned = true
	emit_signal("PlayerRespawned")
	anim_sprite.self_modulate = Color(1, 1, 1)
	
func disable_controls():
	x_movement = 0
	y_movement = 0
	fire_input = false
