extends Node2D

@onready var player: Player = $player
@onready var camera: Camera2D = $level_camera
@onready var hud: Control = $CanvasLayer/player_hud
@onready var lvl_finish: Area2D = $LvlFinish
@onready var game_over: CanvasLayer = $Gameover
@onready var game_over_button: Button = $Gameover/Control/Button
@onready var rooms: Node2D = $rooms

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

func _ready():
	game_over.hide()
#	player.PlayerRespawned.connect(room_respawn) # UNCOMMENT THIS HEN ROOM IS ADDED
	lvl_finish.connect("body_entered", _on_lvl_finish_body_entered)
	game_over_button.connect("pressed", _on_press_game_over_button)
	set_hud_info()
	
	# sets the first respawn point
#	for child in respawn_points.get_children():
#		if child.first_campfire:
#			player.respawn_point = child.global_position
#			child.campfire_lit()
#			break

func _process(delta):
	set_hud_info()
	

func _physics_process(delta):
	if player.hp <= 0 and !game_over.visible:
		game_over.show()
	elif player.hp > 0 and game_over.visible:
		game_over.hide()
	
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

#func room_respawn():
#	for child in rooms.get_children():
#		if child is Room and !child.room_cleared:
#			child.respawn_enemies()
#	print("doing this")

func _on_lvl_finish_body_entered(body):
	if body is Player:
		SceneManager.go_next_level()

func _on_press_game_over_button():
	room_respawn()
	player.respawn_player()

func room_respawn():
	for child in rooms.get_children():
		if child is Room:
			child.respawn_enemies()
