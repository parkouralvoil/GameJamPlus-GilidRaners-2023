extends State
class_name PlayerInAir

@onready var player: CharacterBody2D = get_parent().get_parent()
	# above assumes this state is child of State Machine, child of player node
@onready var anim_sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
@onready var jump_CD: Timer = player.get_node("Timer_JumpCD")
@onready var energy_start_CD: Timer = player.get_node("Timer_EnergyStartCD")
@onready var energy_regen_CD: Timer = player.get_node("Timer_EnergyRegenCD")
@onready var jump_particles: GPUParticles2D = player.get_node("GPUParticles2D_Jump")
# each state needs to have their own reference since the @onready is important

@onready var fire_rate_CD: Timer = player.get_node("Timer_FireRateCD")

func Enter():
	anim_sprite.play("idle")

	
func Exit():
	pass


func Update(_delta: float):
	pass


func Physics_Update(_delta: float):
	if player:
		air_movement(_delta)
		change_animation()
		air_jump()
	else: return
	
	if player.is_on_floor():
		Transitioned.emit(self, "PlayerOnGround")
	else:
		player.velocity.y += player.gravity * _delta

	if player.fire_input and fire_rate_CD.is_stopped() and player.ammo > 0:
		Transitioned.emit(self, "PlayerFire")
		#player.fire()
	
	if player.hp <= 0:
		Transitioned.emit(self, "PlayerDead")
		
# the price to pay for not using rigidbody2d (aka my own physics code for acceleration)
func air_movement(input_delta):
	if player.x_movement == 1:
		player.velocity.x = min(player.velocity.x + player.g_accel * input_delta, player.g_speed)
	elif player.x_movement == -1:
		player.velocity.x = max(player.velocity.x - player.g_accel * input_delta, -player.g_speed)
	else: # no input
		if player.velocity.x > 0.1:
			player.velocity.x = max(player.velocity.x - player.g_friction * input_delta, 0)
		elif player.velocity.x < -0.1:
			player.velocity.x = min(player.velocity.x + player.g_friction * input_delta, 0)
		else:
			player.velocity.x = 0
#	if player.x_movement == 1:
#		player.velocity.x = min(player.velocity.x + player.a_accel * input_delta, player.a_speed)
#	elif player.x_movement == -1:
#		player.velocity.x = max(player.velocity.x - player.a_accel * input_delta, -player.a_speed)
#	else: # no input
#		if player.velocity.x > 0.1:
#			player.velocity.x = max(player.velocity.x - player.a_friction * input_delta, 0)
#		elif player.velocity.x < -0.1:
#			player.velocity.x = min(player.velocity.x + player.a_friction * input_delta, 0)
#		else:
#			player.velocity.x = 0

func air_jump():	
	if player.y_movement == 1 and jump_CD.is_stopped() and player.energy >= 15:
		player.velocity = Vector2(player.velocity.x, player.a_jump_speed)
#		if player.x_movement == 0:
#			player.velocity = Vector2(player.velocity.x, player.a_jump_speed)
#		else:
#			player.velocity = Vector2(player.x_movement * player.a_speed, player.a_jump_speed * 0.8)
			
		jump_particles.emitting = true
		jump_CD.start()
		energy_start_CD.start()
		energy_regen_CD.stop()
		player.stop_energy_regen = true
		player.energy -= 20
				
func change_animation():
	if player.velocity.y > 0.1 and anim_sprite.animation != "falling":
		anim_sprite.play("falling")
	elif player.velocity.y <= -300 and anim_sprite.animation != "jump_high":
		anim_sprite.play("jump_high")
	elif -300 < player.velocity.y and player.velocity.y <= -0.1 and anim_sprite.animation != "jump_med":
		anim_sprite.play("jump_med")
		
	#flip char
	if player.velocity.x <= -0.1:
		anim_sprite.scale.x = -1
	elif player.velocity.x >= 0.1:
		anim_sprite.scale.x = 1
