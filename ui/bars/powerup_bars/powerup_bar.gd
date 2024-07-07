extends Control
class_name PowerupBarControl


@onready var bar: TextureProgressBar = $CircularGreenBar

@onready var max_duration: float = 10:
	set(new_max_dur):
		max_duration = new_max_dur
		bar.max_value = max_duration

@onready var duration: float = 0:
	set(new_dur):
		duration = new_dur
		bar.value = duration
		if new_dur == 0:
			hide()
		else:
			show()
