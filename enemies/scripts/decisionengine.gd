@icon("res://general/icons/decision_engine.svg")
class_name DecisionEngine
extends Node

var enemy : Enemy
var current_state : EnemyState
var blackboard : Blackboard

func _ready() -> void:
	while not enemy:
		await get_tree().process_frame
	
	enemy.change_direction(-1.0 if enemy.is_facing_left else 1.0)
	pass

func decide() -> EnemyState :
	return null 
