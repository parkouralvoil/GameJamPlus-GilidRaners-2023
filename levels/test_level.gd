extends Node2D

@onready var player: Player = $player
@onready var hud: PlayerHud = $CanvasLayer/player_hud
@onready var lvl_finish: Area2D = $LvlFinish
@onready var game_over: CanvasLayer = $Gameover
@onready var game_over_button: Button = $Gameover/Control/Button


var max_hp: int:
	set(value):
		max_hp = value
		hud.max_hp = max_hp

var hp: int:
	set(value):
		hp = value
		hud.hp = hp

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


func _ready() -> void:
	lvl_finish.connect("body_entered", _on_lvl_finish_body_entered)
	game_over_button.connect("pressed", _on_press_game_over_button)
	set_hud_info()


func _process(_delta: float) -> void:
	if player.hp <= 0 and !game_over.visible:
		game_over.show()
	elif player.hp > 0 and game_over.visible:
		game_over.hide()
	set_hud_info()


func set_hud_info() -> void:
	max_hp = player.max_hp
	hp = player.hp
	
	#if $player != null:
		#if $player/Timer_Coffee.time_left > 0.1:
			#current_buff = "SPEED BOOST"
			#buff_duration = $player/Timer_Coffee.time_left
			#hud.current_buff_label.visible = true
		#elif $player/Timer_UnliAmmo.time_left > 0.1:
			#current_buff = "UNLI AMMO"
			#buff_duration = $player/Timer_UnliAmmo.time_left
			#hud.current_buff_label.visible = true
		#elif $player/Timer_Invul.time_left > 0.1:
			#current_buff = "INVULNERABLE"
			#buff_duration = $player/Timer_Invul.time_left
			#hud.current_buff_label.visible = true
		#else:
			#hud.current_buff_label.visible = false


func _on_lvl_finish_body_entered(body) -> void:
	if body is Player:
		SceneManager.go_transition()


func _on_press_game_over_button() -> void:
	SceneManager.go_main_menu()
