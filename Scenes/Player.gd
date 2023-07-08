class_name Player extends CharacterBody2D

signal laser_shot(laser)
signal died

# FAST
@export var fast_accel := 20.0
@export var fast_max_speed := 500.0
@export var fast_rotation_speed := 480.0

# PRECISE
@export var pre_accel := 50.0
@export var pre_max_speed := 200.0
@export var pre_rotation_speed := 480.0

@onready var muzzle = $Muzzle
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D
# need to disable collision shape 2d

var laser_scene = preload("res://Scenes/laser.tscn")

var shoot_cd = false
var rate_of_fire = 0.15

var alive = true

enum movement_state{
	FAST,
	PRECISE
}
var current_state := movement_state.FAST


func _process(delta):
	if !alive: return

	if Input.is_action_pressed("shoot"):
		if !shoot_cd:
			shoot_cd = true
			shoot_laser()
			await get_tree().create_timer(rate_of_fire).timeout
			shoot_cd = false

	# change state logic
	if Input.is_action_just_pressed("change_movement_state"):
		match current_state:
			movement_state.FAST:
				current_state = movement_state.PRECISE
				await get_tree().create_timer(1).timeout
			movement_state.PRECISE:
				current_state = movement_state.FAST
				await get_tree().create_timer(1).timeout
	#print(current_state)


func _physics_process(delta):
	if !alive: return
	
	var input_direction: Vector2
	
	var x_movement = Input.get_axis("move_left", "move_right")
	var y_movement = Input.get_axis("move_forward", "move_backward")
	
	match current_state:
		movement_state.FAST:
			input_direction = Vector2(0, y_movement)
			
			# BASIC FAST MOVEMENT
			velocity += input_direction.rotated(rotation) * fast_accel
			velocity = velocity.limit_length(fast_max_speed)
			if Input.is_action_pressed("move_right"):
				rotate(deg_to_rad(fast_rotation_speed * delta))
			if Input.is_action_pressed("move_left"):
				rotate(deg_to_rad(-fast_rotation_speed * delta))
				
			if input_direction.y == 0:
				# move toward <0,0> by steps of 3
				velocity = velocity.move_toward(Vector2.ZERO, 3)
				
			# ROTATION, SLOWS DOWN TO 60% AT MAX SPEED:
			# first draft, 
			# at half speed, you rotate 90%
			# at 75% speed, you rotate 80%
			# at full speed, you rotate 70%
			# at nitro (125%), you rotate 60%
			# linear increase
			var weaken_fast_rotaiton = 0.0008 * velocity.length()
			if velocity.length() >= fast_max_speed/2: 
				fast_rotation_speed = 480 * (1 - weaken_fast_rotaiton)
			else:
				fast_rotation_speed = 480
			print(fast_rotation_speed)
			
			if Input.is_action_pressed("shift_button") and y_movement == -1:
				fast_max_speed = 500 * 1.5
				fast_accel = 20 * 2
			else:
				fast_max_speed = 500
				fast_accel = 20
				
				
		movement_state.PRECISE:
			input_direction = Vector2(x_movement, y_movement)
			
			var omni_move = input_direction.normalized() * pre_accel
			
			# smooth slow down
			if velocity.length() > pre_max_speed:
				if input_direction != Vector2.ZERO:
					velocity = velocity.move_toward(omni_move, 9)
				else:
					velocity = velocity.move_toward(Vector2.ZERO, 9)
			else:
				if input_direction != Vector2.ZERO:
					velocity += omni_move
					velocity = velocity.limit_length(pre_max_speed)
				else:
					velocity = velocity.move_toward(Vector2.ZERO, 20)
					
			if Input.is_action_pressed("shift_button") and input_direction != Vector2.ZERO:
				pass

			# smooth rotation
			# https://www.youtube.com/watch?v=ciT_jDol9G8&ab_channel=JasonLothamer
			# constant rotation speed, look at mouse pos
			var mouse_relative_pos = get_global_mouse_position() - global_position
			var angle = mouse_relative_pos.angle() + PI/2
			
			var RS = deg_to_rad(pre_rotation_speed * delta)
			angle = lerp_angle(global_rotation, angle, 0.5)
			angle = clamp(angle, global_rotation - RS, global_rotation + RS)
			global_rotation = angle
	
	#print(velocity.length())
	
	move_and_slide()
	
	# this makes it literally Asteroid game, for now ill follow along
	# then once its almost done ill start changing it up a bit	
#	var screen_size = get_viewport_rect().size
#	if global_position.y < 0:
#		global_position.y = screen_size.y
#	elif global_position.y > screen_size.y:
#		global_position.y = 0
#
#	if global_position.x < 0:
#		global_position.x = screen_size.x
#	elif global_position.x > screen_size.x:
#		global_position.x = 0


func shoot_laser():
	var l = laser_scene.instantiate()
	l.global_position = muzzle.global_position
	l.rotation = rotation
	emit_signal("laser_shot", l)


func die():
	if alive == true:
		alive = false
		sprite.visible = false
		#process_mode = Node.PROCESS_MODE_DISABLED
		cshape.set_deferred("disabled", true)
		emit_signal('died')


func respawn(pos):
	if alive == false:
		alive = true
		global_position = pos
		velocity = Vector2.ZERO	
		sprite.visible = true
		#process_mode = Node.PROCESS_MODE_INHERIT
		cshape.set_deferred("disabled", false)
		
# TODO:
# 3. figure out why particles are disappearing (not rlly important)
# 4. Make good background to keep track of where dafuq player is
# 5. PRECISE STATE: Dash when shift
# 6. FAST STATE: Nitro boost when shift (smooth acceleration, more top speed)
