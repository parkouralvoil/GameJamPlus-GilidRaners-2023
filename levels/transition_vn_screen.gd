extends Node2D

@onready var animation_handler = $AnimationPlayer
@onready var transition_text = $transition_control/CenterContainer3/transition_text

func transition(building: String):
	transition_text.text = building
	start_anim()
	await animation_handler.animation_finished
	#insert scene transition
	
func start_anim():
	animation_handler.queue("transition")
	
