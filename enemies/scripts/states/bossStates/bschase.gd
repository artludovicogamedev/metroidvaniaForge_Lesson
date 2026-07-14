class_name BSChase
extends EnemyState

@export var chase_speed = 80
@export var chase_timer : float = 0 
var chase_time = 0 

func enter() -> void :
	chase_time = 0
	#when enemy enters this state
	reset_attack_paramaters()
	enemy.play_animation(animation_name if animation_name else "move")
	
	pass

func re_enter() -> void :
	#when enemy re-enter same state
	pass

func exit() -> void :
	#when enemy moves to next state
	pass

func physics_update(_delta: float) -> void:
	var dir : float = sign(blackboard.target.global_position.x - enemy.global_position.x)
	enemy.change_direction(dir)
	enemy.velocity.x = chase_speed * dir
	pass

func reset_attack_paramaters() -> void :
	blackboard.punishattack = false
	blackboard.just_attacked = false
	pass

func check_if_enemy_on_floor( ) -> void : 
	pass
