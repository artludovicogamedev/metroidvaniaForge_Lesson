extends PlayerState
class_name PlayerStateJump

@export var jumpvelocity : float = 450
@export var dashcooldownTime : float = 0.15
var dashcooldownTimer : Timer
var candash : bool = false

#@export var jumpmovespeed : float = 150

func init() -> void:
	pass
	
func enter() -> void:
	#dash related variables
	player.gravity_multiplier = 1.0
	handle_dash_time_cooldown()
	
	Visualfx.create_jump_dust_fx(player.global_position)
	player.jump_sfx.play()
	player.animation_player.play("jump")
	player.animation_player.pause()
	#player.add_debugger(Color.FOREST_GREEN)
	player.velocity.y = 0
	player.velocity.y = -jumpvelocity
	
	#check if buffer timer is triggered
	if player.previous_state == fall and not Input.is_action_pressed("jump"):
		await get_tree().physics_frame
		player.velocity.y *= 0.5
		player.change_state(fall) # manually change to fall because we cant return a state in the enter function
	pass

func exit() -> void:
	#player.add_debugger(Color.YELLOW)
	pass

func handle_input( event : InputEvent ) -> PlayerState :
	if event.is_action_pressed("dash") and player.player_can_dash():
		return dash
		
	if event.is_action_pressed("attack"):
		if player.ground_slam and Input.is_action_pressed("down"):
			return ground_slam
		return attack
		
	if event.is_action_released("jump"):
		player.velocity.y *= 0.5
		return fall
		
	if event.is_action_pressed("action") and player.player_can_morph():
		return morph_ball
		
	return next_state

func process(_delta: float) -> PlayerState:
	set_jump_frame()
	return next_state

func physics_process(_delta: float) -> PlayerState:
	if player.is_on_floor():
		return idle
		
	elif player.velocity.y >= 0 : 
		return fall
	
	player.velocity.x = player.direction.x * player.movespeed
	return next_state

func set_jump_frame() -> void:
	var frame : float = remap(player.velocity.y ,-jumpvelocity ,0.0,0.0,0.5)
	player.animation_player.seek( frame , true )
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
