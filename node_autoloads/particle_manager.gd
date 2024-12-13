extends Node

var hit_index: int = 0
var hit_queue_size: int = 0


@onready var hit_queue: Node = $HitEffectQueue


func _ready() -> void:
	for p in hit_queue.get_children():
		if p is GPUParticles2D:
			hit_queue_size += 1
	

func hit_trigger(target_pos: Vector2) -> void:
	var particle: GPUParticles2D = hit_queue.get_child(hit_index)
	hit_index = (hit_index + 1) % hit_queue_size
	
	particle.global_position = target_pos
	particle.restart()
