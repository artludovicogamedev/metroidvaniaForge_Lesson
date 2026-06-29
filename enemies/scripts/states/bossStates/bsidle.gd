class_name BSIdle
extends EnemyState

var duration : float = 0
var timer : float = 0
var on_cooldown : bool = false 

func enter() -> void :
	var anim : String = animation_name if animation_name else "Idle"
	enemy.play_animation(anim)
	enemy.velocity.x = 0
	duration = enemy.animation.current_animation_length
	timer = 0
	blackboard.can_decide = false
	pass

func re_enter() -> void :
	#when enemy re-enter same state
	pass

func exit() -> void :
	#when enemy moves to next state
	blackboard.can_decide = true
	pass

func physics_update(_delta: float) -> void:
	timer += _delta
	
	#in this idle method , if enemy detects wall collision or is idle for more than 1 second
	#switch state to taunt/move
	if timer >= duration:
		blackboard.can_decide = true
	pass

 
