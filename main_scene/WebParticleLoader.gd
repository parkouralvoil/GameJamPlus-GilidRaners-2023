extends Node2D

## this is necessary to make the web export not lag when particles first play


@onready var p1: GPUParticles2D = $HitParticles
@onready var p2: GPUParticles2D = $PlayerJumpParticles
@onready var p3: GPUParticles2D = $CastingParticles
@onready var p4: GPUParticles2D = $CollisionParticles


func _ready() -> void:
	p1.one_shot = true
	p2.one_shot = true
	p3.one_shot = true
	p4.one_shot = true
	p1.restart()
	p2.restart()
	p3.restart()
	p4.restart()
