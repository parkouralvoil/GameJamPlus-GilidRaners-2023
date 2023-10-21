extends State
class_name PlayerOnGround

@onready var player: CharacterBody2D = get_parent().get_parent()
	# above assumes this state is child of State Machine, child of player node
@onready var anim_sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")

@onready var energy_start_CD: Timer = player.get_node("Timer_EnergyStartCD")
@onready var jump_CD: Timer = player.get_node("Timer_JumpCD")

@onready var dashLeft: Timer =player.get_node("Left_DoubleTap")
@onready var dashRight: Timer =player.get_node("Right_DoubleTap")
@onready var dash_CD: Timer = player.get_node("Timer_DashCD")

@onready var jump_particles: GPUParticles2D = player.get_node("GPUParticles2D_Jump")
@onready var fire_rate_CD: Timer = player.get_node("Timer_FireRateCD")
	
func Enter():
	anim_sprite.play("idle")
	energy_start_CD.stop()
#	player.stop_energy_regen = false
	player.energy = player.max_energy

	
func Exit():
	pass


func Update(_delta: float):
	pass


func Physics_Update(_delta: float):
	if player:
		ground_movement(_delta)
		change_animation()
		jump()
		DoubleTapDash()
		dash()
	if !player.is_on_floor():
		Transitioned.emit(self, "PlayerInAir")

	if player.fire_input and fire_rate_CD.is_stopped() and player.ammo > 0:
		Transitioned.emit(self, "PlayerFire")
		#player.fire()
		
	if player.hp <= 0:
		Transitioned.emit(self, "PlayerDead")

# the price to pay for not using rigidbody2d (aka my own physics code for acceleration)
func ground_movement(input_delta):
	if player.x_movement == 1:
		player.velocity.x = min(player.velocity.x + player.g_accel * input_delta, player.g_speed + player.speedModifier)
	elif player.x_movement == -1:
		player.velocity.x = max(player.velocity.x - player.g_accel * input_delta, -player.g_speed -player.speedModifier)
	else: # no input
		if player.velocity.x > 0.1:
			player.velocity.x = max(player.velocity.x - player.g_friction * input_delta, 0)
		elif player.velocity.x < -0.1:
			player.velocity.x = min(player.velocity.x + player.g_friction * input_delta, 0)
		else:
			player.velocity.x = 0

func DoubleTapDash():
	if Input.is_action_just_pressed("move_left"):
		if dashLeft.is_stopped():
			dashLeft.start()
			dashRight.stop()
		else:
			player.dash = -1
			dashLeft.stop()
	elif Input.is_action_just_released("move_left") and dashLeft.is_stopped():
		dashLeft.start()
		dashRight.stop()
	elif Input.is_action_just_pressed("move_right"):
		if dashRight.is_stopped():
			dashRight.start()
			dashLeft.stop()
		else:
			player.dash = 1
			dashRight.stop()
	elif Input.is_action_just_released("move_right") and dashRight.is_stopped():
		dashRight.start()
		dashLeft.stop()
	pass

func jump():	
	if player.y_movement == 1 and jump_CD.is_stopped():
		player.velocity.y = player.g_jump_speed
		jump_CD.start()
				
func dash():
	if player.dash != 0 and player.energy >= 5 and dash_CD.is_stopped():
		player.velocity.x = player.d_speed * player.dash * 4
		dash_CD.start()
		jump_particles.emitting = true
		pass
		
func change_animation():
	if abs(player.velocity.x) <= 0.1 and anim_sprite.animation != "idle":
		anim_sprite.play("idle")
	elif abs(player.velocity.x) > 0.1 and anim_sprite.animation != "walk":
		anim_sprite.play("walk")
	
	#flip char
	if player.x_movement == -1:
		anim_sprite.scale.x = -1
	elif player.x_movement == 1:
		anim_sprite.scale.x = 1
