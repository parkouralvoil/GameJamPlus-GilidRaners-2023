extends State
class_name PlayerDash


@onready var p: Player = owner


func Enter() -> void:
	if p.anim_sprite:
		p.anim_sprite.play("dash")
	p.velocity = Vector2(200 * p.dash_dir, 0) # to set direction and initial speed
	
	p.can_dash = false
	if p.dash_duration:
		p.dash_duration.start()
	if p.dash_CD:
		p.dash_CD.start()
	if p.jump_particles:
		p.jump_particles.emitting = true
		


func Exit() -> void:
	p.velocity = Vector2.ZERO
	p.jump_particles.emitting = false


func Update(input_delta: float) -> void:
	if p.dash_dir == 1:
		p.velocity.x = min(p.velocity.x + p.d_accel * input_delta, p.d_speed)
	elif p.dash_dir == -1:
		p.velocity.x = max(p.velocity.x - p.d_accel * input_delta, -p.d_speed)


func Physics_Update(_delta: float) -> void:
	if p:
		change_animation()
	
	if p.hp <= 0:
		Transitioned.emit(self, "PlayerDead")
	
	if p.dash_duration.is_stopped():
		if !p.is_on_floor():
			Transitioned.emit(self, "PlayerInAir")
		else:
			Transitioned.emit(self, "PlayerOnGround")


func change_animation() -> void:
	##flip char
	if p.dash_dir == -1:
		p.anim_sprite.scale.x = -1
	elif p.dash_dir == 1:
		p.anim_sprite.scale.x = 1
