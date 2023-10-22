extends Enemy

var laser_path = load("res://entities/projectiles/laser.tscn")
var laser_range: float = 2000

@export var diagonal_laser: bool = false

@onready var hitbox_playerNearby: Area2D = $Area2D_PlayerNearby

@onready var marker_up: Marker2D = $laser_container/Marker2D_down
@onready var marker_down: Marker2D = $laser_container/Marker2D_up
@onready var marker_left: Marker2D = $laser_container/Marker2D_left
@onready var marker_right: Marker2D = $laser_container/Marker2D_right

@onready var body: Sprite2D = $body
@onready var iris: Marker2D = $body/Marker2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

var player_in_sight: bool = false
var markers

# laser start up and fire
var laser_ready: bool = false
var cleared_lasers: bool = false

var laser_anim: AnimationPlayer = null

func _ready():
	body.show()
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
		body.hide()
		anim_player.stop()
		if !cleared_lasers:
			despawn_lasers()
		return
	display_hp = hp	
	iris_movement()
	
	if laser_anim.is_playing() and !anim_player.is_playing():
		anim_player.play("fire")

func _physics_process(delta):
	pass

func iris_movement():
	if target != null:
		var direction = Vector2.ZERO.direction_to(target.global_position - global_position)
		var distance = (target.global_position - global_position).length()
		iris.position = Vector2.ZERO + direction * min(distance, 2)
	else:
		iris.position = Vector2.ZERO

func spawn_lasers():
	cleared_lasers = false
	
	set_laser(marker_up, Vector2(0, -1))
	set_laser(marker_down, Vector2(0, 1))
	set_laser(marker_left, Vector2(-1, 0))
	set_laser(marker_right, Vector2(1, 0))

func set_laser(marker: Marker2D, direction: Vector2):
	var laser = laser_path.instantiate()
	marker.add_child(laser)
	laser.target_position = laser_range * direction
	laser.casting_particle.rotation = direction.angle()
	if laser_anim == null:
		laser_anim = laser.animator

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

func take_damage(damage):
	if hp - damage > 0:
		hp -= damage
		anim_sprite.modulate = Color(1, 0, 0)
		body.modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.2).timeout
		anim_sprite.modulate = Color(1, 1, 1)
		body.modulate = Color(1, 1, 1)
	else:
		hp = 0

func _on_area_2d_player_nearby_body_entered(body):
	if body is Player:
		target = body


func _on_area_2d_player_nearby_body_exited(body):
	if body is Player:
		target = null
