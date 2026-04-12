class_name DecisionEngineBasic
extends DecisionEngine

@onready var es_move: ESMove = %ESMove
@onready var es_hurt: ESHurt = %ESHurt
@onready var es_death: ESDeath = %ESDeath

func _ready() -> void:
	await super()
	pass

func decide() -> EnemyState :
	#example 
	if blackboard.damage_source :
		if blackboard.health <= 0 :
			return es_death 
		else:
			print(blackboard.health)
			return es_hurt 
			
	if current_state is ESDeath or not blackboard.can_decide :
		return null
	
	#if blackboard.target :
	#	if blackboard.distance_to_target < 40 :
	#		return es_attack
	#	else :
	#		return es_chase
	if blackboard.edge_detected :
		enemy.change_direction(-blackboard.dir)
		
	return es_move
