@icon("res://general/icons/state_machine.svg")
class_name EnemyStateMachine
extends Node

var enemy : Enemy
var blackboard : Blackboard
var states : Array[EnemyState]
var current_state : EnemyState :
	get():
		return states.front()
var previous_state : EnemyState :
	get():
		return states.get(1)

func setup(e : Enemy , bb : Blackboard) -> void :
	blackboard = bb
	enemy = e
	
	for c in get_children() :
		if c is EnemyState :
			c.enemy = e
			c.blackboard = bb
			c.statemachine = self
			states.append(c)
	current_state.enter()
	pass

func change_state(newstate : EnemyState) -> void :
	if not newstate :
		return
	
	if newstate == current_state :
		current_state.re_enter()
	
	if current_state :
		current_state.exit()
	
	states.push_front(newstate)
	if enemy :
		enemy.decisionengine.current_state = newstate
	states.resize(2)
	pass

func physics_update(delta : float) -> void :
	if current_state :
		current_state.physics_update(delta)
	pass
