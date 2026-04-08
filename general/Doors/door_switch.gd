@icon("res://general/icons/switch.svg")
class_name DoorSwitch
extends Node2D

const DOOR_SWITCH_AUDIO = preload("uid://wahkxibc0c6m")

signal activated
@export var is_door_opened : bool = false
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var area_2d: Area2D = %Area2D

func _ready() -> void:
	if SaveManager.persistent_data.get_or_add( set_unique_name() ,"closed") == "open" :
		set_open()
	else :
		area_2d.body_entered.connect(on_player_entered)
		area_2d.body_exited.connect(on_player_exited)
		pass
	pass

func on_player_entered(_n : Node2D) -> void :
	Messages.input_hint_changed.emit("action")
	Messages.player_interacted.connect(on_player_interacted)
	pass

func on_player_exited(_n : Node2D) -> void :
	Messages.input_hint_changed.emit("")
	Messages.player_interacted.disconnect(on_player_interacted)
	pass
	
func on_player_interacted(_player :Player) -> void :
	Audio.play_spatial_soundfx(DOOR_SWITCH_AUDIO,global_position)
	SaveManager.persistent_data[ set_unique_name() ] = "open"
	activated.emit()
	set_open()

func set_open() -> void :
	is_door_opened = true
	sprite_2d.flip_h = true
	sprite_2d.modulate = Color.GRAY
	area_2d.queue_free()
	pass

func set_unique_name () -> String :
	var uname :String = ResourceUID.path_to_uid(owner.scene_file_path) 
	uname += "/" + get_parent().name + "/" + name
	return uname
