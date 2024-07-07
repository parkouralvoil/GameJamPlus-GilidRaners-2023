extends Area2D
class_name PowerUps

## this node is queue_freed' by Player's PowerupManager
## sprite is managed by other stuff

enum PowerupType {
	INVINCIBLE, ## kodigo
	SPEED, ## coffee
	HEALTH, ## kwek-kwek
	ATTACK, ## ballpen bundle
}

@export var current_powerup_type: PowerupType

@onready var sprite_parent: Sprite2D = owner

## since the sprites dont have similar sizes
## scuffed scale fixes:
## food.tscn, kwek-kwek too big
## kodego.tscn, kodego too big
