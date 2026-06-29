class_name BSDeath
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
	duration = enemy.animation.current_animation_length
	timer = 0
	calculate_velocity(blackboard.damage_source)
	blackboard.damage_source = null
	blackboard.can_decide = false
	enemy.velocity.x = 0 
	boss_theme_exit()
	await enemy.animation.animation_finished
	#emit signal here and tell player camera to use the level bounds
	#signal also tells that boss HUD should be hidden
	SceneManager.boss_defeated.emit()
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
	if !is_instance_valid(a):
		return
	
	velx = knockbackstrength
	
	if a.global_position.x > enemy.global_position.x:
		velx *= -1
	pass

func boss_theme_exit() -> Signal :
	var tween : Tween = create_tween()
	tween.tween_property(blackboard.theme_song ,"volume_db", -100,5)
	return tween.finished
