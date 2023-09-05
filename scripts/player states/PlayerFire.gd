extends State
class_name PlayerFire

@onready var player: CharacterBody2D = get_parent().get_parent()
	# above assumes this state is child of State Machine, child of player node
@onready var anim_sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
@onready var fire_rate_CD: Timer = player.get_node("Timer_FireRateCD")
@onready var timer_is_firing: Timer = player.get_node("Timer_IsFiring")

func Enter():
	player.is_firing = true
	fire_rate_CD.start()
	timer_is_firing.start()
	
	player.shoot_bullet()
	flip_player()
	
	apply_recoil()

func Exit():
	pass


func Update(_delta: float):
	pass


func Physics_Update(_delta: float):
	if player:
		halt_recoil(_delta)
		change_animation()
	else: return
	
	if !player.is_firing:
		if player.is_on_floor():
			Transitioned.emit(self, "PlayerOnGround")
		else:
			Transitioned.emit(self, "PlayerInAir")
			
	if Input.is_action_just_pressed("shoot") and fire_rate_CD.is_stopped(): # continue firing
		fire_rate_CD.start()
		timer_is_firing.start()
		player.shoot_bullet()
		flip_player()
		apply_recoil()
		
func apply_recoil():
	if player.is_on_floor():
		player.velocity = Vector2.ZERO
	else:
		player.velocity = player.recoil_direction.normalized() * 100

func halt_recoil(input_delta):
	# horizontal
	if player.velocity.x > 0.1:
		player.velocity.x = max(player.velocity.x - player.g_friction * 0.1 * input_delta, 0)
	elif player.velocity.x < -0.1:
		player.velocity.x = min(player.velocity.x + player.g_friction * 0.1 * input_delta, 0)
#	else:
#		player.velocity.x = 0
		
	# vertical
	if player.velocity.y > -0.1:
		player.velocity.y = max(player.velocity.y - player.g_friction * 0.1 * input_delta, 0)
	elif player.velocity.y < 0.1:
		player.velocity.y = min(player.velocity.y + player.g_friction * 0.1 * input_delta, 0)
#	else:
#		player.velocity.y = 0


func change_animation():
	if anim_sprite.animation != "shoot":
		anim_sprite.play("shoot")

func flip_player():
	if player.get_global_mouse_position().x < player.global_position.x:
		anim_sprite.scale.x = 1
	else:
		anim_sprite.scale.x = -1
