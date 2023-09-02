extends Control

@onready var energy = $EnergyLabel:
	set(value):
		energy.text = "Energy: " + str(value)
