extends Area2D

@export var speed := 1200.0

var movement_vector := Vector2(0, -1)

func _physics_process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited():
	#print("laser down")
	queue_free()


func _on_body_entered(body):
	if body is Player:
		var player = body
		player.damage(10)
		queue_free()
