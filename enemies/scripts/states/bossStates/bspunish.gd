class_name BSPunishWindow
extends EnemyState

var duration : float = 0
var timer : float = 0
var on_cooldown : bool = false 
var punish_hit : int = 0 

func enter() -> void :
	var anim : String = animation_name if animation_name else "PunishWindow"
	enemy.play_animation(anim)
	duration = enemy.animation.current_animation_length
	enemy.velocity.x = 0 
	timer = 0
	blackboard.can_decide = false
	blackboard.damage_source = null
	blackboard.can_retaliate = false 
	
	if !enemy.damage_counter.is_connected(_on_enemy_punished):
		enemy.damage_counter.connect(_on_enemy_punished)
		
	pass

func re_enter() -> void :
	#when enemy re-enter same state
	pass

func exit() -> void :
	#when enemy moves to next state
	
	if punish_hit > 0 :
		blackboard.can_retaliate = true 
	reset_punish_parameters()
	pass

func physics_update(_delta: float) -> void:
	timer += _delta
	if timer >= duration:
		blackboard.can_decide = true
		blackboard.punishattack = false
	pass

func _on_enemy_punished() -> void :
	punish_hit += 1 
	pass

func reset_punish_parameters() -> void :
	blackboard.can_decide = true
	blackboard.punishattack = false
	blackboard.just_attacked = false
	punish_hit = 0
	pass
