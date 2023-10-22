extends Node2D

@onready var player: Player = $player
@onready var camera: Camera2D = $level_camera
@onready var hud: Control = $CanvasLayer/player_hud
@onready var rooms: Node2D = $rooms
@onready var respawn_points: Node2D = $respawn_points


var max_hp: float:
	set(value):
		max_hp = value
		hud.max_hp = max_hp

var hp: float:
	set(value):
		hp = value
		hud.hp = hp

var energy: int:
	set(value):
		energy = value
		hud.energy = energy

var ammo: int:
	set(value):
		ammo = value
		hud.ammo = ammo
		
var reload_time: float:
	set(value):
		reload_time = value
		hud.reload_time = reload_time
		
var powerup: String:
	set(value):
		powerup = value
		hud.powerup = powerup

var current_buff: String:
	set(value):
		current_buff = value
		hud.current_buff = current_buff
		
var buff_duration: float:
	set(value):
		buff_duration = value
		hud.buff_duration = buff_duration

func _ready():
	player.PlayerRespawned.connect(room_respawn)
	#camera.player = player
	set_hud_info()
	
	# sets the first respawn point
	for child in respawn_points.get_children():
		if child.first_campfire:
			player.respawn_point = child.global_position
			child.campfire_lit()
			break

func _process(delta):
	set_hud_info()
	
func set_hud_info():
	max_hp = player.max_hp
	hp = player.hp
	energy = player.energy
	ammo = player.ammo
	reload_time = player.reload_timer.time_left
	if (player.ammo < player.max_ammo 
	and !player.is_firing 
	and 0 < reload_time 
	and reload_time < 1.5):
		hud.reload_time.visible = true
	else:
		hud.reload_time.visible = false
	#enum Powerup {none = 0, ballpenBundle = 1, coffee = 2, kwekkwek = 3, kodigo = 4}
	match player.inventory:
		player.Powerup.none:
			powerup = "None"
		player.Powerup.ballpenBundle:
			powerup = "Unli ballpens!"
		player.Powerup.coffee:
			powerup = "Speedboost Coffee"
		player.Powerup.kwekkwek:
			powerup = "Healing Kwek kwek"
		player.Powerup.kodigo:
			powerup = "Invulnerability Kodego"
	
	if $player != null:
		if $player/Timer_Coffee.time_left > 0.1:
			current_buff = "SPEED BOOST"
			buff_duration = $player/Timer_Coffee.time_left
			hud.current_buff.visible = true
		elif $player/Timer_UnliAmmo.time_left > 0.1:
			current_buff = "UNLI AMMO"
			buff_duration = $player/Timer_UnliAmmo.time_left
			hud.current_buff.visible = true
		elif $player/Timer_Invul.time_left > 0.1:
			current_buff = "INVULNERABLE"
			buff_duration = $player/Timer_Invul.time_left
			hud.current_buff.visible = true
		else:
			hud.current_buff.visible = false
			

func room_respawn():
	for child in rooms.get_children():
		if child is Room and !child.room_cleared:
			child.respawn_enemies()
	print("doing this")
