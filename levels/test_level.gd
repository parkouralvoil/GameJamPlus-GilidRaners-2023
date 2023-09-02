extends Node2D

@onready var player = $player
@onready var hud = $player_hud

var energy: int:
	set(value):
		energy = value
		hud.energy = energy

func _ready():
	energy = player.energy
	

func _process(delta):
	energy = player.energy	
