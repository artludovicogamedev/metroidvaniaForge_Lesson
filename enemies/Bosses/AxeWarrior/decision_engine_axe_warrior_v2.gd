class_name DecisionEngineAxeBossV2
extends DecisionEngine
#meta-name : DecisionEngine
#meta-description : Boilerplate for DecisionEngine
#meta-default : true

@export var state_axe_attack : BSAWAxeAttack
@export var state_jumpchase : BSJumpChase
@export var state_chase : BSChase
@export var state_idle : BSIdle
@export var state_punish : BSPunishWindow
@export var state_cinematic : BSCutScene

@onready var es_move: ESMove = %ESMove
@onready var es_death: BSDeath = %BSDeath
@onready var bs_hurt: BSHurt = %BSHurt
@onready var bs_step_back: BSStepBack = %BSStepBack

var cinematic_triggered : bool = false

func _ready() -> void:
	await super()
	pass

func decide() -> EnemyState :
	if !blackboard.cinematic_state_played and cinematic_triggered == false:
		return state_idle
		
	if blackboard.cinematic_state_played:
		return state_cinematic
	
	if blackboard.damage_source and !blackboard.punishattack:
		if blackboard.health <= 0 :
			return es_death 
		else:
			return bs_hurt 
			
	if blackboard.target :
		print( "Target: ", blackboard.target,
		" | Distance: ", blackboard.distance_to_target,
		" | Can attack: ", state_axe_attack.can_attack(),
		" | Cooldown: ", state_axe_attack.on_cooldown
		)
		if state_axe_attack.can_attack():
			return state_axe_attack
		else :
			return state_chase
	return es_move
	
func _trigger_cinematic() -> void :
	blackboard.cinematic_state_played = true
	cinematic_triggered = true
	pass
