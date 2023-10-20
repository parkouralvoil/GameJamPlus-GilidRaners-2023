extends Control

var test_level: Resource = load("res://levels/test_level.tscn")
var enlistment: Resource = load("res://ui/enlistment.tscn")

func _ready():
	SceneManager.menu_open = false

func _on_play_pressed():
	get_tree().change_scene_to_packed(enlistment)


func _on_go_to_test_level_pressed():
	get_tree().change_scene_to_packed(test_level)
