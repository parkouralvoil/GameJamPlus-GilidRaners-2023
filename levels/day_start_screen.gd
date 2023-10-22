extends Node2D

@onready var animation_handler = $AnimationPlayer

@onready var time1 = $screen_control/CenterContainer3/time1
@onready var time_day = $screen_control/CenterContainer2/day_indicator
@onready var time2 = $screen_control/CenterContainer/time2
@onready var time3 = $screen_control/CenterContainer4/time3
@onready var ampm = $screen_control/AM
@onready var xday = $screen_control/x_days

@onready var weekday = $screen_control/weekday

func level_transition(day_num):
	time_day.text = str(day_num)
	time2.text = str(randi_range(0,5))
	time3.text = str(randi_range(0,9))
	
	
	match day_num:
		1:
			xday.text = "3 days until Finals"
			weekday.text = "Monday"
		2:
			xday.text = "2 days until Finals"
			weekday.text = "Tuesday"
		3:
			xday.text = "1 day until Finals"
			weekday.text = "Wednesday"
		4:
			ampm.text = 'PM'
			xday.text = "Finals"
			weekday.text = "Thursday"
		_:
			pass
	start_anim()
	await animation_handler.animation_finished
	#insert scene transition

func start_anim():
	animation_handler.queue("level_start")
