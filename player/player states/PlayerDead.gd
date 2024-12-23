extends State
class_name PlayerDead

@onready var p: Player = owner
	
func Enter() -> void: ## now just an "dead-end" state
	if p.anim_sprite:
		p.anim_sprite.play("dead")
	p.can_double_jump = false
	p.hp = 0
	if p.anim_sprite:
		p.anim_sprite.self_modulate = Color(1, 1, 1)
#	respawn_CD.start()


func Exit() -> void:
	pass


func Update(_delta: float) -> void:
	pass

func Physics_Update(_delta: float) -> void:
	if not p: 
		return
	
	if p.is_on_floor():
		ground_movement(_delta)
	else:
		p.velocity.y += p.gravity * _delta
		air_movement(_delta)

## still need to bring p to halt
func air_movement(input_delta: float) -> void:
	if p.velocity.x > 0.1:
		p.velocity.x = max(p.velocity.x - p.a_friction * input_delta, 0)
	elif p.velocity.x < -0.1:
		p.velocity.x = min(p.velocity.x + p.a_friction * input_delta, 0)
	else:
		p.velocity.x = 0


func ground_movement(input_delta: float) -> void:
	if p.velocity.x > 0.1:
		p.velocity.x = max(p.velocity.x - p.g_friction * input_delta, 0)
	elif p.velocity.x < -0.1:
		p.velocity.x = min(p.velocity.x + p.g_friction * input_delta, 0)
	else:
		p.velocity.x = 0
