class_name BSCutScene
extends EnemyState

var duration : float = 0
var timer : float = 0
 


func enter() -> void :
	var anim : String = animation_name if animation_name else "Cinematic"
	
	enemy.play_animation(anim)
	duration = enemy.animation.current_animation_length
	enemy.velocity.x = 0 
	timer = 0
	blackboard.can_decide = false
	pass

func re_enter() -> void :
	#when enemy re-enter same state
	pass

func exit() -> void :
	#when enemy moves to next state
	blackboard.can_decide = true
	BossHud.display_boss_hp(blackboard.enemy_name)
 	
	pass

func physics_update(_delta: float) -> void:
	timer += _delta
	if timer >= duration:
		blackboard.can_decide = true
		blackboard.cinematic_state_played = false
	pass
