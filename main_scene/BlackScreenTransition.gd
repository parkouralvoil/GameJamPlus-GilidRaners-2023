extends ColorRect
class_name BlackScreenTransition

signal transition_finished

var opaque := Color(0, 0, 0, 1)
var transparent := Color(0, 0, 0, 0)
var transition_duration: float = 0.5

func _ready() -> void:
	hide()


func out_current_scene() -> void:
	show()
	var t: Tween = create_tween()
	t.tween_property(self, "color", opaque, transition_duration).from(transparent)
	await t.finished
	transition_finished.emit()


func in_next_scene() -> void:
	var t: Tween = create_tween()
	t.tween_property(self, "color", transparent, transition_duration).from(opaque)
	await t.finished
	hide()
	transition_finished.emit()
