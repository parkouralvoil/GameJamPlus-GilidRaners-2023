extends Node

const KobaltLvl_1: AudioStream = preload("res://resources/music/KOBALT_Lvl_1_Theme.wav")
const KobaltLvl_2: AudioStream = preload("res://resources/music/KOBALT_Lvl_2_Theme.wav")
const SampLofi: AudioStream = preload("res://resources/music/samp_lofi.wav")

enum MusicType {
	LOBBY, ## 0
	EASY, ## 1
	HARD, ## 2
}

var last_music: MusicType

@onready var asp_music: AudioStreamPlayer = $MusicPlayer

@onready var asp_enemy_ouch: AudioStreamPlayer2D = $PosSFX/EnemyOuch
@onready var asp_handexplosion: AudioStreamPlayer2D = $PosSFX/HandExplosion

@onready var asp_arrow: AudioStreamPlayer = $NonPosSFX/Arrow
@onready var asp_powerup: AudioStreamPlayer = $NonPosSFX/PowerUp
@onready var asp_playerhit: AudioStreamPlayer = $NonPosSFX/PlayerHit
@onready var asp_victory: AudioStreamPlayer = $NonPosSFX/Victory
@onready var asp_dash: AudioStreamPlayer = $NonPosSFX/Dash

func _ready() -> void:
	last_music = MusicType.LOBBY
	asp_music.stream = SampLofi
	asp_music.play()


func play_music(chosen_music_type: MusicType) -> void:
	if chosen_music_type == last_music:
		return
	var curr_vol: float = asp_music.volume_db
	match chosen_music_type:
		MusicType.LOBBY:
			asp_music.stream = SampLofi
			asp_music.volume_db = curr_vol + 6
		MusicType.EASY:
			asp_music.stream = KobaltLvl_1
			asp_music.volume_db = curr_vol - 5
		MusicType.HARD:
			asp_music.stream = KobaltLvl_2
			asp_music.volume_db = curr_vol - 5
	
	last_music = chosen_music_type
	asp_music.play()


func play_arrow_sfx() -> void:
	asp_arrow.play()
func play_powerup_sfx() -> void:
	asp_powerup.play()
func play_playerhit_sfx() -> void:
	asp_playerhit.play()
func play_victory_sfx() -> void:
	asp_victory.play()
func play_dash_sfx() -> void:
	asp_dash.play()

func play_enemy_ouch(pos: Vector2) -> void:
	asp_enemy_ouch.global_position = pos
	asp_enemy_ouch.play()

func play_hand_explosion(pos: Vector2) -> void:
	asp_handexplosion.global_position = pos
	asp_handexplosion.play()
