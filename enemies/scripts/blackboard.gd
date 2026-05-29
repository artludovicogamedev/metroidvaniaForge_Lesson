class_name Blackboard
extends Resource

var health : float = 3
var curhealth : float = 0 
var target : Player = null
var distance_to_target : float = -1
var can_decide : bool = true
var is_idle : bool = true
var edge_detected : bool = false
var wall_detected : bool = false
var wall_distance : float = 0
var damage_source : AttackArea = null
var dir : float = 1.0
var gravity_multiplier : float = 1.0
var backstabbed : bool = false
var maxfallspeed : float = 500
var punishattack : bool = false
var just_attacked : bool = false
var can_retaliate : bool = false 
var can_combo : bool = false
var cinematic_state_played : bool = false
var enemy_name : String = ""
func update_distance_to_target(pos : Vector2) -> void :
	if target :
		distance_to_target = pos.distance_to(target.global_position)
	else:
		distance_to_target = -1
	pass

		
