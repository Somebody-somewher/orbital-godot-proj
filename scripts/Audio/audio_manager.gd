extends Node

@onready var bgm_stream: AudioStreamPlayer2D

#next bgm to play in queue for smooth transitions
var next_bgm : String = "random"
#stores time when pausing audio
var bgm_stop :float = 0

var in_game_music = ["plains","forest","desert","mountain", "snow"]

@export var master_volume : float = .5
@export var bgm_volume : float = .3
@export var sfx_volume : float = .5


# for stacking SFX isntances
@export var SFX_AUDIOS : Dictionary[String, AudioData]
@export var sfx_instance_scene: PackedScene

# for controlling volume of alot of stacking sfx
var current_instances = 0
# for seeing if should increase pitch of point sfx
var time_since_point_sfx := 0.0
var no_of_point_sfx := 0

func _ready() -> void:
	Signalbus.connect("add_score", play_point_sfx)

func change_master_volume(value : float) ->void:
	master_volume = value
	if bgm_stream:
		bgm_stream.volume_db = linear_to_db(bgm_volume * master_volume)

func change_sfx_volume(value : float) ->void:
	sfx_volume = value

func change_bgm_volume(value : float) ->void:
	bgm_volume = 0.6 * value
	if bgm_stream:
		bgm_stream.volume_db = linear_to_db(bgm_volume * master_volume)

#stops current bgm and immediately plays new one
func play_bgm(audio_name : String, from_position : float = 0.0) -> void:
	if audio_name == "random":
		audio_name = in_game_music.pick_random()
	if bgm_stream:
		#currently playing requested track
		if bgm_stream.name == audio_name:
			return
		# stop previous
		bgm_stream.stop()
	bgm_stream = get_node("BGM").get_node(audio_name)
	bgm_stream.volume_db = linear_to_db(bgm_volume * master_volume)
	bgm_stream.play(from_position)

func play_sfx(audio_name : String, pitch : float = 1.0, from_position : float = 0.0) -> void:
	var instance : SFXInstance = sfx_instance_scene.instantiate()
	current_instances += 1
	instance.stream = SFX_AUDIOS.get(audio_name).get_default()
	instance.pitch_scale = pitch
	instance.from_position = from_position
	instance.volume_db = linear_to_db(sfx_volume  * master_volume) - current_instances
	instance.finished.connect(func(): current_instances -= 1)
	get_node("SFX").add_child(instance)

func play_point_sfx(_score_to_add : int, player_uuid : String) -> void:
	if PlayerManager.getCurrentPlayerUUID() != player_uuid:
		return
	
	if time_since_point_sfx > 1:
		no_of_point_sfx = 1
	else:
		no_of_point_sfx += 1
		
	var instance : SFXInstance = sfx_instance_scene.instantiate()
	instance.stream = SFX_AUDIOS.get("point").get_default()
	instance.pitch_scale = min((no_of_point_sfx+ 5) * .1, 3)
	instance.volume_db = linear_to_db(sfx_volume  * master_volume)
	instance.finished.connect(func(): current_instances -= 1)
	get_node("SFX").add_child(instance)
	time_since_point_sfx = 0

func _process(delta: float) -> void:
	time_since_point_sfx += delta
	

#queues bmg to play after current loop
func queue_bgm(audio_name : String) -> void:
	next_bgm = audio_name

#signal received that bgm has finished, to start playing new loop
func _on_bgm_finished() -> void:
	bgm_stream = null
	play_bgm(next_bgm)

func stop_bgm() -> void:
	if bgm_stream:
		bgm_stream.stop()
		bgm_stop = bgm_stream.get_playback_position()

func resume_bgm() -> void:
	bgm_stream.play()
	bgm_stream.seek(bgm_stop)
