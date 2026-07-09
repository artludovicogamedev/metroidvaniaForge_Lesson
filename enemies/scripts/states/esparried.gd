class_name ESParried
extends EnemyState

@export var parry_duration : float = .5
var velx : float = 0
var duration : float = 0
var timer : float = 0
var attackdirection : float = 0 

func enter() -> void :
	var anim : String = animation_name if animation_name else "Hurt"
	if enemy.animation.current_animation == anim :
		enemy.animation.seek(0)
	else :
		enemy.play_animation(anim)
	duration = parry_duration
	timer = 0
	blackboard.parry_source = null
	blackboard.can_decide = false
	pass

func re_enter() -> void :
	#when enemy re-enter same state
	pass

func exit() -> void :
	#when enemy moves to next state
	blackboard.parry_source = null
	blackboard.can_decide = true
	pass

func physics_update(delta: float) -> void:
	#physics related variables here
	timer += delta
	if timer >= duration :
		blackboard.can_decide = true
	pass
