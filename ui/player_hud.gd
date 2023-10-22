extends Control

var max_hp: float = 999.0
var buff_duration: float = 999.0

@onready var hp = $Label_HP:
	set(value):
		hp.text = "HP: %.0f/%.0f" % [value, max_hp]

@onready var energy = $Label_Energy:
	set(value):
		energy.text = "Energy: " + str(value)

@onready var ammo = $Label_Ammo:
	set(value):
		ammo.text = "Ammo: " + str(value)

@onready var reload_time = $Label_Reload:
	set(value):
		reload_time.text = "Reloading: %.1f" % value

@onready var powerup = $Label_Powerup:
	set(value):
		powerup.text = "Power up: %s" % value

@onready var current_buff = $Label_CurrentBuff:
	set(value):
		current_buff.text = "%s for %.1f" % [value, buff_duration]
