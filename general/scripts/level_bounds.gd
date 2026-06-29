@tool
@icon ("res://general/icons/level_bounds.svg")
class_name LevelBounds
extends Node2D

@export_range( 480 , 2048 ,32 ,"suffix:px") var width = 480 : set = on_width_change
@export_range( 270 , 2048 , 32 , "suffix:px") var height = 270 : set = on_height_change
var player_in_boss_area : bool = false

var camlimit_left : float
var camlimit_right : float
var camlimit_top : float
var camlimit_bottom : float
var camzoom : Vector2
var new_camera_centerpos 

func _ready() -> void:
	z_index = 256
	if Engine.is_editor_hint():
		return
	var camera : Camera2D = null
	SceneManager.boss_defeated.connect(_on_boss_defeated)
	#check reference for camera
	while not camera: 
		await get_tree().process_frame
		camera = get_viewport().get_camera_2d()
		
	#update limits of camera
	#this is the initial view
	camera.limit_left = int(global_position.x )
	camera.limit_right = int(global_position.x) + width
	camera.limit_top = int(global_position.y)
	camera.limit_bottom = int(global_position.y) + height
	print(camera.global_position)
	
	camlimit_left = int(global_position.x )
	camlimit_right = int(global_position.x) + width
	camlimit_top = int(global_position.y)
	camlimit_bottom = int(global_position.y) + height
	
	pass

func _draw() -> void:
	if Engine.is_editor_hint():
		#draw a box 
		var r : Rect2 = Rect2( Vector2.ZERO , Vector2(width,height))
		draw_rect(r, Color(0.0, 0.45,1.0 ,0.6), false,4)
		draw_rect(r, Color(0.0, 0.75,1.0), false,1)
		pass
	pass

func on_width_change(nw : int) -> void :
	width = nw
	queue_redraw()
	pass

func on_height_change(nh : int) -> void :
	height = nh
	queue_redraw()
	pass

func _on_boss_defeated() -> void :
	#new_camera_centerpos = global_position.x
	var playerpos = get_parent().global_position.x
	SceneManager.original_area_limits.emit(camlimit_left,camlimit_right,camlimit_top,camlimit_bottom,playerpos)
	pass
