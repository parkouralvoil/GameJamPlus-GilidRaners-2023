extends State
class_name PlayerFire

@onready var p: Player = owner
	# above assumes this state is child of State Machine, child of p node

func Enter() -> void:
	p.fire()
	apply_recoil()
	p.anim_sprite.stop()
	p.anim_sprite.play("shoot")


func Exit() -> void:
	pass


func Update(_delta: float) -> void:
	pass


func Physics_Update(_delta: float) -> void:
	if p:
		halt_recoil(_delta)
	else: 
		return
	
	if !p.is_firing:
		if p.is_on_floor():
			Transitioned.emit(self, "PlayerOnGround")
		else:
			Transitioned.emit(self, "PlayerInAir")
	
	if p.hp <= 0:
		Transitioned.emit(self, "PlayerDead")


func apply_recoil() -> void:
	if p.is_on_floor():
		p.velocity = Vector2.ZERO
	else:
		p.velocity.x = -p.bullet_aim.x * 100
		p.velocity.y = 40


func halt_recoil(input_delta: float) -> void:
	## horizontal
	if p.velocity.x > 0.1:
		p.velocity.x = max(p.velocity.x - p.g_friction * 0.1 * input_delta, 0)
	elif p.velocity.x < -0.1:
		p.velocity.x = min(p.velocity.x + p.g_friction * 0.1 * input_delta, 0)
#	else:
#		p.velocity.x = 0
		
	## vertical
	if p.velocity.y > -0.1:
		p.velocity.y = max(p.velocity.y - p.g_friction * 0.1 * input_delta, 0)
	elif p.velocity.y < 0.1:
		p.velocity.y = min(p.velocity.y + p.g_friction * 0.1 * input_delta, 0)
#	else:
#		p.velocity.y = 0
