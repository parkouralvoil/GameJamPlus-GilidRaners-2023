class_name Player
extends CharacterBody2D

enum States {
	ON_GROUND, 
	IN_AIR, 
	FIRE,
	}

const bullet_path = preload("res://entities/bullet.tscn")

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

var health: int = 100
var atk: int = 5
var energy: int = 80
var max_energy: int = 80

var has_air_jumped: bool = false

var current_state := States.IN_AIR
@onready var jump_CD = $Timer_JumpCD
@onready var energy_start_CD = $Timer_EnergyStartCD
@onready var energy_regen_CD = $Timer_EnergyRegenCD
@onready var timer_is_firing = $Timer_IsFiring
var is_firing := false

@onready var anim_sprite = $AnimatedSprite2D
@onready var jump_particles = $GPUParticles2D_Jump

@onready var bullet_aim = $Node2D_Aim
@onready var bullet_position = $Node2D_Aim/Marker2D

# input logic (when i add input buffers for jumping or cooldowns)
var x_movement
var y_movement

func _ready():
	if velocity.y <= 0 and anim_sprite.animation != "falling":
		anim_sprite.play("falling")
	
func _process(delta):
	bullet_aim.look_at(get_global_mouse_position())
	
	
func _physics_process(delta):
	x_movement = Input.get_axis("move_left", "move_right")
	y_movement = Input.get_axis("move_up", "move_down")
	
	#gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		change_state(null, States.IN_AIR)
	else:
		has_air_jumped = false
		change_state(null, States.ON_GROUND)
		
	# energy regen
	if energy < max_energy and has_air_jumped == false and energy_regen_CD.is_stopped():
		energy_regen_CD.start()
	elif energy >= max_energy:
		energy_regen_CD.stop()
		energy == max_energy
		
	match current_state:
		States.ON_GROUND:
			if is_firing:
				anim_sprite.play("shoot")
				velocity = Vector2.ZERO
			else:
				energy_start_CD.stop()
				has_air_jumped = false
				ground_movement(delta)
				
				if Input.is_action_just_pressed("move_up") and jump_CD.is_stopped():
					velocity.y = g_jump_speed
					jump_CD.start()
					
				#animation:
				if abs(velocity.x) <= 0.1 and anim_sprite.animation != "idle":
					anim_sprite.play("idle")
				elif abs(velocity.x) > 0.1 and anim_sprite.animation != "walk":
					anim_sprite.play("walk")
				
			#flip char
			if x_movement == -1:
				anim_sprite.scale.x = -1
			elif x_movement == 1:
				anim_sprite.scale.x = 1
			
		States.IN_AIR:
			if is_firing:
				anim_sprite.play("shoot")
				velocity = recoil_direction * 10 # TODO: needs to go to 0
				
			else:
				air_movement(delta)
				
				#animation:
				if velocity.y > 0.1 and anim_sprite.animation != "falling":
					anim_sprite.play("falling")
				elif velocity.y <= -300 and anim_sprite.animation != "jump_high":
					anim_sprite.play("jump_high")
				elif -300 < velocity.y and velocity.y <= -0.1 and anim_sprite.animation != "jump_med":
					anim_sprite.play("jump_med")
				
				if Input.is_action_just_pressed("move_up") and jump_CD.is_stopped() and energy >= 15:
					velocity.y = a_jump_speed
					if x_movement == 0:
						velocity = Vector2(velocity.x * 0.2, a_jump_speed)
					else:
						velocity = Vector2(x_movement * a_speed, a_jump_speed * 0.8)
						
					jump_particles.emitting = true
					jump_CD.start()
					energy_start_CD.start()
					energy_regen_CD.stop()
					has_air_jumped = true
					energy -= 20
	
	if Input.is_action_just_pressed("shoot"): #TODO: need to add CD here lol
		is_firing = true
		# direction of player
		if get_global_mouse_position() < global_position:
			anim_sprite.scale.x = 1
		else:
			anim_sprite.scale.x = -1
		timer_is_firing.start()
		shoot_bullet()
	
	move_and_slide()
	#print(anim_sprite.animation)

func change_state(prev_state, new_state):
	if current_state != new_state:
		enter_state(new_state)
	
func enter_state(new_state):
	current_state = new_state
	
func exit_state(prev_state):
	pass

# the price to pay for not using rigidbody2d (aka my own physics code)
func ground_movement(input_delta):
	if x_movement == 1:
		velocity.x = min(velocity.x + g_accel * input_delta, g_speed)
	elif x_movement == -1:
		velocity.x = max(velocity.x - g_accel * input_delta, -g_speed)
	else: # no input
		if velocity.x > 0.1:
			velocity.x = max(velocity.x - g_friction * input_delta, 0)
		elif velocity.x < -0.1:
			velocity.x = min(velocity.x + g_friction * input_delta, 0)
		else:
			velocity.x = 0
			
func air_movement(input_delta):
	if x_movement == 1:
		velocity.x = min(velocity.x + a_accel * input_delta, a_speed)
	elif x_movement == -1:
		velocity.x = max(velocity.x - a_accel * input_delta, -a_speed)
	else: # no input
		if velocity.x > 0.1:
			velocity.x = max(velocity.x - a_friction * input_delta, 0)
		elif velocity.x < -0.1:
			velocity.x = min(velocity.x + a_friction * input_delta, 0)
		else:
			velocity.x = 0


func _on_timer_energy_start_cd_timeout():
	has_air_jumped = false


func _on_timer_energy_regen_cd_timeout():
	energy += 10


func _on_timer_is_firing_timeout():
	is_firing = false

func shoot_bullet():
	var bullet = bullet_path.instantiate()
	
	get_parent().add_child(bullet)
	bullet.global_position = bullet_position.global_position
	bullet.direction = get_global_mouse_position() - bullet.global_position
	bullet.rotation = bullet_aim.rotation
	recoil_direction = -bullet.direction.normalized()

# GENERAL TODO:
# 4. gun knocks back player
