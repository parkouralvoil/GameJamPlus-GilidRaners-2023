extends State
class_name PlayerDash

@onready var player: CharacterBody2D = get_parent().get_parent()
	# above assumes this state is child of State Machine, child of player node
@onready var anim_sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")

@onready var dash_CD: Timer = player.get_node("Timer_DashCD")

@onready var jump_particles: GPUParticles2D = player.get_node("GPUParticles2D_Jump")
	
func Enter():
	anim_sprite.play("walk")
	
	player.velocity = Vector2(200 * player.dash, 0) # to set direction and initial speed
	dash_CD.start()
	jump_particles.emitting = true


func Exit():
	player.velocity = Vector2.ZERO
	jump_particles.emitting = false


func Update(input_delta: float):
	if player.dash == 1:
		player.velocity.x = min(player.velocity.x + player.d_accel * input_delta, player.d_speed)
	elif player.dash == -1:
		player.velocity.x = max(player.velocity.x - player.d_accel * input_delta, -player.d_speed)

func Physics_Update(_delta: float):
	if player:
		change_animation()
	
	if player.hp <= 0:
		Transitioned.emit(self, "PlayerDead")
	
	if dash_CD.is_stopped():
		if !player.is_on_floor():
			Transitioned.emit(self, "PlayerInAir")
		else:
			Transitioned.emit(self, "PlayerOnGround")


func change_animation():
	#flip char
	if player.dash == -1:
		anim_sprite.scale.x = -1
	elif player.dash == 1:
		anim_sprite.scale.x = 1
