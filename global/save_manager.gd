#save manager script
extends Node

const CONFIG_FILE_PATH = "user://settings.cfg"
const SLOTS : Array [String] = [
	"save_01","save_02","save_03"
]

var current_slot : int = 0
var save_data : Dictionary
var discovered_areas : Array = [] # for map
var persistent_data : Dictionary = {} #data for storing doors, chests , etc..



func _ready() -> void:
	load_configuration()
	SceneManager.scene_entered.connect(on_scene_entered)
	pass

func save_game() -> void :
	var player : Player = get_tree().get_first_node_in_group("Player")
	
	save_data = {
		"scene_path" : SceneManager.current_scene_uid ,
		"player_x_pos" : player.global_position.x,
		"player_y_pos" : player.global_position.y,
		"player_hp" : player.player_hp,
		"player_max_hp" : player.player_max_hp,
		"player_mp" : player.player_mp,
		"player_max_mp" : player.player_max_mp,
		"dash_skill" : player.dash_skill ,
		"double_jump" : player.double_jump,
		"ground_slam" : player.ground_slam,
		"morph_roll" : player.morph_roll,
		"discovered_areas" : discovered_areas,
		"persistent_data" : persistent_data,
	}
	var save_file = FileAccess.open(get_filename( current_slot ), FileAccess.WRITE)
	save_file.store_line( JSON.stringify(save_data)) 
	pass

func create_new_game_save( slot : int  ) -> void :
	current_slot = slot
	discovered_areas.clear()
	var new_game_scene : String = "uid://ci7ccefelmweo"
	discovered_areas.append(new_game_scene)
	save_data = {
		"scene_path" : new_game_scene ,
		"player_x_pos" : 160,
		"player_y_pos" : 168,
		"player_hp" : 20,
		"player_max_hp" : 20,
		"player_mp" : 10,
		"player_max_mp" : 10,
		"dash_skill" : false ,
		"double_jump" : false,
		"ground_slam" : false,
		"morph_roll" : false,
		"discovered_areas" : discovered_areas,
		"persistent_data" : persistent_data,
	}
	#save your file
	var save_file = FileAccess.open(get_filename( current_slot ), FileAccess.WRITE)
	save_file.store_line( JSON.stringify(save_data)) 
	
	save_file.close()
	load_game(slot)
	pass

func load_game( slot : int ) -> void :
	#check if file exists
	
	if not FileAccess.file_exists(get_filename( current_slot )):
		return
	
	#access save file as read only
	current_slot = slot
	var save_file = FileAccess.open(get_filename( current_slot ), FileAccess.READ)
	#get line 1 of JSON file because saved file is 1 liner
	save_data = JSON.parse_string(save_file.get_line())
	
	#persistent data , accessed by searching string using save_data.get
	persistent_data = save_data.get("persistent_data" , {}) 
	discovered_areas = save_data.get("discovered_areas",[])
	var scene_path : String = save_data.get("scene_path","uid://ci7ccefelmweo")
	SceneManager.transition_scene( scene_path , "" , Vector2.ZERO ,"up")
	await SceneManager.new_scene_ready
	load_player_stats()
	pass


func load_player_stats() -> void :
	var player :Player = null
	
	while not player :
		player = get_tree().get_first_node_in_group("Player")
		await get_tree().process_frame
		
	#stats
	player.player_hp = save_data.get("player_hp" , 20)
	player.player_max_hp = save_data.get("player_max_hp" , 20)
	
	#skills
	player.dash_skill = save_data.get("dash_skill" , false)
	player.double_jump = save_data.get("double_jump" , false)
	player.ground_slam = save_data.get("ground_slam" , false)
	player.morph_roll = save_data.get("morph_roll" , false)
	
	#offset position
	player.global_position = Vector2(
		save_data.get("player_x_pos" , 0),
		save_data.get("player_y_pos" , Vector2.ZERO)
	)
	pass

func get_filename(slot : int) -> String :
	return "user://" + SLOTS[slot] + ".sav"
	
func check_if_file_exists( slot : int) -> bool :
	return FileAccess.file_exists( get_filename( slot ))

func is_area_discovered( scene_uid : String) -> bool :
	return discovered_areas.has(scene_uid)

func on_scene_entered(scene_uid : String)-> void :
	if discovered_areas.has(scene_uid): 
		return
	else:
		discovered_areas.append(scene_uid)
	pass
	
func save_configuration()->void:
	var config := ConfigFile.new()
	config.set_value("audio","music" , AudioServer.get_bus_volume_linear(2))
	config.set_value("audio","sfx" , AudioServer.get_bus_volume_linear(3))
	config.set_value("audio","ui" , AudioServer.get_bus_volume_linear(4))
	config.save(CONFIG_FILE_PATH)
	pass

func load_configuration()->void:
	var config := ConfigFile.new()
	var err = config.load(CONFIG_FILE_PATH)
	if err != OK :
		AudioServer.set_bus_volume_linear(2,0.7)
		AudioServer.set_bus_volume_linear(3,1)
		AudioServer.set_bus_volume_linear(4,1)
		save_configuration()
		return
	AudioServer.set_bus_volume_linear(2,config.get_value("audio","music",0.7))
	AudioServer.set_bus_volume_linear(3,config.get_value("audio","sfx",0.7))
	AudioServer.set_bus_volume_linear(4,config.get_value("audio","ui",0.7))
	

	pass
