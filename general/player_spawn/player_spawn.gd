@icon ("res://general/icons/player_spawn.svg")
class_name PlayerSpawn
extends Node2D
 
const PLAYER = preload("uid://byque4w54oowj")

func _ready() -> void:
	visible = false
	await get_tree().process_frame
	
	if get_tree().get_first_node_in_group("Player"):
		#do nothing if there is a player existing in the scene
		return
	
	var player : Player = load("uid://byque4w54oowj").instantiate()
	get_tree().root.add_child(player)
	player.global_position = self.global_position
	
	pass
