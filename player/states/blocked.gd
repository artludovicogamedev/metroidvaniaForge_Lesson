class_name PlayerBlockedState
extends PlayerState

@export var movespeed : float = 100
var knockbackdirection : float = 1.0
var duration 
func init() -> void:
	pass
	
func enter() -> void:
	handle_blocked_properties()
	pass

func exit() -> void:
	player.damage_area_stand.disabled = true
	player.damage_area_crouch.disabled = false
	duration = 0
	pass

func handle_input( _event : InputEvent ) -> PlayerState :
	return null

func process(delta: float) -> PlayerState:
	duration -= delta 
	if duration <= 0 :
		return idle
	return null

func physics_process(_delta: float) -> PlayerState:
	#player.velocity.x = ( movespeed + player.knockback_force ) * knockbackdirection
	return null

func handle_blocked_properties() -> void :
	duration = 0
	player.animation_player.play("blocked")
	duration = player.animation_player.current_animation_length
	#play sfx here
	player.blocked_sfx.play()
	if player.playersprite.flip_h :
		knockbackdirection = 1.0
	else :
		knockbackdirection = -1.0
	player.velocity.x = ( movespeed + player.knockback_force ) * knockbackdirection
	
	pass
