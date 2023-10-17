extends Control

var enlistment = load("res://ui/enlistment.tscn")

func _on_play_pressed():
	get_tree().change_scene_to_packed(enlistment)
