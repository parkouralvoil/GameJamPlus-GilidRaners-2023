extends Node2D

const test_level_1: PackedScene = preload("res://levels/lvls/test_lvl.tscn")
const test_level_2: PackedScene = preload("res://levels/lvls/test_lvl_2.tscn")

const lvl_1: PackedScene = preload("res://levels/lvls/lvl_1.tscn")
const lvl_2: PackedScene = preload("res://levels/lvls/lvl_2.tscn")
const lvl_3: PackedScene = preload("res://levels/lvls/lvl_3.tscn")
const lvl_4: PackedScene = preload("res://levels/lvls/lvl_4.tscn")
const lvl_5: PackedScene = preload("res://levels/lvls/lvl_5.tscn")

var tracked_level: PackedScene:
	set(scene):
		tracked_level = scene

@onready var current_level: Level # = $TestLevel
@onready var player: Player

@onready var camera: Camera2D = $Camera
@onready var hud: PlayerHud = $PlayerHud

@onready var game_over_screen: GameOverScreen = $Gameover
@onready var win_screen: WinScreen = $Win
@onready var menu_screen: MainMenu = $Menu
@onready var select_level_screen: SelectLevelMenu = $SelectLevel

@onready var black_screen: BlackScreenTransition = $CanvasLayer/BlackScreenTransition
@onready var pause_menu: PauseMenuScreen = $PauseMenu
@onready var options_menu: OptionsMenuScreen = $OptionsMenu

## Explanation:
## ALL entries to the levels always begins at fxn "begin_game"
## begin_game calls reset_scene, which removes current level and gets the next scene

## _next_lvl_or_end does either
## 1. go next level
## 2. end the game (either win screen or straigth to menu if u didnt beat last lvl)


func _ready() -> void:
	menu_screen.pressed_play.connect(begin_game.bind(lvl_1))
	menu_screen.pressed_select_level.connect(show_select_level_menu)
	menu_screen.pressed_options.connect(show_options_menu)
	
	select_level_screen.selected_lvl_1.connect(begin_game.bind(lvl_1))
	select_level_screen.selected_lvl_2.connect(begin_game.bind(lvl_2))
	select_level_screen.selected_lvl_3.connect(begin_game.bind(lvl_3))
	select_level_screen.selected_lvl_4.connect(begin_game.bind(lvl_4))
	select_level_screen.selected_lvl_5.connect(begin_game.bind(lvl_5))
	
	game_over_screen.restart_pressed.connect(reset_scene)
	win_screen.menu_pressed.connect(show_menu)
	
	pause_menu.can_pause = false
	pause_menu.pressed_options.connect(show_options_menu)
	pause_menu.pressed_return_to_menu.connect(chose_to_leave)
	pause_menu.hide_options.connect(hide_option_screen)

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
	_hide_UI_screens()
	
	if current_level:
		current_level.queue_free()
		await current_level.tree_exited
		call_deferred("_next_lvl_or_end")
	else:
		_next_lvl_or_end()

func _next_lvl_or_end() -> void:
	if tracked_level: ## theres still a next level
		_add_level_to_tree()
		pause_menu.can_pause = true
	else: ## win screen -> main menu
		current_level = null
		pause_menu.can_pause = false
		show_win_screen()
		
	black_screen.in_next_scene()
	_change_music()

func _add_level_to_tree() -> void:
	current_level = tracked_level.instantiate() ## WEIRDNESS
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
		lvl_1:
			tracked_level = lvl_2
		lvl_2:
			tracked_level = lvl_3
		lvl_3:
			tracked_level = lvl_4
		lvl_4:
			tracked_level = lvl_5
		lvl_5:
			tracked_level = null
	hud.hide()
	GlobalInfo.player_can_move = false
	reset_scene()

#region Menu stuff:
func begin_game(_lvl: PackedScene) -> void:
	tracked_level = _lvl
	reset_scene()

func show_select_level_menu() -> void:
	select_level_screen.show()
#endregion


func show_game_over() -> void:
	await get_tree().create_timer(0.75).timeout
	game_over_screen.show()
	pause_menu.can_pause = false


func show_win_screen() -> void:
	SoundManager.play_victory_sfx()
	win_screen.show()
	pause_menu.can_pause = false
	menu_screen.hide()


func show_menu() -> void:
	black_screen.out_current_scene()
	await black_screen.transition_finished
	game_over_screen.hide()
	win_screen.hide()
	menu_screen.show()
	black_screen.in_next_scene()


func show_options_menu() -> void:
	options_menu.show()


func chose_to_leave() -> void: ## left through pause menu
	tracked_level = null
	hud.p = null
	pause_menu.hide()
	black_screen.out_current_scene()
	await black_screen.transition_finished
	get_tree().paused = false
	player = null
	
	current_level.queue_free()
	await current_level.tree_exited
	current_level = null
	pause_menu.can_pause = false
	_change_music()
	show_menu()


func hide_option_screen() -> void:
	options_menu.hide()


func _hide_UI_screens() -> void:
	menu_screen.hide()
	select_level_screen.hide()


func _change_music() -> void:
	match tracked_level:
		lvl_1:
			SoundManager.play_music(1)
		lvl_2:
			SoundManager.play_music(1)
		lvl_3:
			SoundManager.play_music(1)
		lvl_4:
			SoundManager.play_music(1)
		lvl_5:
			SoundManager.play_music(2)
		_:
			SoundManager.play_music(0)
