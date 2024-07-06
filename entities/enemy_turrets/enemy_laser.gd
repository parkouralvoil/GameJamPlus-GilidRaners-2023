extends Enemy
class_name EnemyLaser

const LaserPath: PackedScene = preload("res://entities/projectiles/laser.tscn")

@export var diagonal_laser: bool = false

var laser_range: float = 2000
var player_in_sight: bool = false
var markers: Array[Marker2D] = []

## laser start up and fire
var laser_ready: bool = false
var cleared_lasers: bool = false

var laser_anim: AnimationPlayer = null ## animation dependence with laser

@onready var hitbox_playerNearby: Area2D = $Area2D_PlayerNearby
@onready var marker_up: Marker2D = $laser_container/Marker2D_down
@onready var marker_down: Marker2D = $laser_container/Marker2D_up
@onready var marker_left: Marker2D = $laser_container/Marker2D_left
@onready var marker_right: Marker2D = $laser_container/Marker2D_right
@onready var sprite_body: Sprite2D = $sprite_body
@onready var iris: Marker2D = $sprite_body/Marker2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super()
	sprite_body.show()
	$Control.global_position = global_position
	if diagonal_laser == true:
		$laser_container.rotation_degrees = 45
	
	markers = [marker_down, marker_up, marker_left, marker_right]
	spawn_lasers()


func _process(_delta: float) -> void:
	if hp <= 0:
		sprite_body.hide()
		anim_player.stop()
		if !cleared_lasers:
			despawn_lasers()
		return
	
	iris_movement()
	
	if laser_anim.is_playing() and !anim_player.is_playing():
		anim_player.play("fire")


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
	if laser_anim == null:
		laser_anim = laser.animator


func despawn_lasers() -> void:
	cleared_lasers = true
	for mark in markers:
		var laser: Laser = mark.get_child(0)
		laser.queue_free()


func respawn() -> void:
	super()
	spawn_lasers()


func show_damage_visual() -> void:
	var t: Tween = create_tween()
	t.tween_property(sprite_body, "self_modulate", color_default, 0.1).from(color_red)


func _on_area_2d_player_nearby_body_entered(body: CharacterBody2D) -> void:
	if body is Player:
		target = body


func _on_area_2d_player_nearby_body_exited(body: CharacterBody2D) -> void:
	if body is Player:
		target = null
