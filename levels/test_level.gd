extends Node2D

@onready var player = $player
@onready var hud = $CanvasLayer/player_hud

var hp: int:
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
	set_hud_info()

func _process(delta):
	set_hud_info()
	
func set_hud_info():
	hp = player.hp
	energy = player.energy
	ammo = player.ammo
	reload_time = player.reload_timer.time_left
	if player.ammo < player.max_ammo and !player.is_firing:
		hud.reload_time.visible = true
	else:
		hud.reload_time.visible = false
