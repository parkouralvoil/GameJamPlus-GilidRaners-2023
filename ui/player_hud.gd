extends CanvasLayer
class_name PlayerHud

var max_hp: int = 99
var buff_duration: float = 999.0

var buff_dur_info: BuffDurationResource = load("res://resources/stats/buff_duration_info.tres")
var p: Player = null: ## given by Main.gd
	set(val):
		p = val
		if p:
			show() ## show hud
		else:
			hide()

@onready var healtbar: TextureProgressBar = $Control/HeartHealthbar
@onready var coffee_bar: PowerupBarControl = $Control/HBoxContainer/CoffeeDurationBar
@onready var pen_bar: PowerupBarControl = $Control/HBoxContainer/PenbundleDurationBar
@onready var invul_bar: PowerupBarControl = $Control/HBoxContainer/InvulnerableDurationBar

@onready var hp: int:
	set(value):
		healtbar.value = value
		hp = value


func _ready() -> void:
	invul_bar.max_duration = buff_dur_info.MAX_DUR_INVULNERABLE
	pen_bar.max_duration = buff_dur_info.MAX_DUR_PENBUNDLE
	coffee_bar.max_duration = buff_dur_info.MAX_DUR_COFFEE


func _physics_process(_delta: float) -> void:
	if not p:
		return
	
	hp = p.hp
	max_hp = p.max_hp
	
	invul_bar.duration = buff_dur_info.dur_invulnerable
	pen_bar.duration = buff_dur_info.dur_penbundle
	coffee_bar.duration = buff_dur_info.dur_coffee
