extends Node2D

const test_level_1: PackedScene = preload("res://levels/lvls/test_lvl.tscn")
const test_level_2: PackedScene = preload("res://levels/lvls/test_lvl_2.tscn")

var tracked_level: PackedScene

@onready var current_level: Level# = $TestLevel
@onready var current_screen: CanvasLayer
@onready var player: Player

@onready var camera: Camera2D = $LevelCamera
@onready var hud: PlayerHud = $PlayerHud

@onready var game_over_screen: GameOverScreen = $Gameover
@onready var win_screen: WinScreen = $Win
@onready var menu_screen: MainMenu = $Menu

@onready var black_screen: BlackScreenTransition = $CanvasLayer/BlackScreenTransition

func _ready() -> void:
	current_screen = menu_screen
	
	menu_screen.pressed_play.connect(begin_game)
	game_over_screen.restart_pressed.connect(reset_scene)
	win_screen.menu_pressed.connect(show_menu)
	
	if current_level: ## testing
		current_level.level_exit_reached.connect(_go_next_level) ## HACK
		_start_level()
		menu_screen.hide()
	else: ## show menu
		menu_screen.show()


func _process(_delta: float) -> void:
	if not player:
		return
	
	camera.global_position = player.global_position
	


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		reset_scene()


func reset_scene() -> void:
	black_screen.out_current_scene()
	await black_screen.transition_finished
	player = null
	current_screen.hide()
	
	if current_level:
		current_level.queue_free()
		await current_level.tree_exited
	
	if tracked_level: ## theres still a next level
		add_level_to_tree()
		black_screen.in_next_scene()
	else: ## win screen -> main menu
		show_win_screen()
		black_screen.in_next_scene()

func add_level_to_tree() -> void:
	current_level = test_level_1.instantiate() ## WEIRDNESS
	add_child(current_level)
	current_level.level_exit_reached.connect(_go_next_level)
	
	if current_level.p:
		_start_level()


func _start_level() -> void:
	player = current_level.p
	player.player_died.connect(show_game_over)
	hud.p = player
	game_over_screen.hide()
	GlobalInfo.player_can_move = true


func _go_next_level() -> void:
	match tracked_level:
		test_level_1:
			tracked_level = null
			current_level = null
	player = null
	hud.hide()
	GlobalInfo.player_can_move = false
	reset_scene()


func begin_game() -> void:
	tracked_level = test_level_1
	reset_scene()


func show_game_over() -> void:
	await get_tree().create_timer(0.75).timeout
	game_over_screen.show()


func show_win_screen() -> void:
	win_screen.show()
	menu_screen.hide()


func show_menu() -> void:
	black_screen.out_current_scene()
	await black_screen.transition_finished
	game_over_screen.hide()
	win_screen.hide()
	menu_screen.show()
	black_screen.in_next_scene()
