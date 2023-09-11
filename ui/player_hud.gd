extends Control


@onready var hp = $Label_HP:
	set(value):
		hp.text = "HP: " + str(value)

@onready var energy = $Label_Energy:
	set(value):
		energy.text = "Energy: " + str(value)

@onready var ammo = $Label_Ammo:
	set(value):
		ammo.text = "Ammo: " + str(value)

@onready var reload_time = $Label_Reload:
	set(value):
		reload_time.text = "Reloading: %.1f" % value
