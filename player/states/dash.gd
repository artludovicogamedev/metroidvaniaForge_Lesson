class_name DashState
extends PlayerState

#create a dash timer using float 
#create dash time / used as default value on how long player can dash
@export var dashDuration : float = 0.2 #how long player can dash
@export var effectDuration : float = 0.2
@export var dashvelocity : float = 800
@export var effect_delay : float = 0.05
@onready var damage_area: DamageArea = %DamageArea

#@onready var slideTimer : Timer

var dashdirection : float = 1
var dashtimer : float = 0
var effects_time : float = 0

var origdashDuration : float = 0


func init() -> void:
	pass
	
func enter() -> void:
	dashtimer = dashDuration
	damage_area.make_invulnerable(dashDuration)
	player.animation_player.play("dash")
	player.dash_sfx.play()
	player.velocity.y  = 0
	player.gravity_multiplier = 0
	player.playersprite.create_tween_fx(dashDuration)
	
	pass
	
func process(delta: float) -> PlayerState:
	dashtimer -= delta
	if dashtimer <= 0 :
		if player.is_on_floor():
			return idle
		else:
			return fall
	effects_time -= delta
	
	if effects_time < 0 :
		effects_time = effectDuration
		player.playersprite.create_player_afterimage()
		
	return next_state

func physics_process(_delta: float) -> PlayerState:
	if player.hasdashed == true :
		return next_state
		
	get_dash_direction()
	player.velocity.x = ( dashvelocity * (dashtimer / dashDuration) + dashvelocity ) * dashdirection
	return next_state
	
func exit() -> void:
	player.hasdashed = true
	pass
	
func get_dash_direction() -> void : 
	dashdirection = 1.0 
	if player.playersprite.flip_h == true :
		dashdirection = -1.0
	pass
	
 
