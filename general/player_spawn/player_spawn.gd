@icon ("res://general/icons/player_spawn.svg")
class_name PlayerSpawn
extends Node2D
 
const PLAYER = preload("uid://du587dc8hdbsf")
var temp_collision_tile
func _ready() -> void:
	visible = false
	await get_tree().process_frame
	
	if get_tree().get_first_node_in_group("Player"):
		#do nothing if there is a player existing in the scene
		#but access player to assign the tilemap
		var player: Player = get_tree().get_first_node_in_group("Player")
		player.collisionTiles = get_parent().get_node("LevelTilemaps/TileMapMain")
		return
		
	var player: Player = get_tree().get_first_node_in_group("Player")

	if player == null:
		player = PLAYER.instantiate()
		get_tree().root.add_child(player)

	# These should happen EVERY time a level loads
	player.global_position = self.global_position
	player.collisionTiles = get_parent().get_node("LevelTilemaps/TileMapMain")
	
	pass
