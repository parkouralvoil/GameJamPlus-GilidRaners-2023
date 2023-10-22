extends Control

var test_level: Resource = load("res://levels/test_level.tscn")
var enlistment: Resource = load("res://ui/enlistment.tscn")

var first_lvl: Resource = load("res://levels/Lvl 1.tscn")
var second_lvl: Resource = load("res://levels/Lvl 2.tscn")

func _ready():
	SceneManager.menu_open = false

func _on_play_pressed():
	get_tree().change_scene_to_packed(first_lvl)
