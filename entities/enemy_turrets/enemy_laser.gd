extends Enemy

var max_hp: float = 20.0
var hp: float = max_hp
var atk: float = 20.0 

var laser_path = load("res://entities/projectiles/laser.tscn")
var laser_range: float = 2000

@export var diagonal_laser: bool = false

@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var hitbox_playerNearby: Area2D = $Area2D_PlayerNearby

@onready var marker_up: Marker2D = $laser_container/Marker2D_down
@onready var marker_down: Marker2D = $laser_container/Marker2D_up
@onready var marker_left: Marker2D = $laser_container/Marker2D_left
@onready var marker_right: Marker2D = $laser_container/Marker2D_right

var target: Player = null
var player_in_sight: bool = false

# laser start up and fire
var laser_ready: bool = false

# healthbar:
@onready var display_hp = $Control/Label_HP:
	set(value):
		display_hp.text = "{0}/{1}".format([str(value), str(max_hp)])

func _ready():
	$Control.global_position = global_position
	if diagonal_laser == true:
		anim_sprite.rotation_degrees = 45
		$laser_container.rotation_degrees = 45
	
	spawn_lasers()

func _process(delta):
	if hp == 0:
		die()
		return
	display_hp = hp	

func _physics_process(delta):
	pass


func take_damage(damage):
	if hp - damage > 0:
		hp -= damage
		anim_sprite.self_modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.2).timeout
		anim_sprite.self_modulate = Color(1, 1, 1)
	else:
		hp = 0
		
func die():
	anim_sprite.visible = false
	
	queue_free()


func spawn_lasers():
	var markers = [marker_down, marker_up, marker_left, marker_right]
	
	for mark in markers:
		var laser = laser_path.instantiate()
		
		mark.add_child(laser)
		laser.target_position = laser_range * mark.position.normalized()
		laser.casting_particle.rotation = mark.position.normalized().angle()

#func shoot_bullet():
#	var bullet = bullet_path.instantiate()
#
#	get_parent().add_child(bullet)
#	bullet.global_position = global_position
#	bullet.direction = marker.global_position - bullet.global_position
#	bullet.rotation = turret_aim.rotation
