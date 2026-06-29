@tool
@icon ("res://general/icons/level_bounds.svg")
class_name BossLevelBounds
extends Node2D

@export_range(480, 2048, 32,"suffix:px") var boss_width := 480:
	set(value):
		boss_width = value
		queue_redraw()

@export_range(270, 2048, 32 ,"suffix:px") var boss_height := 270:
	set(value):
		boss_height = value
		queue_redraw()
		
@export var zoom_x : float = 1.0  # Furthest view (zoomed out)
@export var zoom_y : float = 1.0
@export var zoom_duration := 0.5 # Duration in seconds

var boss_is_defeated : bool = false
var camlimit_left : float
var camlimit_right : float
var camlimit_top : float
var camlimit_bottom : float
var camzoom : Vector2
var new_camera_centerpos 
func _ready() -> void:
	z_index = 258
	
	if Engine.is_editor_hint():
		return
	var camera : Camera2D = null
	
	#check reference for camera
	while not camera: 
		await get_tree().process_frame
		camera = get_viewport().get_camera_2d()

	camlimit_left = int(global_position.x )
	camlimit_right = int(global_position.x) + boss_width
	camlimit_top = int(global_position.y)
	camlimit_bottom = int(global_position.y) + boss_height
	
	
	SceneManager.boss_area_entered.connect(_on_boss_area_entered)
	SceneManager.boss_defeated.connect(_on_boss_defeated)
	
	#var viewport_size = get_viewport_rect().size
	#var zoom_x = viewport_size.x / boss_width
	#var zoom_y = viewport_size.y / boss_height
	#var target_zoom = min(zoom_x, zoom_y)
	#print(viewport_size," : ", viewport_size.x," : ", viewport_size.y)
	#camzoom = Vector2(target_zoom, target_zoom)

	pass
	
func _draw() -> void:
	if Engine.is_editor_hint():
		var br := Rect2(Vector2.ZERO, Vector2(boss_width, boss_height))
		draw_rect(br, Color(1.0, 0.0, 0.086, 0.6), false,4)
		draw_rect(br, Color(1.0, 0.0, 0.025, 1.0), false,1)
		pass
	pass

func on_width_change(nw : int) -> void :
	boss_width = nw
	queue_redraw()
	pass

func on_height_change(nh : int) -> void :
	boss_height = nh
	queue_redraw()
	pass

func _on_boss_area_entered() -> void :
	new_camera_centerpos = global_position.x + boss_width * 0.5
	SceneManager.boss_area_limits.emit(camlimit_left,camlimit_right,camlimit_top,camlimit_bottom,new_camera_centerpos)
	pass

func _on_boss_defeated()-> void :
	boss_is_defeated = true
	pass
