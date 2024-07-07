extends CanvasLayer

## this is the thing that loads games
var menu: PackedScene = load("res://ui/menu.tscn")

var first_lvl: PackedScene = load("res://levels/Lvl 1.tscn")
var second_lvl: PackedScene = load("res://levels/Lvl 2.tscn")

#var transition_screen: Resource = load("res://levels/subjects/transition_vn_screen.tscn")

var winning_screen: PackedScene = load("res://ui/win.tscn")

var level_array: Array[PackedScene] = []
var level: int = 0

var menu_open: bool = false

@onready var control: Control = $Control
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	level_array = [first_lvl, second_lvl]
	control.hide()


func begin_game() -> void:
	level = 0
	print(level_array)
	if level < level_array.size():
		menu_open = false
		get_tree().change_scene_to_packed(level_array[level])


#func go_transition() -> void:
	#menu_open = true
	#get_tree().change_scene_to_packed(transition_screen)


func go_main_menu() -> void:
	menu_open = true
	get_tree().change_scene_to_packed(menu)


func go_next_level() -> void:
	level += 1
	if level < level_array.size():
		get_tree().change_scene_to_packed(level_array[level])
		menu_open = false
	else:
		menu_open = true
		get_tree().change_scene_to_packed(winning_screen)
		# probs best to put here the "go to game finished scene"
