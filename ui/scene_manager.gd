extends CanvasLayer

# this is the thing that loads games

# Building A
var path_major1: Resource = load("res://levels/subjects/major_1.tscn")
var path_ge1: Resource = load("res://levels/subjects/GE_1.tscn")

# Building B
var path_major2: Resource = load("res://levels/subjects/major_2.tscn")
var path_ge2: Resource= load("res://levels/subjects/GE_2.tscn")

# Transition Lvl
var path_transition_AB: Resource = load("res://levels/subjects/transitionAB.tscn")
var path_transition_BA = load("res://levels/subjects/transitionAB.tscn") # CHANGE THIS

var menu: Resource = load("res://ui/menu.tscn")

var first_lvl: Resource = load("res://levels/Lvl 1.tscn")
var second_lvl: Resource = load("res://levels/Lvl 2.tscn")

var transition_screen: Resource = load("res://levels/subjects/transition_vn_screen.tscn")

var winning_screen: Resource = load("res://ui/win.tscn")

@onready var control: Control = $Control
#@onready var background: ColorRect = $Control/ColorRect
#@onready var label: Label = $Control/Label
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var level_array: Array[Resource] = []
var level: int = 0

var menu_open: bool = false

# get_tree().change_scene_to_packed(path_major1)

func _ready():
	level_array = [first_lvl, second_lvl]
	control.hide()

func begin_game():
	level = 0
#	insert_transition_lvls()
	print(level_array)
	if level < level_array.size():
		menu_open = false
		get_tree().change_scene_to_packed(level_array[level])
	
func go_transition():
	menu_open = true
	get_tree().change_scene_to_packed(transition_screen)

func go_main_menu():
	menu_open = true
	get_tree().change_scene_to_packed(menu)

func go_next_level():
	level += 1
	if level < level_array.size():
		get_tree().change_scene_to_packed(level_array[level])
		menu_open = false
	else:
		menu_open = true
		get_tree().change_scene_to_packed(winning_screen)
		# probs best to put here the "go to game finished scene"

#func insert_transition_lvls():
#	var i: int = 0
#	while i <= 3:
#		if level_array[i] == path_major1 or level_array[i] == path_ge1:
#			if level_array[i+1] == path_major2 or level_array[i+1] == path_ge2:
#				level_array.insert(i+2, path_transition_AB)
#		elif level_array[i+1] == path_major1 or level_array[i+1] == path_ge1:
#			if level_array[i] == path_major2 or level_array[i] == path_ge2:
#				level_array.insert(i+2, path_transition_BA)
#		i += 3
