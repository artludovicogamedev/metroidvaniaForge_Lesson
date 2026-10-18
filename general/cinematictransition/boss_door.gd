
@icon("res://general/icons/door.svg")
class_name BossDoor
extends Node2D

const DOOR_CRASH_AUDIO = preload("uid://csfqkrs6y48sj")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var door_name : String = ""

func _ready() -> void:
	pass

func on_boss_door_closing() -> void : 
	#audio playback
	#play the animation open
	Audio.play_spatial_soundfx(DOOR_CRASH_AUDIO,global_position, 0,-35)
	animation_player.play("closing")
	pass
	
func on_boss_door_closed() -> void :
	#if opened, play the open animation
	animation_player.play("closed")
	pass

func on_boss_door_open() -> void :
	#if opened, play the open animation
	animation_player.play("opening")
	pass
	
#func _get_configuration_warnings() -> PackedStringArray:
	#if check_for_switches() == false :
		#return [ "Door Switch node missing."]
	#return []

#func check_for_switches() -> bool :
	#for c in get_children():
		#if c is DoorSwitch :
			#return true
	#return false
