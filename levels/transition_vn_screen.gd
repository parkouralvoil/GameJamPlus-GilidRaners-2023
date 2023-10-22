extends Node2D

@onready var animation_handler = $AnimationPlayer
@onready var transition_text = $transition_control/CenterContainer3/transition_text

func _ready():
	if SceneManager.level == 0:
		transition("Math Building")
	elif SceneManager.level == 1:
		transition("Oh, end of class")

func transition(building: String):
	transition_text.text = building
	start_anim()
	await animation_handler.animation_finished
	SceneManager.go_next_level()
	
func start_anim():
	animation_handler.queue("transition")
	
