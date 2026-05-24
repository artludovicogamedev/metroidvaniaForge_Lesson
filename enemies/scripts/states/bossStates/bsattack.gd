class_name BSAttack
extends EnemyState

enum ATTACKTYPE { LIGHT , HEAVY , KNOCKBACK }

@export var cooldown : float = 3.0
@export var reposition_distance : float = 100
@export var attack_velocity_curve : Curve
@export var attack_range : float = 150
@export var attackdamage1 : float = 8
@export var attackdamage2 : float = 4

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
	var attackname : String = "Attack"
	var anim : String = animation_name if animation_name else attackname + str(attackcnt)
	print("Animation Name : " , anim , 
	" hurtbox X : ",hurtbox_size_x ,
	" hurtbox Y : " , hurtbox_size_y , 
	" hurtbox position x : " , hurtbox_position_x,
	" hurtbox position y : " , hurtbox_position_y,	
	" Damage : " ,finaldamage)
	enemy.play_animation(anim)
	duration = enemy.animation.current_animation_length
	timer = 0
	enemy.attack_area.compute_attack_properties(hurtbox_size_x,hurtbox_size_y,hurtbox_position_x,hurtbox_position_y,finaldamage)
	blackboard.can_decide = false
	on_cooldown = true
	enemy.velocity.x = reposition_distance * blackboard.dir
	pass
	
	#distance to target - attack1 triggers at 90 
func re_enter() -> void :
	#when enemy re-enter same state
	pass

func exit() -> void :
	blackboard.can_decide = true
	enemy.attack_area.reset_attack_properties()
	run_attack_cooldown()
	pass

func physics_update(_delta: float) -> void:
	#physics related variables here
	timer += _delta
	if timer >= duration:
		blackboard.can_decide = true
	
	if attack_velocity_curve :
		var sample : float = attack_velocity_curve.sample(timer / duration)
		enemy.velocity.x = reposition_distance * sample * blackboard.dir
	pass

func can_attack() -> bool :
	if blackboard.distance_to_target <= attack_range and not on_cooldown:
		var distancetotarget = blackboard.distance_to_target

		#To optimize the variables below later.
		if distancetotarget >= 90 :
			set_up_attack_variables(1,1,48,120,72,-60,200,8)

		elif distancetotarget > 40 and distancetotarget < 90 :
			set_up_attack_variables(2,1,24,24,48,-32,50,3)
			
			
		print("Distance to Target : ", 
			blackboard.distance_to_target , " : Attack Range : " , attack_range )
		return true
	return false

func run_attack_cooldown() -> void :
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

func reset_attack_area_properties() -> void : 
	pass
