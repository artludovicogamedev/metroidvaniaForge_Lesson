class_name ESMove
extends EnemyState

@export var walkspeed : float = 50

func enter() -> void :
	var anim : String = animation_name if animation_name else "move"
	enemy.play_animation(anim)
	pass

func re_enter() -> void :
	#when enemy re-enter same state
	pass

func exit() -> void :
	#when enemy moves to next state
	pass

func physics_update(_delta: float) -> void:
	#physics related variables here
	if enemy.is_on_wall():
		enemy.change_direction(-blackboard.dir)
		
	enemy.velocity.x = walkspeed * blackboard.dir
	pass
	
