extends CanvasLayer
class_name PlayerHud

@export var p: Player

var max_hp: int = 99
var buff_duration: float = 999.0

@onready var hp_label: Label = $Control/VBoxContainer/Label_HP
@onready var powerup_label: Label = $Control/VBoxContainer/Label_Powerup
@onready var current_buff_label: Label = $Control/VBoxContainer/Label_CurrentBuff

@onready var hp: int:
	set(value):
		hp_label.text = "HP: %d/%d" % [value, max_hp]

@onready var powerup: String:
	set(value):
		powerup_label.text = "%s" % value

@onready var current_buff: String:
	set(value):
		current_buff_label.text = "%s for %.1f" % [value, buff_duration]
