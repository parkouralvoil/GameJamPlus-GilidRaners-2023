extends Label
class_name WordEffectClass

var speed: float = 40

func _ready() -> void:
	var t: Tween = create_tween()
	t.tween_property(self, "modulate", Color(1, 1, 1, 0), 1)
	await t.finished
	queue_free()


func _physics_process(delta: float) -> void:
	global_position.y -= speed * delta
