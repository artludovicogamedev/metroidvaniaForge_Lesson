class_name BSAttack
extends EnemyState

enum ATTACKTYPE { LIGHT , HEAVY , KNOCKBACK }


@export var reposition_distance : float = 100
@export var attack_velocity_curve : Curve
@export var attack_range : float = 150

@export var attackdamage1 : float = 3
@export var attackdamage2 : float = 2
@export var atkcd1 : float = 3.0
@export var atkcd2 : float = 1.5
@export var cooldown : float = 4

@export var rise_gravity_multiplier : float = 1.0
@export var fall_gravity_multiplier : float = 2.5


var hurtbox_size_x : float = 0
var hurtbox_size_y : float = 0
var hurtbox_position_x : float = 0
var hurtbox_position_y : float = 0
var attackcnt : int = 1
var finaldamage : float = 0


var duration : float = 0
var timer : float = 0
var on_cooldown : bool = false 



func enter() -> void :
	normal_attack_pattern()
	print("Attack State - just attacked : " , blackboard.just_attacked)

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
	blackboard.gravity_multiplier = 1.0
	enemy.attack_area.reset_attack_properties()
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

	if attack_velocity_curve :
		var sample : float = attack_velocity_curve.sample(timer / duration)
		enemy.velocity.x = reposition_distance * sample * blackboard.dir
	pass

func can_attack() -> bool :
	if blackboard.distance_to_target <= attack_range and not on_cooldown:
		var distancetotarget = blackboard.distance_to_target

		print("Distance to target : " , blackboard.distance_to_target)
		#To optimize the variables below later.
		
		if distancetotarget > 80:
			set_up_attack_variables(1,atkcd1,48,120,72,-60,200,attackdamage1)
			
		elif ( distancetotarget > 20 and 
			distancetotarget <= 80 and 
			enemy.velocity.y == 0 and 
			enemy.is_on_floor()):
			set_up_attack_variables(2,atkcd2,24,24,48,-32,50,attackdamage2)
		

		return true
	return false

func run_attack_cooldown() -> void :
	#if attackcnt == 1 :
		#cooldown = atkcd1
	#else:
		#cooldown = atkcd2
	await get_tree().create_timer(cooldown).timeout
	on_cooldown = false
	pass
	
func set_up_attack_variables( ac : int , atkcd : float , 
	hbszx : float , hbszy : float , 
	hbposx : float , hbposy : float, 
	sp : float , dmg : float ) -> void :
	attackcnt = ac    # attack count 
	cooldown = atkcd  # cooldown 
	hurtbox_size_x = hbszx # shape size X 
	hurtbox_size_y = hbszy # shape size Y 
	hurtbox_position_x = hbposx
	hurtbox_position_y = hbposy  # hitbox position 
	reposition_distance = sp # reposition_distance 
	finaldamage = dmg # damage
	pass



func normal_attack_pattern () -> void :
	var attackname : String = "Attack"
	var anim : String = animation_name if animation_name else attackname + str(attackcnt)
	enemy.play_animation(anim)
	duration = enemy.animation.current_animation_length
	timer = 0
	enemy.attack_area.compute_attack_properties(hurtbox_size_x,hurtbox_size_y,hurtbox_position_x,hurtbox_position_y,finaldamage)
	blackboard.can_decide = false
	
	
	if attackcnt == 1 and blackboard.punishattack:
		blackboard.just_attacked = true
		
	on_cooldown = true
	enemy.velocity.x = reposition_distance * blackboard.dir

func retaliation_pattern() -> void :
	pass
	
