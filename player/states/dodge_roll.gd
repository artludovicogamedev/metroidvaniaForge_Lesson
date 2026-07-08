class_name PlayerStateDodgeRoll
extends PlayerState

@export var invincibility_time : float = 1
@export var dodge_speed : float = 300
@onready var damage_area: DamageArea = %DamageArea

var dodge_timer : float = 0 
var duration : float = 0 
var dodge_direction : int = 1
func init() -> void:
	pass

func enter() -> void:
	#call this function whenver you enter a new state
	dodge_timer = invincibility_time
	get_dodge_direction()
	Visualfx.create_land_dust_fx(player.global_position)
	player.dodge_roll_sfx.play()
	player.velocity.y = -250
	player.gravity_multiplier = 1.5
	player.velocity.x = dodge_speed * dodge_direction
	damage_area.make_invulnerable(invincibility_time)
	player.animation_player.play("dodgeroll")
	pass

func exit() -> void:
	pass

func handle_input( _event : InputEvent ) -> PlayerState :
	return next_state

func process(delta: float) -> PlayerState:
	dodge_timer -= delta 
	if dodge_timer <= 0 :
		if player.is_on_floor():
			Visualfx.create_land_dust_fx(player.global_position)
			return idle
	return next_state

func physics_process(_delta: float) -> PlayerState:
	return next_state

 
func get_dodge_direction() -> void:
	if player.playersprite.flip_h :
		dodge_direction = -1
	else :
		dodge_direction = 1
	pass
