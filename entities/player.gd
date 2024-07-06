extends CharacterBody2D
class_name Player

signal PlayerRespawned

const BulletPath: PackedScene = preload("res://entities/projectiles/projectile_arrow.tscn")

enum Powerup {none = 0, ballpenBundle = 1, coffee = 2, kwekkwek = 3, kodigo = 4}
## 0, 1, 2, 3, 4

@export var respawn_point: Vector2 = Vector2.ZERO

## g for ground variables
var g_speed: float = 200
var g_accel: float = 5000
var g_jump_speed: float = -350
var g_friction: float = 4000


## a for air variables
var a_speed: float = 250
var a_accel: float = 500
var a_jump_speed: float = -470
var a_friction: float = 500
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


## d for dash variables
var d_speed: float = 800
var d_accel: float = 10000
var speedModifier = 0


## stats
var max_hp: int = 5
var hp: int = max_hp
var atk: int = 1
var invul: bool = false

## controller stuff
var sensitivity: float = 8.5
var debounce_time := 0.5 # seconds
var debounce_timer := 0.0

## projectile info
var projectile_speed: float = 750
var projectile_lifespan: float = 0.55
var mouse_position: Vector2

var controller_input: bool = false

## input logic
var x_movement: float = 0
var y_movement: float = 0
var dash_dir: int = 0 ## input is "Input.is_action_just_pressed("shift_button")"
var fire_input: bool = false
var can_double_jump: bool = false ## resets when u step on the ground
var can_dash: bool = true ## resets after dashCD timeout

var is_firing := false
## for PlayerDead.gd
var just_respawned: bool = false

@onready var jump_CD: Timer = $Timers/JumpCD
@onready var timer_is_firing: Timer = $Timers/IsFiring
@onready var fire_rate_CD: Timer = $Timers/FireRateCD
@onready var respawn_CD: Timer = $Timers/Respawn

@onready var dash_duration: Timer = $Timers/DashDuration
@onready var dash_CD: Timer = $Timers/DashCD

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_particles: GPUParticles2D = $GPUParticles2D_Jump

@onready var state_machine: Node = $"State Machine"

var bullet_aim: Vector2

func _ready() -> void:
	respawn_point = global_position
	mouse_position = get_viewport().size / 2


func _process(_delta: float) -> void:
	if controller_input:
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
	
	bullet_aim = global_position.direction_to(get_global_mouse_position()).normalized()
	if hp <= 0:
		fire_input = false
		anim_sprite.self_modulate = Color(1, 0 ,0)
		return
		
	x_movement = Input.get_axis("move_left", "move_right")
	if Input.is_action_just_pressed("move_up"):
		y_movement = 1
	else:
		y_movement = 0
	
	#if Input.is_action_just_pressed("interact"):
		#useItem()
	fire_input = Input.is_action_pressed("shoot")


func _physics_process(_delta: float) -> void:
	move_and_slide()


func _on_timer_is_firing_timeout() -> void:
	is_firing = false


func shoot_bullet() -> void:
	var bullet: Bullet = BulletPath.instantiate()
	
	bullet.lifespan = projectile_lifespan
	get_tree().root.add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = get_global_mouse_position() - bullet.global_position
	bullet.rotation = bullet_aim.angle()
	bullet.projectile_speed = projectile_speed
	bullet.damage = atk


func take_damage(damage: int) -> void:
	if invul:
		pass
	elif hp - 1 > 0:
		anim_sprite.self_modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.2).timeout
		anim_sprite.self_modulate = Color(1, 1, 1)
		hp -= 1
	else:
		hp = 0


func flip_player() -> void:
	if get_global_mouse_position().x < global_position.x:
		anim_sprite.scale.x = -1
	else:
		anim_sprite.scale.x = 1


func fire() -> void: ## called by PlayerFire state
	is_firing = true
	fire_rate_CD.start()
	timer_is_firing.start()
	
	shoot_bullet()
	flip_player()


func respawn_player() -> void:
	just_respawned = true
	emit_signal("PlayerRespawned")
	anim_sprite.self_modulate = Color(1, 1, 1)


#func useItem():
	#if inventory == Powerup.ballpenBundle:
		#UnliAmmo()
	#elif inventory == Powerup.kwekkwek:
		#healConsummable()
	#elif inventory == Powerup.kodigo:
		#useInvul()
	#elif inventory == Powerup.coffee:
		#drinkCoffee()
	#inventory = Powerup.none

func healConsummable() -> void:
	var healed_amt: int = 1
	if hp + healed_amt > max_hp:
		hp = max_hp
	else:
		hp = hp + healed_amt

#func UnliAmmo():
	#unliAmmo = true
	#ammo = max_ammo
	#ammoTime.start()
	
#func drinkCoffee() -> void:
	#speedModifier += 200
	#coffeeTime.start()

#func useInvul() -> void:
	#invul = true
	#invulTime.start()

#func getKodigo():
	#inventory = Powerup.kodigo

#func getHealth():
	#inventory = Powerup.kwekkwek

#func getCoffee():
	#inventory = Powerup.coffee

#func getMinigun():
	#inventory = Powerup.ballpenBundle


func disable_controls() -> void:
	x_movement = 0
	y_movement = 0
	fire_input = false


func _on_timer_dash_cd_timeout() -> void:
	can_dash = true


#func _on_timer_invul_timeout() -> void:
	#invul = false
	#invulTime.stop()
#
#
#func _on_timer_coffee_timeout() -> void:
	#speedModifier -= 200
	#coffeeTime.stop()


func _on_timer_dash_duration_timeout() -> void:
	pass #dash_dir = 0
