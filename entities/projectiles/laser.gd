extends RayCast2D
class_name Laser

var prev_is_casting: bool = false
var is_casting: bool = true

var laser_size: float = 7.0
var cast_point: Vector2 = target_position

var damage: int = 1
var target: Player = null

@onready var laser_line: Line2D = $Line2D
@onready var animator: AnimationPlayer = $AnimationPlayer

@onready var hitbox: Area2D = $Area2D
@onready var hitbox_length: CollisionShape2D = $Area2D/CollisionShape2D

@onready var casting_particle: GPUParticles2D = $CastingParticles
@onready var collision_particle: GPUParticles2D = $CollisionParticles

@onready var reload_CD: Timer = $Timer_Reload


func _ready() -> void:
	is_casting = true
	set_physics_process(true)
	laser_line.points[1] = Vector2.ZERO
	casting_particle.emitting = false
	collision_particle.emitting = false


func _process(_delta: float) -> void:
	## this purely handles if physics process starts
	set_is_casting()


func _physics_process(_delta: float) -> void:
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		collision_particle.global_rotation = get_collision_normal().angle()
		collision_particle.position = cast_point
		
	laser_line.points[1] = cast_point
	@warning_ignore("unsafe_property_access")
	hitbox_length.shape.b = cast_point
	if target != null:
		target.take_damage(damage) ## need iframes here or one shot moment


func set_is_casting() -> void:
	if is_casting and !prev_is_casting:
		prev_is_casting = true
		animator.play("laser_firing")
		set_physics_process(true)
		prev_is_casting = true
	
	elif !is_casting and prev_is_casting:
		if animator.is_playing():
			animator.stop()
		set_physics_process(false)
		prev_is_casting = false


func _deactivate_laser() -> void: ## for animation player
	is_casting = false
	reload_CD.start()


func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body is Player:
		target = body


func _on_area_2d_body_exited(body: CharacterBody2D) -> void:
	if body is Player:
		target = null


func _on_timer_reload_timeout() -> void:
	is_casting = true
