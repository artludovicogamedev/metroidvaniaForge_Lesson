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
@onready var bs_step_back: BSStepBack = %BSStepBack

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
	
	if blackboard.damage_source and !blackboard.punishattack:
		if blackboard.health <= 0 :
			return es_death 
		else:
			return bs_hurt 
			
	if current_state is ESDeath or not blackboard.can_decide :
		return null
		
	#forces enemy to attack even if blackboard.target is null
	if blackboard.just_jumped:
		return state_attack

	if blackboard.punishattack and blackboard.just_attacked:
		return state_punish
		
	if blackboard.target :
		return choose_next_action()

	#if blackboard.distance_to_target <= 50:
		#return choose_close_range_move()
	#
	##forces the boss to attack even if there is no target after jump 
	#if blackboard.just_jumped:
		#return state_attack
		#
	## transition from state attack to punish regardless 
	#if blackboard.punishattack and blackboard.just_attacked:
		#return state_punish
#
	#if blackboard.just_stepped_back : 
		#blackboard.just_stepped_back = false
		#return choose_after_step_back()
		#
	#if blackboard.target:
		#if state_jumpchase.decide_to_jump():
			#return state_jumpchase
		#
		#if state_attack.can_attack():
			#return state_attack
	#
		#if blackboard.distance_to_target <= 50:
			#return choose_close_range_move()
	#
		#return state_chase
 #
	#if blackboard.edge_detected :
		#enemy.change_direction(-blackboard.dir)

	return es_move
	

func choose_next_action() -> EnemyState :
	var roll = randi_range(0,99)
	
	if roll < 10 and state_jumpchase.decide_to_jump():
		return state_jumpchase
		
	if roll < 30 and bs_step_back.can_jump_back():
		return bs_step_back
		
	if roll < 70 and state_attack.can_attack():
		return state_attack
		
	return state_chase

func choose_after_step_back() -> EnemyState:
	var roll = randi_range(0,99)
	
	if roll < 10 and blackboard.step_back_counter == 0:
		blackboard.step_back_counter += 1
		return bs_step_back
		
	if roll < 60:
		return state_attack
	if roll < 30:
		return state_chase
	blackboard.step_back_counter = 0
	enemy.velocity.x = 0
	return state_idle

func choose_close_range_move() -> EnemyState :
	var roll := randi_range(0, 99)
	
	if roll < 40 and bs_step_back.can_jump_back():
		return bs_step_back

	if roll < 99 and state_attack.can_attack():
		return state_attack
		
	enemy.velocity.x = 0
	return state_idle
	
func _trigger_cinematic() -> void :
	blackboard.cinematic_state_played = true
	cinematic_triggered = true
	SceneManager.play_cinematic.disconnect(_trigger_cinematic)
	pass
