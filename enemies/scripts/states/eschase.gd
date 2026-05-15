class_name ESChase
extends EnemyState

@export var chase_speed = 80

func enter() -> void :
	#when enemy enters this state
	enemy.play_animation(animation_name if animation_name else "move")
	pass

func re_enter() -> void :
	#when enemy re-enter same state
	pass

func exit() -> void :
	#when enemy moves to next state
	pass

func physics_update(_delta: float) -> void:
	if blackboard.target != null :
		var dir : float = sign(blackboard.target.global_position.x - enemy.global_position.x)
		enemy.change_direction(dir)
		enemy.velocity.x = chase_speed * dir
		
	pass
