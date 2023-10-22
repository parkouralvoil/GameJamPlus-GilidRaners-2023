extends Sprite2D
var active_hitbox: bool = true


func _on_area_2d_body_entered(body):
	if body is Player and active_hitbox:
		var player = body
		if player.inventory == 0:
			player.getHealth()
			queue_free()
