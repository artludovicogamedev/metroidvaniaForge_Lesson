extends PlayerState
class_name PlayerStateIdle

@export var dashcooldownTime : float = 0.15
var dashcooldownTimer : Timer
var candash : bool = false

func init() -> void:
	pass
	
func enter() -> void:
	#dash related variables
	player.hasdashed = false
	candash = true
	player.gravity_multiplier = 1.0
	handle_dash_time_cooldown()
	
	player.animation_player.play("idle")
	pass

func exit() -> void:
	pass

func handle_input( _event : InputEvent ) -> PlayerState :
	if (_event.is_action_pressed("dash") and player.player_can_dash() and candash):
		return dash
		
	if _event.is_action_pressed("attack"):
		return attack
		
	if _event.is_action_pressed("jump"):
		return jump

	if _event.is_action_pressed("action") and player.player_can_morph():
		return morph_ball
		
	return next_state

func process(_delta: float) -> PlayerState:
	if player.direction.x != 0 :
		return run
	elif player.direction.y > 0.5 :
		return crouch
	return next_state

func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = 0
	if player.is_on_floor():
		#player.add_debugger(Color.DARK_BLUE)
		return idle
	return next_state

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
