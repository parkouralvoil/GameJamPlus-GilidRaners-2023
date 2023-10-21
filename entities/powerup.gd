extends Sprite2D
var active_hitbox: bool = true


func _on_area_2d_body_entered(body):
	print("amogus")
	if body is Player and active_hitbox:
		var player = body
		if player.inventory == 0:
			player.getKodigo()
			queue_free()
