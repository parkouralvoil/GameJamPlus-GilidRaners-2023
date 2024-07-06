extends State
class_name PlayerOnGround

@onready var p: Player = owner


func Enter() -> void:
	if p.anim_sprite:
		p.anim_sprite.play("idle")
	p.can_double_jump = true


func Exit() -> void:
	pass


func Update(_delta: float) -> void:
	pass


func Physics_Update(_delta: float) -> void:
	if p:
		ground_movement(_delta)
		change_animation()
		jump()
		#DoubleTapDash()
		
	if !p.is_on_floor():
		Transitioned.emit(self, "PlayerInAir")

	if p.fire_input and p.fire_rate_CD.is_stopped():
		Transitioned.emit(self, "PlayerFire")
	
	if Input.is_action_just_pressed("shift_button") and p.can_dash:
		Transitioned.emit(self, "PlayerDash")
		
	if p.hp <= 0:
		Transitioned.emit(self, "PlayerDead")

## the price to pay for not using rigidbody2d (aka my own physics code for acceleration)
func ground_movement(input_delta: float) -> void:
	if p.dash_duration.is_stopped():
		if p.x_movement == 1:
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


#func DoubleTapDash():
	#if Input.is_action_just_pressed("move_left"):
		#if p.dashLeft.is_stopped():
			#dashLeft.start()
			#dashRight.stop()
		#else:
			#p.dash = -1
			#dashLeft.stop()
	#elif Input.is_action_just_released("move_left") and dashLeft.is_stopped():
		#dashLeft.start()
		#dashRight.stop()
	#elif Input.is_action_just_pressed("move_right"):
		#if dashRight.is_stopped():
			#dashRight.start()
			#dashLeft.stop()
		#else:
			#p.dash = 1
			#dashRight.stop()
	#elif Input.is_action_just_released("move_right") and dashRight.is_stopped():
		#dashRight.start()
		#dashLeft.stop()


func jump() -> void:
	if p.y_movement == 1 and p.jump_CD.is_stopped() and p.dash_duration.is_stopped():
		p.velocity.y = p.g_jump_speed
		p.jump_CD.start()


func change_animation() -> void:
	if abs(p.velocity.x) <= 0.1 and p.anim_sprite.animation != "idle":
		p.anim_sprite.play("idle")
	elif abs(p.velocity.x) > 0.1 and p.anim_sprite.animation != "walk":
		p.anim_sprite.play("walk")
	
	#flip char
	if p.x_movement == -1:
		p.anim_sprite.scale.x = -1
		p.dash_dir = -1
	elif p.x_movement == 1:
		p.anim_sprite.scale.x = 1
		p.dash_dir = 1
