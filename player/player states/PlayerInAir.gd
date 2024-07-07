extends State
class_name PlayerInAir

@onready var p: Player = owner


func Enter() -> void:
	if p.anim_sprite:
		p.anim_sprite.play("idle")


func Exit() -> void:
	pass


func Update(_delta: float) -> void:
	pass


func Physics_Update(_delta: float) -> void:
	if p:
		air_movement(_delta)
		change_animation()
		air_jump()
		#air_dash()
		#DoubleTapDash()
	else: 
		return
	
	if p.is_on_floor():
		Transitioned.emit(self, "PlayerOnGround")
	else:
		p.velocity.y += p.gravity * _delta

	if p.fire_input and p.fire_rate_CD.is_stopped():
		Transitioned.emit(self, "PlayerFire")
		#p.fire()
	if Input.is_action_just_pressed("shift_button") and p.can_dash:
		Transitioned.emit(self, "PlayerDash")
	
	if p.hp <= 0:
		Transitioned.emit(self, "PlayerDead")
		
# the price to pay for not using rigidbody2d (aka my own physics code for acceleration)
#func DoubleTapDash():
	#if Input.is_action_just_pressed("move_left"):
		#if dashLeft.is_stopped():
			#dashLeft.start()
			#dashRight.stop()
		#else:
			#p.dash = -1
			#dashLeft.stop()
	#elif Input.is_action_just_pressed("move_right"):
		#if dashRight.is_stopped():
			#dashRight.start()
			#dashLeft.stop()
		#else:
			#p.dash = 1
			#dashRight.stop()

func air_movement(input_delta: float) -> void:
	if not p.jump_CD.is_stopped():
		return
	elif p.x_movement == 1:
		p.velocity.x = min(p.velocity.x + p.g_accel * input_delta, p.g_speed + p.speedModifier)
	elif p.x_movement == -1:
		p.velocity.x = max(p.velocity.x - p.g_accel * input_delta, -p.g_speed - p.speedModifier)
	else: # no input
		if p.velocity.x > 0.1:
			p.velocity.x = max(p.velocity.x - p.g_friction * input_delta, 0)
		elif p.velocity.x < -0.1:
			p.velocity.x = min(p.velocity.x + p.g_friction * input_delta, 0)
		else:
			p.velocity.x = 0


func air_jump() -> void:
	if p.y_movement == 1 and p.jump_CD.is_stopped() and p.can_double_jump and p.dash_duration.is_stopped():
		p.velocity = Vector2(p.velocity.x, p.a_jump_speed)
		p.jump_particles.emitting = true
		p.jump_CD.start()
		p.can_double_jump = false
#		if p.x_movement == 0:
#			p.velocity = Vector2(p.velocity.x, p.a_jump_speed)
#		else:
#			p.velocity = Vector2(p.x_movement * p.a_speed, p.a_jump_speed * 0.8)
			
#func air_dash():	
#	if 	p.dash != 0 and p.energy >= 5 and dash_duration.is_stopped():
#		p.velocity = Vector2(p.velocity.x + (p.d_speed * p.dash), 0)
#		jump_particles.emitting = true
#		dash_duration.start()
#		p.stop_energy_regen = true
#		p.energy -= 5
#		p.dash = 0
#	elif not dash_duration.is_stopped():
#		p.velocity = Vector2(p.velocity.x + (p.d_speed * p.x_movement), 0)

func change_animation() -> void:
	if p.velocity.y > 0.1 and p.anim_sprite.animation != "falling":
		p.anim_sprite.play("falling")
	elif p.velocity.y <= -300 and p.anim_sprite.animation != "jump_high":
		p.anim_sprite.play("jump_high")
	elif -300 < p.velocity.y and p.velocity.y <= -0.1 and p.anim_sprite.animation != "jump_med":
		p.anim_sprite.play("jump_med")
		
	#flip char
	if p.velocity.x <= -0.1:
		p.anim_sprite.scale.x = -1
		p.dash_dir = -1
	elif p.velocity.x >= 0.1:
		p.anim_sprite.scale.x = 1
		p.dash_dir = 1
