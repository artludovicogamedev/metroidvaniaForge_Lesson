class_name BSAWAxeAttack
extends EnemyState

@onready var slash_sfx: AudioStreamPlayer = %SlashSfx
@onready var grunt_attack_1: AudioStreamPlayer = %GruntAttack1
@onready var male_grunt_3: AudioStreamPlayer = %MaleGrunt3

@export var attack_range : float = 150
@export var attackdamage1 : float = 3
@export var cooldown : float = 4
@export var reposition_distance : float = 100
@export var attack_velocity_curve : Curve
@export var knockbackforce1 : float = 200
@export var knockbackforce2 : float = 150

var hurtbox_size_x : float = 0
var hurtbox_size_y : float = 0
var hurtbox_position_x : float = 0
var hurtbox_position_y : float = 0
var attackcnt : int = 1
var finaldamage : float = 0
var distancetotarget : float = 0

var duration : float = 0
var timer : float = 0
var on_cooldown : bool = false 


func enter() -> void :
	#when enemy enters this state
	duration = 0
	#hurtbox management
	print("Boss enter AXE ATTACK State")
	var anim : String = animation_name if animation_name else "AxeAttack1"
	enemy.play_animation(anim)
	duration = enemy.animation.current_animation_length	
	timer = 0
	blackboard.can_decide = false
	enemy.velocity.x = reposition_distance * blackboard.dir
	
	set_up_attack_variables(1,81,166,89,-85,200,attackdamage1)
	prepare_attack_parameters()
	grunt_attack_1.play()
	on_cooldown = true
	pass

func re_enter() -> void :
	#when enemy re-enter same state
	pass

func exit() -> void :
	#when enemy moves to next state
	blackboard.can_decide = true
	run_attack_cooldown()
	pass

func physics_update(_delta: float) -> void:
	print("physics update ticker : " , enemy.statemachine.current_state)
	timer += _delta
	
	if timer >= duration:
		blackboard.can_decide = true
	
	if attack_velocity_curve :
		var sample : float = attack_velocity_curve.sample(timer / duration)
		enemy.velocity.x = reposition_distance * sample * blackboard.dir
	pass

func can_attack() -> bool :
	#attack cooldown will vary
	if blackboard.distance_to_target <= attack_range and not on_cooldown :
		return true
	return false
	
func run_attack_cooldown() -> void :
	await get_tree().create_timer(cooldown).timeout
	on_cooldown = false
	pass
	
func set_up_attack_variables( ac : int , 
	hbszx : float , hbszy : float , 
	hbposx : float , hbposy : float, 
	sp : float , dmg : float ) -> void :
		
	#this function handles attack variables including damage, resizing the hurtboxes
	#position of the hurtboxes 
	
	attackcnt = ac    # attack count 
	hurtbox_size_x = hbszx # shape size X 
	hurtbox_size_y = hbszy # shape size Y 
	hurtbox_position_x = hbposx
	hurtbox_position_y = hbposy  # hitbox position 
	reposition_distance = sp # reposition_distance 
	finaldamage = dmg # damage
	pass

func prepare_attack_parameters() -> void :
	var kbf : float = 0 
	if attackcnt == 1 :
		kbf = knockbackforce1
	else :
		kbf = knockbackforce2
	enemy.attack_area.compute_attack_properties(hurtbox_size_x,hurtbox_size_y,hurtbox_position_x,hurtbox_position_y,finaldamage,kbf)
	pass
	
