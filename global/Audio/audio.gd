extends Node

enum REVERB_TYPE { none, small , medium , large}

@export var ui_focus_audio : AudioStream
@export var ui_select_audio : AudioStream
@export var ui_cancel_audio : AudioStream
@export var ui_success_audio : AudioStream
@export var ui_error_audio : AudioStream

var current_track : int = 0
var music_tweens : Array [Tween]
var ui_audio_player : AudioStreamPlaybackPolyphonic

@onready var music_1: AudioStreamPlayer = %Music1
@onready var music_2: AudioStreamPlayer = %Music2
@onready var ui: AudioStreamPlayer = %UI

func _ready() -> void:
	ui.play()
	ui_audio_player = ui.get_stream_playback()
	pass

func play_audio_stream( audio : AudioStream ) -> void :
	if audio == null:
		return
	if ui_audio_player:
		ui_audio_player.play_stream(audio)
	pass

#region ui functions 
func ui_focus_changed()->void :
	play_audio_stream(ui_focus_audio)
	pass
	
func ui_select()->void :
	play_audio_stream(ui_select_audio)
	pass
	
func ui_focus()->void :
	play_audio_stream(ui_success_audio)
	pass
	
func ui_cancel()->void :
	play_audio_stream(ui_cancel_audio)
	pass

func ui_success()->void :
	play_audio_stream(ui_success_audio)
	pass

func ui_error()->void :
	play_audio_stream(ui_error_audio)
	pass
#endregion

func setup_audio_buttons( node : Node) -> void :
	for c in node.find_children("*" ,"Button") : 
		c.pressed.connect(ui_select)
		c.focus_entered.connect(ui_focus_changed)
	pass

func play_music(audio : AudioStream) -> void :
	#get current player 
	var currentplayer : AudioStreamPlayer = get_music_player(current_track)
	if currentplayer.stream == audio :
		return
	
	#next track 
	var next_track_idx : int = wrapi(current_track + 1,0 ,2)
	var next_music_player : AudioStreamPlayer = get_music_player(next_track_idx)
	
	next_music_player.stream = audio
	next_music_player.play()
	
	for t in music_tweens :
		t.kill()
	
	music_tweens.clear()
	#store/set music track
	fade_out(currentplayer)
	fade_in(next_music_player)
	
	current_track = next_track_idx
	pass

func set_reverb ( revtype : REVERB_TYPE) -> void :
	var revfx : AudioEffectReverb = AudioServer.get_bus_effect(1,0)
	
	if not revfx :
		return
		
	AudioServer.set_bus_effect_enabled(1,0,true)
	match revtype :
		REVERB_TYPE.none:
			AudioServer.set_bus_effect_enabled(1,0,false)
			
		REVERB_TYPE.small:
			AudioServer.set_bus_effect_enabled(1,0,true)
			revfx.room_size = 0.28
			#revfx.damping = 0.65
			#revfx.spread = 0.5
			#revfx.hipass = 0.1
			#revfx.dry = 1.0
			#revfx.wet = 0.2
		REVERB_TYPE.medium:
			AudioServer.set_bus_effect_enabled(1,0,true)
			revfx.room_size = 0.6
			#revfx.damping = 0.7
			#revfx.spread = 0.7
			#revfx.hipass = 0.2
			#revfx.dry = 1.0
			#revfx.wet = 0.4
			
		REVERB_TYPE.large:
			AudioServer.set_bus_effect_enabled(1,0,true)
			revfx.room_size = 0.8
			#revfx.damping = 0.7
			#revfx.spread = 0.7
			#revfx.hipass = 0.2
			#revfx.dry = 1.0
			#revfx.wet = 1.0
	pass

func get_music_player( i : int) -> AudioStreamPlayer :
	if i == 0 :
		return music_1
	else :
		return music_2
		
func fade_in ( player : AudioStreamPlayer ) -> void :
	var tween : Tween = create_tween()
	music_tweens.append(tween)
	tween.tween_property(player, "volume_linear" , 1.0 , 1.0)
	pass
	
func fade_out ( player : AudioStreamPlayer ) -> void :
	var tween : Tween = create_tween()
	music_tweens.append(tween)
	tween.tween_property(player, "volume_linear" , 0.0 , 1.2)
	tween.tween_callback(player.stop)
	pass

func play_spatial_soundfx(audio : AudioStream , pos : Vector2 , roomsize : float = 0.0 , vo : float = 0.0 ) ->void: 
	var ap : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	add_child(ap)
	
	var revfx : AudioEffectReverb = AudioServer.get_bus_effect(1,0)
	AudioServer.set_bus_effect_enabled(1,0,true)
	
	ap.bus = "SFX"
	revfx.room_size = roomsize #override sfx reverb
	ap.global_position = pos
	ap.volume_db = vo # override volume here
	ap.stream = audio
	ap.finished.connect(ap.queue_free)
	ap.play()
	pass
