class_name ESAttack
extends EnemyState
#meta-name : DecisionEngine
#meta-description : Boilerplate for DecisionEngine
#meta-default : true

#default variables
#var statemachine : EnemyStateMachine
#var enemy : Enemy
#var blackboard : Blackboard
#@export var animation_name : String = "idle
@export var cooldown : float = 3.0
@export var walkspeed : float = 50
@export var attack_velocity_curve : Curve
@export var attack_range : float = 50


var duration : float = 0
var timer : float = 0
var on_cooldown : bool = false 


func enter() -> void :
	var anim : String = animation_name if animation_name else "Attack"
	enemy.play_animation(anim)
	duration = enemy.animation.current_animation_length
	print(duration)
	timer = 0
	blackboard.can_decide = false
	on_cooldown = true
	enemy.velocity.x = 0
	pass

func re_enter() -> void :
	#when enemy re-enter same state
	pass

func exit() -> void :
	blackboard.can_decide = true
	run_attack_cooldown()
	pass

func physics_update(_delta: float) -> void:
	#physics related variables here
	timer += _delta
	if timer >= duration:
		blackboard.can_decide = true
	
	if attack_velocity_curve :
		var sample : float = attack_velocity_curve.sample(timer / duration)
		enemy.velocity.x = walkspeed * sample * blackboard.dir
	pass

func can_attack() -> bool :
	if blackboard.distance_to_target <= attack_range and not on_cooldown:
		return true
	return false

func run_attack_cooldown() -> void :
	await get_tree().create_timer(cooldown).timeout
	on_cooldown = false
	pass
