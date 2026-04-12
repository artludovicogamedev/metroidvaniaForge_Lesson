extends DecisionEngine
#meta-name : DecisionEngine
#meta-description : Boilerplate for DecisionEngine
#meta-default : true

#default variables
#var enemy : Enemy
#var current_state : EnemyState
#var blackboard : Blackboard

func _ready() -> void:
	await super()
	pass

func decide() -> EnemyState :
	#example 
	#if blackboard.damage_source :
	#	if blackboard.health <= 0 :
	#		return es_death 
	#	else:
	#		return es_hurt 
	#if currentstate is es_death and not blackboard.candecide :
	#	return null
	
	#if blackboard.target :
	#	if blackboard.distance_to_target < 40 :
	#		return es_attack
	#	else :
	#		return es_chase
	return null
