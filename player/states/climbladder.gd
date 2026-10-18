class_name ClimbLadder
extends PlayerState

@export var climbSpeed : float = 120
var entered_from_top : bool = false
var entered_from_below :bool = false
var entered_ladder : bool = false
var duration = 0

func init() -> void:
	pass
	
func enter() -> void:
	print("Entered ladder climb state")
	player.collision_stand.disabled = true
	player.collision_crouch.disabled = true
	player.collision_ledge.disabled = true
	duration = 0
	entered_ladder = true
	player.gravity_multiplier = 0
	pass

func exit() -> void:
	pass

func handle_input( _event : InputEvent ) -> PlayerState :
	if _event.is_action_pressed("jump"):
		player.gravity_multiplier = 1
		duration = 0
		print("Entered Jump state from Ladder Climb state")
		return jump
	return null

func process(_delta: float) -> PlayerState:
	var direction := Input.get_axis("up", "down")
	
	
	
	if entered_ladder :
		if direction != 0:
			player.velocity.y = direction * climbSpeed
		else:
			player.velocity.y = 0
			
		ladder_animation_properties(direction)
		
	if player.can_exit_top_ladder and player.is_on_ladder:
		ladder_exit.check_ladder_exit_direction("exit_top")
		player.can_exit_top_ladder = false
		print("This happens when player pressed down after jumping from ladder")
		return ladder_exit
		
	if player.player_at_bottom_ladder and player.is_on_ladder:
		ladder_exit.check_ladder_exit_direction("exit_bottom")
		print("Player exits from bottom")
		return ladder_exit
		
	return null

func physics_process(_delta: float) -> PlayerState:
	return null

func ladder_animation_properties(directionval : float = 0) -> void :
	var d = directionval 
	if d != 0:
		player.animation_player.play("ladderclimb")
	else:
		player.animation_player.pause()
	pass

func reset_ladder_properties() -> void : 
	player.collision_stand.disabled = false
	player.collision_crouch.disabled = true
	player.collision_ledge.disabled = true
	player.gravity_multiplier = 1
	duration = 0
	pass
