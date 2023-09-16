extends RayCast2D

var prev_is_casting: bool = false
var is_casting: bool = false

@onready var enemy: Enemy = get_parent().get_parent()
@onready var laser_line: Line2D = $Line2D
@onready var animator: AnimationPlayer = $AnimationPlayer

@onready var hitbox: Area2D = $Area2D
@onready var hitbox_length: CollisionShape2D = $Area2D/CollisionShape2D

@onready var casting_particle: GPUParticles2D = $CastingParticles
@onready var collision_particle: GPUParticles2D = $CollisionParticles

@onready var dmg_proc_CD: Timer = $Timer_DmgProc

var laser_size: float = 7.0

var damage: float = 20

func _ready():
	set_physics_process(false)
	laser_line.points[1] = Vector2.ZERO
	casting_particle.emitting = false
	collision_particle.emitting = false

func _process(delta: float):
	# this purely handles if physics process starts
	set_is_casting()

func _physics_process(delta: float):
	var cast_point: Vector2 = target_position
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		collision_particle.global_rotation = get_collision_normal().angle()
		collision_particle.position = cast_point
		
	#print("RAH")
	for body in hitbox.get_overlapping_bodies():
		if body is Player and dmg_proc_CD.is_stopped():
			body.take_damage(damage)
			dmg_proc_CD.start()
			print("DPS RACE")
			
	laser_line.points[1] = cast_point
	hitbox_length.shape.b = cast_point / 0.45 # cuz of wonky width workaround with scale
	
	
func set_is_casting(): # set by enemy script
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


func _on_timer_dmg_proc_timeout():
	pass # Replace with function body.
