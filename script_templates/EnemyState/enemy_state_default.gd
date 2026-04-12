#class_name ESState
extends EnemyState
#meta-name : DecisionEngine
#meta-description : Boilerplate for DecisionEngine
#meta-default : true

#default variables
#var statemachine : EnemyStateMachine
#var enemy : Enemy
#var blackboard : Blackboard
#@export var animation_name : String = "idle

func enter() -> void :
	#when enemy enters this state
	pass

func re_enter() -> void :
	#when enemy re-enter same state
	pass

func exit() -> void :
	#when enemy moves to next state
	pass

func physics_update(_delta: float) -> void:
	#physics related variables here
	pass
