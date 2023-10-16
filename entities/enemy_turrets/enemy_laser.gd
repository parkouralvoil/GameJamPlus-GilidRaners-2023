extends Enemy

var laser_path = load("res://entities/projectiles/laser.tscn")
var laser_range: float = 2000

@export var diagonal_laser: bool = false

@onready var hitbox_playerNearby: Area2D = $Area2D_PlayerNearby

@onready var marker_up: Marker2D = $laser_container/Marker2D_down
@onready var marker_down: Marker2D = $laser_container/Marker2D_up
@onready var marker_left: Marker2D = $laser_container/Marker2D_left
@onready var marker_right: Marker2D = $laser_container/Marker2D_right

var player_in_sight: bool = false
var markers

# laser start up and fire
var laser_ready: bool = false
var cleared_lasers: bool = false

func _ready():
	max_hp = 20.0
	hp = max_hp
	atk = 2.0
	$Control.global_position = global_position
	if diagonal_laser == true:
		anim_sprite.rotation_degrees = 45
		$laser_container.rotation_degrees = 45
	
	markers = [marker_down, marker_up, marker_left, marker_right]
	spawn_lasers()

func _process(delta):
	if hp <= 0:
		die()
		if !cleared_lasers:
			despawn_lasers()
		return
	display_hp = hp	

func _physics_process(delta):
	pass


func spawn_lasers():
	cleared_lasers = false
	for mark in markers:
		var laser = laser_path.instantiate()
		
		mark.add_child(laser)
		laser.target_position = laser_range * mark.position.normalized()
		laser.casting_particle.rotation = mark.position.normalized().angle()

func despawn_lasers():
	cleared_lasers = true
	for mark in markers:
		var laser = mark.get_child(0)
		
		laser.queue_free()
		
func respawn():
	hp = max_hp
	anim_sprite.visible = true
	display_hp.visible = true
	hitbox.set_deferred("disabled", false)
	spawn_lasers()
