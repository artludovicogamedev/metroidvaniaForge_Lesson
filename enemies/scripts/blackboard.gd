class_name Blackboard
extends Resource

var health : float = 3
var maxhealth : float = 3
var target : Player = null
var target_found : bool = false
var distance_to_target : float = -1
var can_decide : bool = true
var is_idle : bool = true
var edge_detected : bool = false
var wall_detected : bool = false
var wall_distance : float = 0
var damage_source : AttackArea = null
var parry_source : ParryArea = null
var dir : float = 1.0
var gravity_multiplier : float = 1.0
var punishattack : bool = false
var just_attacked : bool = false
var just_jumped : bool = false
var just_stepped_back : bool = false
var can_retaliate : bool = false 
var theme_song : AudioStreamPlayer = null
var cinematic_state_played : bool = false
var enemy_name : String = ""

var step_back_counter : int = 0

func update_distance_to_target(pos : Vector2) -> void :
	if target :
		distance_to_target = pos.distance_to(target.global_position)
	else:
		distance_to_target = -1
	pass

		
