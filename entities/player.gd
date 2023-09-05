class_name Player
extends CharacterBody2D

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

var stop_energy_regen: bool = false

@onready var jump_CD = $Timer_JumpCD
@onready var energy_start_CD = $Timer_EnergyStartCD
@onready var energy_regen_CD = $Timer_EnergyRegenCD
@onready var timer_is_firing = $Timer_IsFiring
var is_firing := false
@onready var fire_rate_CD = $Timer_FireRateCD

@onready var anim_sprite = $AnimatedSprite2D
@onready var jump_particles = $GPUParticles2D_Jump

@onready var bullet_aim = $Node2D_Aim
@onready var bullet_position = $Node2D_Aim/Marker2D

@onready var state_machine = $"State Machine"

# input logic (when i add input buffers for jumping or cooldowns)
var x_movement: float
var y_movement: float

var input_fire: bool = false

func _ready():
	print(state_machine.states)
	pass
	
func _process(delta):
	bullet_aim.look_at(get_global_mouse_position())
	
	x_movement = Input.get_axis("move_left", "move_right")
	y_movement = Input.get_axis("move_up", "move_down")


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

# sept 5: need to do
# 1. more convenient firing (hold down m1 to keep shooting)
# 2. adjustable bullet (in code, it can be swapped between enemy or player use)
# 3. enemy_trap fires arrows
# 4. enemy_trap moves up and down
# 5. player can take dmg and die
# 6. player can respawn


# archives:
# Player script will contain all logic responsible for
	# choosing weapon, firing weapon, whether weapon has certain properties or not
	# PlayerFire.gd will only bother with actually moving the player, slowing them down, and chainging states.
	
# variables:
	# if a state script needs a particular component of the player,
	# imo it is clearer if it's referenced by the state script itself
	# but there is a benefit to making the 
	# player.gd be the "central logic" part
	# while all the other states just focus on moving/acting the player

# the responsibility changing current states will still be managed by the states

# ok in hindsight, prob way better to just have the states handle the transitions too
# also, repeated shooting should be in fire state
# also, player should be able to cancel fire recoil by jumping
