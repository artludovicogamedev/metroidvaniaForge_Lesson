class_name ESDeath
extends EnemyState
#meta-name : DecisionEngine
#meta-description : Boilerplate for DecisionEngine
#meta-default : true

@export var knockbackstrength : float = 100
@export var deathsoundsfx : AudioStream
var velx : float = 0
var duration : float = 0
var timer : float = 0

func enter() -> void :
	#when enemy enters this state
	var anim : String = animation_name if animation_name else "death"
	enemy.play_animation(anim)
	Audio.play_spatial_soundfx(deathsoundsfx,enemy.global_position,0.5)
	duration = enemy.animation.current_animation_length
	timer = 0
	calculate_velocity(blackboard.damage_source)
	blackboard.damage_source = null
	blackboard.can_decide = false
	await enemy.animation.animation_finished
	enemy.queue_free()
	pass

func physics_update(delta: float) -> void:
	#physics related variables here
	timer += delta
	enemy.velocity.x = velx * (1 - timer/duration)
	if timer >= duration :
		blackboard.can_decide = true
	pass
	
func calculate_velocity(a : AttackArea) -> void :
	velx = 1
	if a.global_position.x > enemy.global_position.x :
		velx = -1
	velx *= knockbackstrength
	pass
