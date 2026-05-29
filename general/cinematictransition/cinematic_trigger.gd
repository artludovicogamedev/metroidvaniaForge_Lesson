@tool
@icon("res://general/icons/cinematic.svg")
class_name CinematicTrigger
extends Node2D

enum SIDE { LEFT , RIGHT , TOP , BOTTOM }
enum LEVEL_TYPE { DUNGEON, FOREST }


@onready var area_2d: Area2D = $Area2D


@export_range( 2 , 16 , 1.0 ,"or_greater") var size : int = 2 :
	set(value) :
		size = value
		apply_area_settings()
	
@export var location : SIDE = SIDE.LEFT :
	set(value) :
		location = value
		apply_area_settings()
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	apply_area_settings()
	SceneManager.check_boss_cinematic.connect(on_new_cinematic_ready)
	pass # Replace with function body.
	
func on_new_cinematic_ready( ) -> void :
	area_2d.monitoring = false
	area_2d.body_entered.connect( _on_player_entered )
	await get_tree().physics_frame
	await get_tree().physics_frame
	area_2d.monitoring = true
	pass

func _on_player_entered( _n : Node2D) -> void :
	SceneManager.play_cinematic.emit()
	area_2d.body_entered.disconnect( _on_player_entered )
	pass

func apply_area_settings() -> void :
	#this function controls the scaling of the level transition node.
	area_2d = get_node_or_null("Area2D")
	if not area_2d : 
		return
	if location == SIDE.LEFT or location == SIDE.RIGHT:
		area_2d.scale.y = size
		if location == SIDE.LEFT:
			area_2d.scale.x = -1
		if location == SIDE.RIGHT:
			area_2d.scale.x = 1
	else :
		area_2d.scale.x = size
		if location == SIDE.TOP:
			area_2d.scale.y = 1
		if location == SIDE.BOTTOM:
			area_2d.scale.y = -1
	pass
