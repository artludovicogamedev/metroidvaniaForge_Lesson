extends PlayerState
class_name PlayerStateRun


var foot_step_played : bool = false

@export var dashcooldownTime : float = 0.15
var dashcooldownTimer : Timer
var candash : bool = false

#region preloaded audio
const FOOTSTEP1 = preload("uid://b3diyo26xdaah")
const FOOTSTEP2 = preload("uid://b1y6rfnri83vk")
const FOOTSTEP3 = preload("uid://bddhaxqxpxwym")

const FOOTSTEPS = [FOOTSTEP1, FOOTSTEP2, FOOTSTEP3]

#endregion

func init() -> void:
	pass
	
func enter() -> void:
	#play animation
	#call this function whenver you enter a new state
	#dash related variables
	player.hasdashed = false
	candash = true
	player.gravity_multiplier = 1.0
	handle_dash_time_cooldown()
	
	player.animation_player.play("run")
	pass

func exit() -> void:
	pass

func handle_input( _event : InputEvent ) -> PlayerState :
	if _event.is_action_pressed("attack"):
		return attack
		
	if _event.is_action_pressed("jump"):
		return jump
	
	if (_event.is_action_pressed("dash") and player.player_can_dash() and candash):
		return dash
		
	if _event.is_action_pressed("action")and player.player_can_morph():
		return morph_ball
		
	return next_state

func process(_delta: float) -> PlayerState:
	if player.direction.x == 0:
		return idle
	return next_state

func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = player.direction.x * player.movespeed
	
	if (player.playersprite.frame == 14 
	or player.playersprite.frame == 17
	or player.playersprite.frame == 13):
		randomize_footstep_sfx()
	else :
		foot_step_played = false
		
	if player.is_on_floor() == false:
		return fall
	return next_state
	
func randomize_footstep_sfx() -> void :
	if !foot_step_played :
		var fs = FOOTSTEPS.pick_random()
		#Audio.play_spatial_soundfx(fs ,player.global_position , -3 , -6)
		player.footstep_sfx.stream = fs
		player.footstep_sfx.play()
		foot_step_played = true
	pass
	

func handle_dash_time_cooldown() -> void :

	if player.previous_state != dash :
		return
		
	dashcooldownTimer = Timer.new()
	add_child(dashcooldownTimer)
	dashcooldownTimer.one_shot = true
	dashcooldownTimer.wait_time = dashcooldownTime
	dashcooldownTimer.timeout.connect(_on_dashtimer_timeout)
	dashcooldownTimer.start()
	candash = false 
	pass

func _on_dashtimer_timeout() -> void :
	candash	= true
	pass
