extends Area2D

## put effects of powerups here
	## circle healthbar to indicate duration

## STACKING BUFFS, dedicated timer, has stack count, each new stack refreshes timer
## coffee buff

## REFRESHING BUFFS, has dedicated timer, has icon
## attack buff
## invulnerability buff

const WordEffectPath: PackedScene = preload("res://ui/word_effect/word_effect.tscn")

@export var p: Player

## SET THE (duration) OF THE BUFFS IN THE BuffDurationResouce here
var buff_dur_info: BuffDurationResource = load("res://resources/stats/buff_duration_info.tres")
var cofee_speed_buff: float = 100
var coffee_stacks: int = 0
var effect_pos: Vector2

@onready var duration_invul: Timer = $Invulnerability
@onready var duration_atk: Timer = $Attack
@onready var duration_coffee: Timer = $Coffee

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	assert(p, "PowerupManager: Missing export to player")
	duration_coffee.wait_time = buff_dur_info.MAX_DUR_COFFEE
	duration_atk.wait_time = buff_dur_info.MAX_DUR_PENBUNDLE
	duration_invul.wait_time = buff_dur_info.MAX_DUR_INVULNERABLE


func _process(_delta: float) -> void:
	if not p:
		return
	buff_dur_info.dur_invulnerable = duration_invul.time_left
	buff_dur_info.dur_penbundle = duration_atk.time_left
	buff_dur_info.dur_coffee = duration_coffee.time_left


func _on_area_entered(area: Area2D) -> void:
	if not(area is PowerUps):
		return
	
	var up: PowerUps = area
	effect_pos = up.global_position
	match up.current_powerup_type:
		up.PowerupType.INVINCIBLE:
			p.invul = true
			duration_invul.start()
			_spawn_word_effect("Invincible!")
		
		up.PowerupType.ATTACK:
			p.triple_atk = true
			duration_atk.start()
			_spawn_word_effect("Triple shot!")
		
		up.PowerupType.SPEED:
			_coffee_stack()
			duration_coffee.start()
			_spawn_word_effect("Coffee x%d" % coffee_stacks)
		
		up.PowerupType.HEALTH:
			p.healConsummable()
			_spawn_word_effect("Heal HP")
	
	up.sprite_parent.queue_free() ## remove the sprite, which has the parent of area
	## if player dies, just reload the scene rather than making a respawn mechanic for
	## enemy and powerups
	## only the player truly respawns


func _coffee_stack() -> void:
	coffee_stacks += 1
	p.speedModifier = cofee_speed_buff + ((cofee_speed_buff) * coffee_stacks - 1)


func _spawn_word_effect(effect_string: String) -> void:
	var inst: WordEffectClass = WordEffectPath.instantiate()
	
	inst.text = effect_string
	inst.global_position = effect_pos + Vector2(-20, -30)
	
	get_tree().root.add_child(inst)


func _on_invulnerability_timeout() -> void:
	p.invul = false


func _on_attack_timeout() -> void:
	p.triple_atk = false


func _on_coffee_timeout() -> void:
	p.speedModifier = 0
	coffee_stacks = 0
