extends PlayerState
class_name PlayerStateFall

@export var fall_gravity_multiplier : float = 1.165
@export var coyoteTime: float = 0.125
@export var jumpBufferTime : float = 0.22
@export var beforelandingTime : float = 1.5
@export var kickfromwall : float = 200
@export var dashcooldownTime : float = 0.15

var landingtimer : float = 0
var coyoteTimer : float = 0
var bufferTimer : float = 0


var dashcooldownTimer : Timer
var candash : bool = false

var playerHasDoubleJumped : bool = false
var origvolume : float = 0

func init() -> void:
	pass
	
func enter() -> void:
	#dash related variables
	player.gravity_multiplier = 1.0
	handle_dash_time_cooldown()
	
	player.animation_player.play("jump")
	player.animation_player.pause()
	landingtimer = beforelandingTime
	origvolume = player.land_sfx.volume_db
	can_wall_jump()
	player.gravity_multiplier = fall_gravity_multiplier #increases gravity fall velocity during fall
	if player.previous_state == jump || player.previous_state == attack || player.previous_state == dash:
		coyoteTimer = 0
	else :
		coyoteTimer = coyoteTime
	pass

func exit() -> void:
	bufferTimer = 0
	player.land_sfx.volume_db = origvolume
	player.gravity_multiplier = 1.0 # reset gravity to default
	pass

func handle_input( event : InputEvent ) -> PlayerState :
	if event.is_action_pressed("action") and player.player_can_morph():
		return morph_ball
		
	if event.is_action_pressed("dash") and player.player_can_dash() and candash:
		return dash
		
	if event.is_action_pressed("attack"):
		if player.ground_slam and Input.is_action_pressed("down"):
			return ground_slam
		return attack
		
	if event.is_action_pressed("jump"):
		if coyoteTimer > 0:
			return jump
		
		if can_wall_jump():
			return jump
			
		elif playerHasDoubleJumped == false and player.double_jump : 
			playerHasDoubleJumped = true
			return jump
		else :
			bufferTimer = jumpBufferTime

	return next_state

func process(delta: float) -> PlayerState:
	coyoteTimer -= delta
	bufferTimer -= delta
	landingtimer -= delta
	set_fall_frame()
	return next_state

func physics_process(_delta: float) -> PlayerState:
	if player.is_on_floor():
		
		playerHasDoubleJumped = false
		candash = true
		Visualfx.create_land_dust_fx(player.global_position)
		#player.add_debugger(Color.DARK_BLUE)
		#Audio.play_spatial_soundfx(LANDDOWNSFX ,player.global_position , -3 , -11)
		player.land_sfx.play()
		
		if landingtimer < 0 :
			player.land_sfx.volume_db += 5
		if bufferTimer > 0 :
			return jump
		player.land_sfx.volume_db = 0
		return idle
	
	if can_wall_jump():
		player.velocity.x = player.direction.x * kickfromwall
	else:
		player.velocity.x = player.direction.x * player.movespeed
	return next_state

func set_fall_frame() -> void:
	var frame : float = remap(player.velocity.y ,0.0,player.maxfallspeed,0.5,1.0)
	player.animation_player.seek( frame , true )
	pass

func can_wall_jump() -> bool : 
	player.walljumpleftraycast.force_raycast_update()
	player.walljumprightraycast.force_raycast_update()
	
	if (player.walljumpleftraycast.is_colliding() or 
		player.walljumprightraycast.is_colliding()):
		return true 
	
	return false

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
	pass
