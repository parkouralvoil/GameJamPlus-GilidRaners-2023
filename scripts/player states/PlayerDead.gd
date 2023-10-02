extends State
class_name PlayerDead

@onready var player: CharacterBody2D = get_parent().get_parent()
	# above assumes this state is child of State Machine, child of player node
@onready var anim_sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
@onready var reload_CD: Timer = player.get_node("Timer_Reload")
@onready var respawn_CD: Timer = player.get_node("Timer_Respawn")
	
func Enter():
	anim_sprite.play("idle")
	player.stop_energy_regen = true
	reload_CD.stop()
	player.hp = 0
	respawn_CD.start()
	
func Exit():
	player.hp = player.max_hp


func Update(_delta: float):
	if player.just_respawned:
		player.global_position = player.respawn_point
		Transitioned.emit(self, "PlayerInAir")
		player.just_respawned = false

func Physics_Update(_delta: float):
	if player:
		change_animation()
	else: return
	
	if player.is_on_floor():
		ground_movement(_delta)
	else:
		player.velocity.y += player.gravity * _delta
		air_movement(_delta)

# still need to bring player to halt
func air_movement(input_delta):
	if player.velocity.x > 0.1:
		player.velocity.x = max(player.velocity.x - player.a_friction * input_delta, 0)
	elif player.velocity.x < -0.1:
		player.velocity.x = min(player.velocity.x + player.a_friction * input_delta, 0)
	else:
		player.velocity.x = 0
		
func ground_movement(input_delta):
	if player.velocity.x > 0.1:
		player.velocity.x = max(player.velocity.x - player.g_friction * input_delta, 0)
	elif player.velocity.x < -0.1:
		player.velocity.x = min(player.velocity.x + player.g_friction * input_delta, 0)
	else:
		player.velocity.x = 0

func change_animation():
	if anim_sprite.animation != "dead":
		anim_sprite.play("dead")
