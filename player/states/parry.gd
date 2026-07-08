class_name PlayerParryState
extends PlayerState

@export var hit_particles :Array[HitParticlesSettings]
@export var emission_offset : Vector2 = Vector2.ZERO

var timer = 0 
var duration = 0
func init() -> void:
	pass
	
func enter() -> void:
	player.blocking_area.disabled = true
	player.parry_area_collider.disabled = true
	player.successful_parry = true
	print("Player Parried : " , player.successful_parry)
	player.animation_player.play("parry")
	player.parry_impact_sfx.play()
	duration = player.animation_player.current_animation_length
	
	var pos : Vector2 = player.blocking_area.position + emission_offset
	var dir : Vector2 = Vector2(1 , -1)
	
	for p in hit_particles :
		Visualfx.hit_particles( pos , dir , p)
	pass

func exit() -> void:
	player.damage_area_stand.disabled = false
	player.damage_area_crouch.disabled = true
	player.parry_area_collider.disabled = true
	player.successful_parry = false
	duration = 0
	timer = 0
	pass

func handle_input( _event : InputEvent ) -> PlayerState :
	return null

func process(delta: float) -> PlayerState:
	duration -= delta
	
	if duration <= 0 :
		return idle
		
	return null

func physics_process(_delta: float) -> PlayerState:
	return null
