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

# d for dash variables
var d_speed: float = 800
var d_accel: float = 10000
var speedModifier = 0

var max_hp: float = 100.0
var respawn_hp: float = max_hp
var hp: float = max_hp
var atk: float = 10.0
var max_energy: float = 20
var energy: float = max_energy
var max_ammo: int = 8
var ammo: int = max_ammo
var inventory: int = Powerup.none
var invul: bool = false
var unliAmmo: bool = false
var sensitivity: float = 8.5
var debounce_time := 0.5 # seconds
var debounce_timer := 0.0
@export var respawn_point: Vector2 = Vector2.ZERO

# projectile info
var projectile_speed: float = 750
var projectile_lifespan: float = 0.55
var mouse_position := Vector2()

var stop_energy_regen: bool = false
var input_source: int = 1 # binary value that is either 0 (controller) or 1 (mouse)

@onready var jump_CD = $Timer_JumpCD

@onready var energy_start_CD = $Timer_EnergyStartCD
@onready var energy_regen_CD = $Timer_EnergyRegenCD
@onready var invulTime = $Timer_Invul
@onready var ammoTime = $Timer_UnliAmmo
@onready var coffeeTime = $Timer_Coffee
@onready var dashLeft = $Left_DoubleTap
@onready var dashRight = $Right_DoubleTap
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

enum Powerup {none = 0, ballpenBundle = 1, coffee = 2, kwekkwek = 3, kodigo = 4}
# 0, 1, 2, 3, 4

signal PlayerRespawned

# input logic (when i add input buffers for jumping or cooldowns)
var x_movement: float
var y_movement: float
var dash: float

var fire_input: bool = false

func _ready():
	respawn_point = global_position
	mouse_position = get_viewport().size / 2
	pass
	
# func _input(event):
# 	if event is InputEventJoypadMotion and abs(event.axis_value) < 0.1 and input_source:
# 		input_source = 0
	# 	
	# if event is InputEventMouseMotion and not input_source:
	# 	input_source = 1

func _process(delta):
	if not input_source:
		var move_y := Input.get_action_strength("cursor_down") - Input.get_action_strength("cursor_up")
		var move_x := Input.get_action_strength("cursor_right") - Input.get_action_strength("cursor_left")
		mouse_position.x += move_x * sensitivity
		mouse_position.y += move_y * sensitivity
		
		mouse_position.x = clamp(mouse_position.x, 0, get_viewport().size.x - 1)
		mouse_position.y = clamp(mouse_position.y, 0, get_viewport().size.y - 1)
		get_viewport().warp_mouse(mouse_position)
	
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
	
	if Input.is_action_just_pressed("interact"):
		useItem()
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
	
	if unliAmmo == false:
		ammo -= 1
	if !reload_timer.is_stopped():
		reload_timer.stop()

func take_damage(damage):
	if invul:
		pass
	elif hp - damage > 0:
		anim_sprite.self_modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.2).timeout
		anim_sprite.self_modulate = Color(1, 1, 1)
		hp -= damage
	else:
		hp = 0


func flip_player():
	if get_global_mouse_position().x < global_position.x:
		anim_sprite.scale.x = -1
	else:
		anim_sprite.scale.x = 1
		
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
	
	
func useItem():
	if inventory == Powerup.ballpenBundle:
		UnliAmmo()
	elif inventory == Powerup.kwekkwek:
		healConsummable()
	elif inventory == Powerup.kodigo:
		useInvul()
	elif inventory == Powerup.coffee:
		drinkCoffee()
	inventory = Powerup.none
	
	
func healConsummable():
	if hp + 20 > max_hp:
		hp = max_hp
	else:
		hp = hp + 20

func UnliAmmo():
	unliAmmo = true
	ammo = max_ammo
	ammoTime.start()
	
func drinkCoffee():
	speedModifier += 200
	coffeeTime.start()
	
func useInvul():
	invul = true
	invulTime.start()
	
func getKodigo():
	inventory = Powerup.kodigo
	
func getHealth():
	inventory = Powerup.kwekkwek
	
func getCoffee():
	inventory = Powerup.coffee
	
func getMinigun():
	inventory = Powerup.ballpenBundle
	
	
func disable_controls():
	x_movement = 0
	y_movement = 0
	fire_input = false


	
func _on_timer_dash_cd_timeout():
	dash = 0


func _on_left_double_tap_timeout():
	dashLeft.stop()


func _on_right_double_tap_timeout():
	dashRight.stop()


func _on_timer_unli_ammo_timeout():
	unliAmmo = false
	ammoTime.stop()


func _on_timer_invul_timeout():
	invul = false
	invulTime.stop()


func _on_timer_coffee_timeout():
	speedModifier -= 200
	coffeeTime.stop()
