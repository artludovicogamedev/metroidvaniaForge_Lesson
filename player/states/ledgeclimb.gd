class_name PlayerStateLedgeClimb
extends PlayerState

var timer : float = 0 
var duration : float = 0 
var playerdir : int = 0
func init() -> void:
	pass

func enter() -> void:
	timer = 0 
	duration = 0 
	player.animation_player.play("ledgeclimb")
	check_player_direction()
	duration = player.animation_player.current_animation_length
	player.collision_stand.disabled = true
	player.collision_ledge.disabled = false
	player.collision_crouch.disabled = true
	player.velocity.y= -320
	pass

func exit() -> void:
	player.collision_stand.set_deferred("disabled", true)
	player.collision_crouch.set_deferred("disabled", true)
	player.collision_ledge.set_deferred("disabled", true)
	player.damage_area_stand.set_deferred("disabled", false)
	player.damage_area_crouch.set_deferred("disabled", true)
	pass

func handle_input( _event : InputEvent ) -> PlayerState :
	return next_state

func process(_delta: float) -> PlayerState:
	return next_state

func physics_process(delta: float) -> PlayerState:
	timer += delta
	if timer > duration :
		player.velocity.x = player.velocity.x + (playerdir * 350)
		player.can_move = true
		return fall
	return next_state

func _on_ledge_timer_out()-> void :
	pass

func check_player_direction() -> void:
	if player.playersprite.flip_h :
		playerdir = -1
	else :
		playerdir = 1
	pass
