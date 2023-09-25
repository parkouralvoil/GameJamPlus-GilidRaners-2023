extends Enemy

var max_hp: float = 40.0
var hp: float = max_hp
var atk: float = 20.0 

@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var hitbox_playerNearby: Area2D = $Area2D_PlayerNearby
@onready var explosion: Area2D = $delayed_aoe
@onready var explosion_line: Line2D = $Line2D

@onready var reload_CD: Timer = $Timer_Reload
@onready var reload_wait_time: float = 3.0
@onready var explosion_line_lifetime: Timer = $Timer_Line

var target: Player = null

var ready_to_fire: bool = true

# healthbar:
@onready var display_hp = $Control/Label_HP:
	set(value):
		display_hp.text = "{0}/{1}".format([str(value), str(max_hp)])

func _ready():
	$Control.global_position = global_position
	explosion_line.points[1] = Vector2.ZERO

func _process(delta):
	if hp == 0:
		die()
		return
	display_hp = hp	

func _physics_process(delta):
	if target != null and ready_to_fire:
		show_line()
		fire_explosion()


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

func fire_explosion():
	explosion.global_position = target.global_position
	explosion.start_aoe = true
	if reload_CD.is_stopped():
		var rng = RandomNumberGenerator.new()
		reload_CD.start(rng.randf_range(reload_wait_time, reload_wait_time + 2))
	ready_to_fire = false

func show_line():
	explosion_line.points[1] = target.global_position - global_position
	if explosion_line_lifetime.is_stopped():
		explosion_line_lifetime.start()

func _on_area_2d_player_nearby_body_entered(body):
	if body is Player:
		target = body
		print("view")


func _on_area_2d_player_nearby_body_exited(body):
	if body is Player:
		target = null
		print("no")


func _on_timer_reload_timeout():
	ready_to_fire = true


func _on_timer_line_timeout():
	explosion_line.points[1] = Vector2.ZERO
