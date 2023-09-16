extends Enemy

var max_hp: float = 20.0
var hp: float = max_hp
var atk: float = 5.0

@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var reload_CD: Timer = $Timer_Reload
@onready var laser_duration: Timer = $Timer_LaserDuration

@onready var hitbox_playerNearby: Area2D = $Area2D_PlayerNearby

@onready var laser_up: RayCast2D = $laser_collection/laser_up
@onready var laser_down: RayCast2D = $laser_collection/laser_down
@onready var laser_left: RayCast2D = $laser_collection/laser_left
@onready var laser_right: RayCast2D = $laser_collection/laser_right

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

func _process(delta):
	if hp == 0:
		die()
		return
	display_hp = hp	

func _physics_process(delta):
	if reload_CD.is_stopped() and laser_duration.is_stopped():
		reload_CD.start()


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


func _on_timer_reload_timeout():
	laser_activation(true)
	laser_duration.start()
	print("reloaded")

func _on_timer_laser_lifespan_timeout():
	laser_activation(false)
	print("laser out")

func laser_activation(input: bool):
	laser_up.is_casting = input
	laser_down.is_casting = input
	laser_left.is_casting = input
	laser_right.is_casting = input
