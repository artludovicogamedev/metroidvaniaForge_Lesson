class_name BSJumpChase
extends EnemyState

@export var cooldown : float = 3.0
@export var jump_force := Vector2(0,-300)
var on_cooldown : bool = false 
var duration : float = 0
var timer : float = 0

func enter() -> void:
	print("you entered the jump state : ")
	var anim : String = animation_name if animation_name else "Jump"
	enemy.play_animation(anim)
	duration = enemy.animation.current_animation_length
	timer = 0
	var dir := -1 if enemy.sprite.flip_h else 1
	
	enemy.velocity.x = jump_force.x * dir
	enemy.velocity.y = jump_force.y
	
	blackboard.can_decide = false
	blackboard.punishattack = true
	blackboard.just_attacked = false
	
	print("you entered the jump state and Punish Window is " , blackboard.punishattack) 
	on_cooldown = true
	pass
	
func re_enter() -> void :
	pass

func exit() -> void :
	blackboard.can_decide = true
	enemy.animation.pause()
	set_fall_frame()
	run_chase_cooldown()
	pass

func physics_update(_delta: float) -> void:
	timer += _delta
	
	if timer >= duration:
		blackboard.can_decide = true
	pass

func decide_to_jump() -> bool :
	if blackboard.distance_to_target > 120 and not on_cooldown:
		return true
	return false

func run_chase_cooldown() -> void :
	await get_tree().create_timer(cooldown).timeout
	on_cooldown = false
	pass

func set_fall_frame() -> void:
	enemy.animation.seek(03 ,true)
	pass

func reset_attack_paramaters() -> void :
	if blackboard.wall_detected : 
		print("compute jump distance here")
		#enemy.update_jump_coordinates()
	pass
