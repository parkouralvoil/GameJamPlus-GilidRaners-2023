class_name Enemy extends CharacterBody2D

signal enemy_laser_shot(laser)
signal enemy_died

@onready var muzzle = $Muzzle
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D
# need to disable collision shape 2d

var laser_scene = preload("res://Scenes/enemies/enemy_laser.tscn")

var shoot_cd = false
var rate_of_fire = 0.6

var rotation_speed = 150

var alive = true

var target = null


func _physics_process(delta):
	if !alive: return
	
	if target != null:
		var mouse_relative_pos = target.global_position - global_position
		var angle = mouse_relative_pos.angle() + PI/2
		
		var RS = deg_to_rad(rotation_speed * delta)
		angle = lerp_angle(global_rotation, angle, 0.5)
		angle = clamp(angle, global_rotation - RS, global_rotation + RS)
		global_rotation = angle
		
		if !shoot_cd:
			shoot_cd = true
			shoot_laser()
			await get_tree().create_timer(rate_of_fire).timeout
			shoot_cd = false

func shoot_laser():
	print("firing")
	var l = laser_scene.instantiate()
	l.global_position = muzzle.global_position
	l.rotation = rotation
	emit_signal("enemy_laser_shot", l)


func die():
	if alive == true:
		alive = false
		sprite.visible = false
		cshape.set_deferred("disabled", true)
		emit_signal('died')


func _on_vision_range_body_entered(body):
	if body is Player:
		target = body
		print("player entered")


func _on_vision_range_body_exited(body):
	if body is Player:
		target = null
		print("player left")
