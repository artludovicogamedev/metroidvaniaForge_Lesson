class_name BSStepBack
extends EnemyState
#meta-name : DecisionEngine
#meta-description : Boilerplate for DecisionEngine
#meta-default : true

#default variables
#var statemachine : EnemyStateMachine
#var enemy : Enemy
#var blackboard : Blackboard
#@export var animation_name : String = "idle
@export var jumpbackcooldown : float = 0
@export var jump_force := Vector2(300,-450)

var descending_gravity : float = 2.5
var duration : float = 0 
var timer = 0 
var on_cooldown : bool = false


func enter() -> void :
	handle_jump_back()
	pass

func re_enter() -> void :
	#when enemy re-enter same state
	
	handle_jump_back()
	pass

func handle_jump_back() -> void :
	#when enemy enters this state
	var anim : String = animation_name if animation_name else "jumpback"
	enemy.play_animation(anim)
	duration = enemy.animation.current_animation_length
	var dir := -1 if enemy.sprite.flip_h else 1
	enemy.velocity.x = -jump_force.x * dir
	enemy.velocity.y = jump_force.y
	blackboard.can_decide = false
	blackboard.just_stepped_back = true
	on_cooldown = true
	pass

func exit() -> void :
	run_stepback_cooldown()
	timer = 0
	blackboard.can_decide = true
	pass

func physics_update(_delta: float) -> void:
	#physics related variables here
	timer += _delta
	blackboard.gravity_multiplier = descending_gravity
	
	if enemy.is_on_floor() and enemy.velocity.y >= 0:
		enemy.velocity.x = 0
		blackboard.can_decide = true
	pass

func run_stepback_cooldown() -> void :
	await get_tree().create_timer(jumpbackcooldown).timeout
	on_cooldown = false
	pass
	
func can_jump_back() -> bool : 
	if not on_cooldown:
		return true
	return false
