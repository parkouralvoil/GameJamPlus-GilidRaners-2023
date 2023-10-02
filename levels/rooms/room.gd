extends Node2D

var enemies_max: int = 0
var enemies_left: int = 0

var room_cleared: bool = false

func _ready():
	for child in get_children():
		if child is Enemy:
			enemies_max += 1
			child.Died.connect(update_enemies_left, CONNECT_ONE_SHOT)
	enemies_left = enemies_max

func _process(delta):
	print(enemies_left)

func update_enemies_left():
	enemies_left -= 1
	if enemies_left <= 0:
		room_cleared = true
		# room cleared
		# show text above player's head
		# open doors

# need to have test_level 
	# have all rooms respawn_enemies (whose "room_cleared" boolean is false)
	# when player dies

func respawn_enemies():
	for child in get_children():
		if child is Enemy and child.hp <= 0:
			enemies_left += 1
			child.respawn()
			child.Died.connect(update_enemies_left, CONNECT_ONE_SHOT)
