class_name BSChase
extends EnemyState

@export var chase_speed = 80


func enter() -> void :
	#when enemy enters this state
	enemy.play_animation(animation_name if animation_name else "move")
	reset_attack_paramaters()
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
	
	if enemy.is_on_wall():
		enemy.change_direction(-blackboard.dir)
		
	#check if there is ledge
	pass

func reset_attack_paramaters() -> void :
	blackboard.punishattack = false
	blackboard.just_attacked = false
	pass
