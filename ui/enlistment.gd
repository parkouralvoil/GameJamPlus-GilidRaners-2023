extends Control

@onready var buttons_holder1 := $MarginContainer/VBoxContainer/HBoxContainer_Buttons/VBoxContainer_1

# Building A
var path_major1: Resource = SceneManager.path_major1 	# math 21
var path_ge1: Resource = SceneManager.path_ge1 			# speech 2

# Building B
var path_major2: Resource = SceneManager.path_major2 	# Geol 1
var path_ge2: Resource = SceneManager.path_ge2 			# Chem 13


# theres gonna be a scene loader autoload ( i have to make dat pa)
func _ready():
	for child in buttons_holder1.get_children():
		pass


func _on_schedule_1_pressed():
	SceneManager.level_array = [path_major1, path_ge1, path_major1, path_major2, path_major1, path_ge1]
	SceneManager.begin_game()

func _on_schedule_2_pressed():
	SceneManager.level_array = [path_major2, path_ge1, path_major1, path_ge2, path_major2, path_ge1]
	SceneManager.begin_game()

func _on_schedule_3_pressed():
	SceneManager.level_array = [path_ge1, path_major1, path_major2, path_ge2, path_ge1, path_major2]
	SceneManager.begin_game()
