extends Control


func _on_play_pressed():
	get_tree().change_scene_to_file("res://levels/test_level.tscn")
