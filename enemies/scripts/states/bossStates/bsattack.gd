class_name BSAttack
extends EnemyState

enum ATTACKTYPE { LIGHT , HEAVY , KNOCKBACK }

@onready var slash_sfx: AudioStreamPlayer = %SlashSfx
@onready var grunt_attack_1: AudioStreamPlayer = %GruntAttack1
@onready var male_grunt_3: AudioStreamPlayer = %MaleGrunt3

@export var reposition_distance : float = 100
@export var attack_velocity_curve : Curve
@export var attack_range : float = 150
@export var attackdamage1 : float = 3
@export var attackdamage2 : float = 2
@export var knockbackforce1 : float = 200
@export var knockbackforce2 : float = 150
@export var cooldown : float = 4

@export var rise_gravity_multiplier : float = 1.0
@export var fall_gravity_multiplier : float = 2.5

var can_use_axe_attack : bool = false
var can_use_kick_attack : bool = false

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
	print("Enemy Distance to Target : ", distancetotarget)
	if blackboard.just_jumped :
		jump_attack_pattern()
		blackboard.just_jumped = false
		
	if can_use_axe_attack :
		axe_attack_pattern()

	if can_use_kick_attack :
		kick_attack_pattern()
		
	prepare_attack_parameters()
	duration = enemy.animation.current_animation_length
	enemy.velocity.x = reposition_distance * blackboard.dir
	on_cooldown = true
	timer = 0
	blackboard.can_decide = false

	
	#print("Animation Name : " , anim , 
	#" hurtbox X : ",hurtbox_size_x ,
	#" hurtbox Y : " , hurtbox_size_y , 
	#" hurtbox position x : " , hurtbox_position_x,
	#" hurtbox position y : " , hurtbox_position_y,	
	#" Damage : " ,finaldamage)
	pass
	
	#distance to target - attack1 triggers at 90 
func re_enter() -> void :
	#when enemy re-enter same state
	pass

func exit() -> void :
	blackboard.can_decide = true
	blackboard.just_jumped = false
	blackboard.gravity_multiplier = 1.0
	run_attack_cooldown()
	pass

func physics_update(_delta: float) -> void:
	#physics related variables here
	timer += _delta
	
	if enemy.velocity.y < 0:
		blackboard.gravity_multiplier = rise_gravity_multiplier
	else:
		blackboard.gravity_multiplier = fall_gravity_multiplier
		
	if timer >= duration:
		blackboard.can_decide = true
	
	if attackcnt == 1 and blackboard.punishattack:
		blackboard.just_attacked = true
		
	if attack_velocity_curve :
		var sample : float = attack_velocity_curve.sample(timer / duration)
		enemy.velocity.x = reposition_distance * sample * blackboard.dir
	pass
	
#rework 
# can_attack becomes can_jump attack - move the attack animation logic here
# can_axe_attack - move attack animation here 
# can kick attack - move kick animation here 
#func can_axe_attack() -> bool :
	#if blackboard.distance_to_target <= attack_range and not on_cooldown:
		#distancetotarget = blackboard.distance_to_target
		#if distancetotarget > 80 :
			#jump_attack_pattern()
			#return true
	#return false
	#
func can_attack() -> bool :
	#attack cooldown will vary
	if blackboard.distance_to_target <= attack_range and not on_cooldown:
		distancetotarget = blackboard.distance_to_target
		if distancetotarget > 80 :
			can_use_axe_attack = true
			can_use_kick_attack = false
			
		if (distancetotarget >= 30 and distancetotarget <= 80 ):
			can_use_axe_attack = false
			can_use_kick_attack = true
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

func kick_attack_pattern() -> void :
	set_up_attack_variables(2,24,24,48,-32,50,attackdamage2)
	var anim : String = animation_name if animation_name else "Attack2"
	enemy.play_animation(anim)
	male_grunt_3.play()
	can_use_kick_attack = false

func axe_attack_pattern () -> void :
	set_up_attack_variables(1,48,120,72,-60,200,attackdamage1)
	var anim : String = animation_name if animation_name else "Attack1"
	enemy.play_animation(anim)
	grunt_attack_1.play()
	can_use_axe_attack = false
	
func jump_attack_pattern() -> void :
	set_up_attack_variables(1,48,120,72,-60,200,attackdamage1)
	var anim : String = animation_name if animation_name else "Attack1"
	slash_sfx.play()
	enemy.play_animation(anim)

func prepare_attack_parameters() -> void :
	var kbf : float = 0 
	if attackcnt == 1 :
		kbf = knockbackforce1
	else :
		kbf = knockbackforce2
	enemy.attack_area.compute_attack_properties(hurtbox_size_x,hurtbox_size_y,hurtbox_position_x,hurtbox_position_y,finaldamage,kbf)
	pass
	
