class_name Room extends Node2D

var enemies_max: int = 0
var enemies_left: int = 0

var room_cleared: bool = false
var doors: Array[StaticBody2D] = []

func _ready():
	for child in get_children():
		if child is Enemy:
			enemies_max += 1
			child.Died.connect(update_enemies_left, CONNECT_ONE_SHOT)
		elif child is StaticBody2D: # door
			doors.append(child)
	enemies_left = enemies_max

func _process(delta):
	pass

func update_enemies_left():
	enemies_left -= 1
	if enemies_left <= 0 and !room_cleared:
		room_cleared = true
		for door in doors:
			door.open_door()
		# room cleared
		# show text above player's head
		# open doors

# need to have test_level 
	# have all rooms call respawn_enemies (rooms where "room_cleared" boolean is false)
	# when player dies

func respawn_enemies():
	for child in get_children():
		if child is Enemy and child.hp <= 0:
			enemies_left += 1
			child.respawn()
			child.Died.connect(update_enemies_left, CONNECT_ONE_SHOT)
			print("respawning: ", child)
