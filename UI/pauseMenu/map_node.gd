@tool
@icon ("res://general/icons/map_node.svg")
class_name MapNode
extends Control

const SCALE_FACTOR : float = 40

@export_file("*.tscn") var linkedscene : String : set = on_scene_set
@export_tool_button("Update" ) var update_node_action = update_Map_node

@export var entrance_top : Array[float] = [] 
@export var entrance_right : Array[float] = []
@export var entrance_bottom : Array[float] = []
@export var entrance_left : Array[float] = []

var indicator_offset : Vector2 = Vector2.ZERO # player location in map

@onready var label: Label = $Label
@onready var transition_blocks: Control = %TransitionBlocks

func _ready() -> void:
	if Engine.is_editor_hint():
		pass
	else :
		label.queue_free()
		create_transition_blocks()
		#create transition block
		#check if player discovered map
		if not SaveManager.is_area_discovered(linkedscene):
			visible = false
		elif SceneManager.current_scene_uid == linkedscene:
			display_player_location()
	pass
	
func on_scene_set(value : String) -> void :
	if linkedscene != value :
		linkedscene = value
		if Engine.is_editor_hint():
			update_Map_node()
	pass

func update_Map_node() -> void :
	
	var new_map_node_size : Vector2 = Vector2(480,270)
	var transitions : Array[LevelTransition] = []
	
	if ResourceLoader.exists(linkedscene):
		var packed_scene : PackedScene = ResourceLoader.load(linkedscene) as PackedScene
		
		if packed_scene :
			var instance = packed_scene.instantiate()
			
			if instance :
				update_node_label(instance)
				for c in instance.get_children():
					if c is LevelBounds :
						new_map_node_size = Vector2(c.width , c.height)
						indicator_offset = c.position
					elif c is LevelTransition:
						transitions.append(c)
				instance.queue_free()
				
	size = new_map_node_size / SCALE_FACTOR
	size = size.round()
	create_entrance_data(transitions)
	create_transition_blocks()
	pass

func update_node_label( scene : Node) ->void :
	if not label :
		label = $Label
	
	var t : String = scene.scene_file_path
	t = t.replace("res://levels/","")
	t = t.replace(".tscn","")
	label.text = t
	pass

func create_entrance_data ( transitions : Array[LevelTransition]) -> void :
	entrance_left.clear()
	entrance_right.clear()
	entrance_top.clear()
	entrance_bottom.clear()
	
	for t in transitions :
		var pos : Vector2 = ( t.position - indicator_offset ) / SCALE_FACTOR
		if t.location == LevelTransition.SIDE.LEFT :
			var offset : float = clampf(
					pos.y - 3,
					2.0,
					self.size.y - 5.0
				)
			entrance_left.append(offset)
			
		elif t.location == LevelTransition.SIDE.RIGHT :
			var offset : float = clampf(
					pos.y - 3,
					2.0,
					self.size.y - 5.0
				)
			entrance_right.append(offset)

		elif t.location == LevelTransition.SIDE.TOP :
			var offset : float = clampf(
					pos.x,
					2.0,
					self.size.x - 5.0
				)
			entrance_top.append(offset)

		elif t.location == LevelTransition.SIDE.BOTTOM :
			var offset : float = clampf(
					pos.x,
					2.0,
					self.size.x - 5.0
				)
			entrance_bottom.append(offset)
				
	pass

func create_transition_blocks( ) -> void :
	if not transition_blocks :
		transition_blocks = %TransitionBlocks
	
	for c in transition_blocks.get_children():
		c.queue_free()
	
	for t in entrance_left :
		var block : ColorRect = create_door_block()
		block.size.y = 3
		block.position.x = 0
		block.position.y = t

	for t in entrance_right :
		var block : ColorRect = create_door_block()
		block.size.y = 3
		block.position.x = self.size.x - 1
		block.position.y = t

	for t in entrance_top :
		var block : ColorRect = create_door_block()
		block.size.x = 3
		block.position.y = 0
		block.position.x = t

	for t in entrance_bottom :
		var block : ColorRect = create_door_block()
		block.size.x = 3
		block.position.y = self.size.y - 1
		block.position.x = t
		
func create_door_block () -> ColorRect :
	var block : ColorRect = ColorRect.new()
	transition_blocks.add_child(block)
	block.custom_minimum_size.x = 1
	block.custom_minimum_size.y = 1
	return block

func display_player_location() -> void :
	var player : Player = get_tree().get_first_node_in_group("Player")
	var i : Control = %PlayerIndicator
	var pos : Vector2 = position
	
	pos += ((player.global_position - indicator_offset) / SCALE_FACTOR)
	i.position = pos
	var clamppos : Vector2 = Vector2(4,4)
	pos = pos.clamp(position + clamppos,position + size - clamppos)
	#get player location 
	#add player indication
	#position equivalent to mini map
	
	pass
