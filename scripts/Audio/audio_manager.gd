extends Node2D

@onready var bgm_stream: AudioStreamPlayer2D

#next bgm to play in queue for smooth transitions
var next_bgm : String = "desert"

#does nothing currently
@export var master_volume : float = .5
@export var bgm_volume : float = .3
@export var sfx_volume : float = .5

# for stacking SFX isntances
@export var sfx_instance_scene: PackedScene
@export var SFX_AUDIOS : Dictionary[String, AudioData]
# for controlling volume of alot of stacking sfx
var current_instances = 0

func change_master_volume(value : float) ->void:
	master_volume = value
	if bgm_stream:
		bgm_stream.volume_db = linear_to_db(bgm_volume * master_volume)

func change_bgm_volume(value : float) ->void:
	bgm_volume = 0.6 * value
	if bgm_stream:
		bgm_stream.volume_db = linear_to_db(bgm_volume * master_volume)

#stops current bgm and immediately plays new one
func play_bgm(audio_name : String, from_position : float = 0.0) -> void:
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
	get_node("SFX").add_child(instance)

#queues bmg to play after current loop
func queue_bgm(audio_name : String) -> void:
	next_bgm = audio_name

#signal received that bgm has finished, to start playing new loop
func _on_bgm_finished() -> void:
	bgm_stream = null
	play_bgm(next_bgm)

func stop_bgm() -> void:
	bgm_stream.stop()
