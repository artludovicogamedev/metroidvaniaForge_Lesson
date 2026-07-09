class_name DecisionEngineAttack
extends DecisionEngine
#meta-name : DecisionEngine
#meta-description : Boilerplate for DecisionEngine
#meta-default : true

#default variables
#var enemy : Enemy
#var current_state : EnemyState
#var blackboard : Blackboard

 

@export var state_attack : ESAttack
@export var state_chase : ESChase
@export var state_idle : ESIdle
@export var attack_distance : float = 40

@onready var es_move: ESMove = %ESMove
@onready var es_hurt: ESHurt = %ESHurt
@onready var es_death: ESDeath = %ESDeath
@onready var es_parried: ESParried = %ESParried

#@onready var es_attack 


func _ready() -> void:
	await super()
	pass

func decide() -> EnemyState :
	#example 
	if blackboard.parry_source :
		return es_parried
	
	if blackboard.damage_source :
		if blackboard.health <= 0 :
			return es_death 
		else:
			return es_hurt 
			
	if current_state is ESDeath or not blackboard.can_decide :
		return null
	#
	if blackboard.target:
		if blackboard.edge_detected :
			return state_idle
			
		if state_attack.can_attack():
			return state_attack
			
		return state_chase

		
	if blackboard.edge_detected :
		enemy.change_direction(-blackboard.dir)
	return es_move
