class_name DecisionEngineAxeBoss
extends DecisionEngine

@export var state_attack : BSAttack
@export var state_jumpchase : BSJumpChase
@export var state_chase : BSChase
@export var state_idle : BSIdle
@export var state_punish : BSPunishWindow
@export var state_cinematic : BSCutScene
@export var attack_distance : float = 40


@onready var es_move: ESMove = %ESMove
@onready var es_death: BSDeath = %BSDeath
@onready var bs_hurt: BSHurt = %BSHurt

var previous_state : EnemyState
var cinematic_triggered : bool = false
func _ready() -> void:
	await super()
	SceneManager.play_cinematic.connect(_trigger_cinematic)
	pass

func decide() -> EnemyState :
	#example 
	#add a one time state transition 
	if !blackboard.cinematic_state_played and cinematic_triggered == false:
		return state_idle
		
	if blackboard.cinematic_state_played:
		return state_cinematic
	
	if blackboard.damage_source:
		if blackboard.health <= 0 :
			return es_death 
		else:
			return bs_hurt 
			
	if current_state is ESDeath or not blackboard.can_decide :
		return null
	
	#forces the boss to attack even if there is no target after jump 
	if blackboard.just_jumped:
		return state_attack
		
	# transition from state attack to punish regardless 
	if blackboard.punishattack and blackboard.just_attacked:
		return state_punish
	
	if blackboard.target:
		if state_jumpchase.decide_to_jump():
			return state_jumpchase
		
		if state_attack.can_attack():
			return state_attack
	
		if blackboard.distance_to_target <= 40 :
			#for now do this, else make boss move bac
			return state_idle
			
		return state_chase
		#if blackboard.distance_to_target < 300 :
			#return state_idle
		
		#return state_idle
	#			if attacktype is normal ( downward axe swing )
	#				return to idle state for a while 
	#               knockback player 
	#			if attacktype is kick 
	#				knockback player further away
	#			if attacktype is heavy ( stronger axe swing with danger indication )
	#				if hit - knockback player 
	#				if missed - transition to recovery state.
	#               	in recovery state there is punish window 
	#               	if player is still within target range after punish window ends
	#						transition to attack (upward swing)
	#							if hit - launch player upwards 
	#					if player is outside target area, return to idle
			
	#	else :
	#		return es_chase
	if blackboard.edge_detected :
		enemy.change_direction(-blackboard.dir)

	return es_move
func _trigger_cinematic() -> void :
	blackboard.cinematic_state_played = true
	cinematic_triggered = true
	SceneManager.play_cinematic.disconnect(_trigger_cinematic)
	pass
