class_name MorphBall

extends PlayerState

const MORPH_SFX = preload("uid://e45goqfir0go")
const MORPH_OUT_SFX = preload("uid://dkltvno0vbou6")
@onready var ball_raycast_up: RayCast2D = %BallRaycastUp
@onready var ball_raycast_down: RayCast2D = %BallRaycastDown



@export var jumpvelocity : float = 400
var on_floor : bool = true


func init() -> void:
	pass
	
func enter() -> void:
	player.animation_player.play("ball")
	Audio.play_spatial_soundfx(MORPH_SFX,player.global_position)
	player.velocity.y -= 80
	adjust_ball_collision()
	pass

func handle_input( _event : InputEvent ) -> PlayerState:
	if _event.is_action_pressed("action"):
		if player_can_stand():
			if !player.is_on_floor():
				return fall
			elif player.is_on_floor():
				return idle
	
	if _event.is_action_pressed("jump"):
		if player.is_on_floor():
			if Input.is_action_pressed("down"):
				player.drop_down_shape_cast.force_shapecast_update()
				if player.drop_down_shape_cast.is_colliding():
					player.position.y += 4
					return null
			Visualfx.create_jump_dust_fx(player.global_position)
			player.jump_sfx.play()
			player.velocity.y -= jumpvelocity
	return next_state
	
func process(_delta: float) -> PlayerState:
	if player.direction.x == 0 :
		player.animation_player.speed_scale = 0
	else :
		player.animation_player.speed_scale = 1
	return next_state

func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = player.direction.x * player.movespeed
	
	if on_floor :
		if not player.is_on_floor():
			on_floor = false
	
	else :
		if player.is_on_floor():
			on_floor = true
			Visualfx.create_land_dust_fx(player.global_position)
			player.land_sfx.play()
	return next_state

func exit() -> void:
	var shape :CapsuleShape2D = player.collision_stand.get_shape() as CapsuleShape2D
	shape.radius = 8.0
	shape.height = 46.0
	Audio.play_spatial_soundfx(MORPH_OUT_SFX,player.global_position)
	player.collision_stand.position.y = -23
	player.damage_area_stand.position.y = -23
	player.animation_player.speed_scale = 1
	player.velocity.y = -120
	
func adjust_ball_collision() -> void : 
	var shape :CapsuleShape2D = player.collision_stand.get_shape() as CapsuleShape2D
	shape.radius = 11.0
	shape.height = 22.0
	player.collision_stand.position.y = -11
	player.damage_area_stand.position.y = -11

func player_can_stand() -> bool :
	ball_raycast_down.force_raycast_update()
	ball_raycast_up.force_raycast_update()
	if ball_raycast_down.is_colliding() and ball_raycast_up.is_colliding():
		return false
	return true
