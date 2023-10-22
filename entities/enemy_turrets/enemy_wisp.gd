extends Enemy

@onready var hitbox_playerNearby: Area2D = $Area2D_PlayerNearby
@onready var explosion: Area2D = $delayed_aoe
@onready var explosion_line: Line2D = $Line2D

@onready var reload_CD: Timer = $Timer_Reload
@onready var reload_wait_time: float = 3.0
@onready var explosion_line_lifetime: Timer = $Timer_Line
@onready var rotater: Node2D = $Rotator

@onready var RC_player: RayCast2D = $RayCast2D_Player

var ready_to_fire: bool = true
var player_in_sight: bool = false

func _ready():
	max_hp = 30.0
	hp = max_hp
	atk = 10.0
	$Control.global_position = global_position
	explosion_line.points[1] = Vector2.ZERO
	
	$delayed_aoe.visible = false

func _process(delta):
	if hp <= 0:
		die()
		return
	display_hp = hp	

func _physics_process(delta):
	if hp <= 0:
		return
		
	player_vision()
	
	if target != null and ready_to_fire and target.hp > 0 and player_in_sight:
		rotater.look_at(target.global_position)
		$CollisionShape2D.rotation = rotater.rotation
		
		show_line()
		fire_explosion()

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

func player_vision():
	if target != null:
		RC_player.target_position = target.global_position - global_position
		if RC_player.get_collider() == target:
			player_in_sight = true
		else:
			player_in_sight = false
	else:
		player_in_sight = false

func _on_area_2d_player_nearby_body_entered(body):
	if body is Player:
		target = body
		#print("view")


func _on_area_2d_player_nearby_body_exited(body):
	if body is Player:
		target = null
		#print("no")


func _on_timer_reload_timeout():
	ready_to_fire = true


func _on_timer_line_timeout():
	explosion_line.points[1] = Vector2.ZERO

func respawn():
	hp = max_hp
	anim_sprite.visible = true
	display_hp.visible = true
	hitbox.set_deferred("disabled", false)
