class_name PlayerBlockBreak
extends PlayerState

var knockbackdirection : float = 1.0
var block_recovery_timer = 0 
@export var movespeed : float = 150

@export var block_recovery_speed : float = 0

func init() -> void:
	pass
	
func enter() -> void:
	player.blocking_area.disabled = true
	player.parry_area_collider.disabled = true
	block_recovery_timer = block_recovery_speed
	player.block_break_sfx.play()
	player.animation_player.play("blockbreak")
	pass

func exit() -> void:
	player.damage_area_stand.disabled = false
	player.damage_area_crouch.disabled = true
	player.blocking_area.disabled = true
	player.parry_area_collider.disabled = true
	block_recovery_timer = 0
	pass

func handle_input( _event : InputEvent ) -> PlayerState :
	return null

func process(_delta: float) -> PlayerState:
	return null

func physics_process(_delta: float) -> PlayerState:
	block_recovery_timer -= _delta 
	player.velocity.x = ( movespeed + player.knockback_force ) * knockbackdirection
	
	if block_recovery_timer <= 0 :
		return idle
		
	return null
