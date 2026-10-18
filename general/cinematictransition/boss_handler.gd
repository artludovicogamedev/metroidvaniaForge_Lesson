@icon("res://general/icons/cinematic.svg")
class_name BossHandler
extends Node2D

@export var boss_enemy : Node2D
@export var boss_area_trigger : Area2D
@export var boss_level_bounds : Node2D
@export var boss_doors: Array[Node2D] = []

@export var zoom_duration : float = 0
@export var zoom_value := Vector2(0,0)
@export_category("Boss Music")
@export var boss_track : AudioStream
@export var boss_track_end : AudioStream

@export var boss_reward : Node2D
@export var original_levelbounds : Node2D
signal boss_reward_collected

var player_camera : Node2D
var boss_camera_adjusted : bool = false
var boss_door_locked : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if boss_enemy :
		boss_enemy.process_mode = Node.PROCESS_MODE_DISABLED

	if boss_area_trigger :
		#collision mask 5 is the player layer
		boss_area_trigger.set_collision_mask_value(5 , true)
		boss_area_trigger.body_entered.connect( _on_player_entered ) 
	
	if boss_reward :
		boss_reward.process_mode = Node.PROCESS_MODE_DISABLED
		boss_reward.visible = false
	
	if original_levelbounds :
		print("Original Level bounds found ")
	
	if SaveManager.persistent_data.get_or_add( boss_uname() , "" ) == "defeated" :
		queue_free()
	pass # Replace with function body.


func _on_player_entered( _n : Node2D) -> void :
	#Switches player to Idle state
	var player_node
	if _n is Player :
		player_node = _n
		_n.can_move = false
		_n.change_state(_n.current_state.idle)
	
	for cam in player_node.get_children() :
		if cam is PlayerCamera :
			player_camera = cam
			print("Player Camera is found")
	
	#disconnect so this area2D can only trigger the boss battle once
	start_boss_battle()
	boss_area_trigger.body_entered.disconnect( _on_player_entered )
	pass

func start_boss_battle() -> void :
	#connected to BossLevelBounds and decides the camera properties
	SceneManager.boss_area_entered.emit()
	
		
	if boss_enemy :
		boss_enemy.process_mode = Node.PROCESS_MODE_INHERIT
		boss_intro_properties()
		boss_enemy.tree_exiting.connect(end_boss_battle)
 
	pass

func end_boss_battle() -> void :
	boss_outro_properties()
	print("Boss Destroyed")
	pass

func boss_intro_properties() -> void :
	var boss_decision_engine 

	for c in boss_enemy.get_children() :
		if c is DecisionEngine :
			boss_decision_engine = c
		pass
	
	for bd in boss_doors:
		if bd.has_method("on_boss_door_closing"):
			await bd.on_boss_door_closing()
			boss_door_locked = true
		pass
	
	if boss_door_locked and boss_decision_engine.has_method("_trigger_cinematic"):
		await reposition_boss_camera(zoom_value,zoom_duration)
		boss_decision_engine._trigger_cinematic()
		Audio.play_music(boss_track) # 
	pass

func boss_outro_properties() -> void :
	#stop boss music
	Audio.play_music(boss_track_end)

	SaveManager.persistent_data[ boss_uname() ] = "defeated"
	
	#wait for deliver reward to finish
	await deliver_reward()
	
	#emit boss defeat signal 
	SceneManager.boss_defeated.emit()

	
	for bd in boss_doors:
		if bd.has_method("on_boss_door_open"):
			await bd.on_boss_door_open()
		pass

func deliver_reward() -> bool :
	if not boss_reward :
		return false
		
	if boss_reward :
		boss_reward.process_mode = Node.PROCESS_MODE_INHERIT
		boss_reward.visible = true
		
	await boss_reward.tree_exiting
	boss_reward_collected.emit()
	return true
	
func reposition_boss_camera(zv : Vector2 ,zd : float) -> Signal :
	var newzv = zv
	var newzd = zd
	var tween : Tween = create_tween()
	tween.tween_property(player_camera ,"zoom", newzv, newzd)
	return tween.finished

func boss_uname () -> String :
	var uname :String = ResourceUID.path_to_uid(owner.scene_file_path) 
	uname += "/" + get_parent().name + "/" + name
	return uname
	
#create a drop mechanic here 
# plan is Item will spawn floating 
# if player touches item, emit signal to switch player to idle 
# display text and sprite / scene explaining the skill
# wait for player to press confirm 
# once confirmed , enable player movement 
