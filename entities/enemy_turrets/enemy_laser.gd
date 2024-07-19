extends Enemy
class_name EnemyLaser

const LaserPath: PackedScene = preload("res://entities/projectiles/laser.tscn")

@export var diagonal_laser: bool = false

var laser_range: float = 2000
var lasers_spawned: bool = false
var player_in_sight: bool = false:
	set(value):
		player_in_sight = value
		if value == true and not lasers_spawned:
			spawn_lasers()
			lasers_spawned = true

var markers: Array[Marker2D] = []

## laser start up and fire
var laser_ready: bool = false
var cleared_lasers: bool = false

var laser_ref: Laser = null ## animation dependence with laser

@onready var hitbox_playerNearby: Area2D = $Area2D_PlayerNearby
@onready var laser_container: Node2D = $laser_container
@onready var marker_up: Marker2D = $laser_container/Marker2D_down
@onready var marker_down: Marker2D = $laser_container/Marker2D_up
@onready var marker_left: Marker2D = $laser_container/Marker2D_left
@onready var marker_right: Marker2D = $laser_container/Marker2D_right
@onready var sprite_body: Sprite2D = $sprite_body
@onready var iris: Marker2D = $sprite_body/Marker2D

@onready var RC_player: RayCast2D = $RayCast2D_Player

@onready var hostile_sprite: Sprite2D = $sprite_body/hostile


func _ready() -> void:
	super()
	sprite_body.show()
	if diagonal_laser == true:
		laser_container.rotation_degrees = 45
	
	markers = [marker_down, marker_up, marker_left, marker_right]


func _process(_delta: float) -> void:
	if hp <= 0:
		sprite_body.hide()
		if !cleared_lasers:
			despawn_lasers()
		return
	
	iris_movement()
	player_vision()
	
	if lasers_spawned:
		if laser_ref.is_casting:
			hostile_sprite.show()
		else:
			hostile_sprite.hide()


func iris_movement() -> void:
	if target != null:
		var direction: = Vector2.ZERO.direction_to(target.global_position - global_position)
		var distance: float = (target.global_position - global_position).length()
		iris.position = Vector2.ZERO + direction * min(distance, 2)
	else:
		iris.position = Vector2.ZERO


func spawn_lasers() -> void:
	cleared_lasers = false
	set_laser(marker_up, Vector2(0, -1))
	set_laser(marker_down, Vector2(0, 1))
	set_laser(marker_left, Vector2(-1, 0))
	set_laser(marker_right, Vector2(1, 0))


func set_laser(marker: Marker2D, direction: Vector2) -> void:
	var laser: Laser = LaserPath.instantiate()
	marker.add_child(laser)
	laser.target_position = laser_range * direction
	laser.casting_particle.rotation = direction.angle()
	if laser_ref == null:
		laser_ref = laser


func despawn_lasers() -> void:
	cleared_lasers = true
	for mark in markers:
		var laser: Laser = mark.get_child(0)
		laser.queue_free()


#func respawn() -> void:
	#super()
	#spawn_lasers()


func player_vision() -> void:
	if not target:
		player_in_sight = false
		return
	
	RC_player.target_position = target.global_position - global_position
	if RC_player.get_collider() == target:
		player_in_sight = true
	else:
		player_in_sight = false


func show_damage_visual() -> void:
	var t: Tween = create_tween()
	t.tween_property(sprite_body, "self_modulate", color_default, 0.1).from(color_red)


func _on_area_2d_player_nearby_body_entered(body: CharacterBody2D) -> void:
	if body is Player:
		target = body


func _on_area_2d_player_nearby_body_exited(body: CharacterBody2D) -> void:
	if body is Player:
		target = null
