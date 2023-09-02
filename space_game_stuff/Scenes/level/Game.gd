extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var EnemyTurret = $EnemyTurret

@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var game_over_screen = $UI/GameOverScreen
@onready var player_spawn_pos = $PlayerSpawnPos
@onready var player_spawn_area = $PlayerSpawnPos/PlayerSpawnArea

var asteroid_scene = preload("res://space_game_stuff/Scenes/asteroids/asteroid.tscn")

var score: int:
	set(value):
		score = value
		hud.score = score
		
var lives: int:
	set(value):
		lives = value
		hud.init_lives(lives)

func _ready():
	game_over_screen.visible = false
	score = 0
	lives = 3
	player.connect("laser_shot", _on_player_laser_shot)
	player.connect("died", _on_player_died)
	
	EnemyTurret.connect('enemy_laser_shot', _on_enemy_laser_shot)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)
	
func _process(delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	
	
func _on_player_laser_shot(laser):
	$LaserSound.play()
	lasers.add_child(laser)
	
func _on_enemy_laser_shot(laser):
	$LaserSound.play()
	lasers.add_child(laser)
	
	
func _on_asteroid_exploded(pos, size, points):
	score += points
	#print(score)
	for i in range(2):
		match size:
			Asteroid.AsteroidSize.LARGE:
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				pass
	
func spawn_asteroid(pos, size):
	var a = asteroid_scene.instantiate() #NOT INSTANTIATED !!!
	a.global_position = pos
	a.size = size
	a.connect("exploded", _on_asteroid_exploded)
	#asteroids.add_child(a)
	asteroids.call_deferred("add_child", a)
	# what is "call_deferred": it calls the method when the node isn't "busy", 
	# i.e. during idle times when calculations and other things aren't 
	# being thrown around. When the parts of the node aren't being removed 
	# from RAM via queue_free(), it'll execute the code add_child() on the parent node.
		
func _on_player_died():
	lives -= 1
	$PlayerDieSound.play()
	#print(lives)
	player.global_position = player_spawn_pos.global_position
	if lives <= 0:
		game_over_screen.visible = true
	else:
		await get_tree().create_timer(1).timeout
		while !player_spawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout

		player.respawn(player_spawn_pos.global_position)
