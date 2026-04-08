extends PlayerState
class_name PlayerStateCrouch

@export var slowDownSpeed : float = 10

func init() -> void:
	pass
	
func enter() -> void:
	#call this function whenver you enter a new state
	player.animation_player.play("crouch")
	if player.previous_state == attack : 
		player.animation_player.seek(0.15,true) #set to last frame of animnation after attack
		
		
	player.collision_stand.disabled = true
	player.collision_crouch.disabled = false

	player.drop_down_shape_cast.force_shapecast_update()
	#player.player_sprite.scale.y = 0.625
	#player.player_sprite.position.y = -15
	pass

func exit() -> void:
	player.collision_stand.set_deferred("disabled", false)
	player.collision_crouch.set_deferred("disabled", true)
	player.damage_area_stand.set_deferred("disabled", false)
	player.damage_area_crouch.set_deferred("disabled", true)
	
	#player.player_sprite.scale.y = 1.0
	#player.player_sprite.position.y = -24
	pass

func handle_input( _event : InputEvent ) -> PlayerState :
	if _event.is_action_pressed("attack"):
		return attack
		
	if _event.is_action_released("jump"):
		player.drop_down_shape_cast.force_shapecast_update()
		if player.drop_down_shape_cast.is_colliding():
			player.position.y += 4
			return fall
		return jump
		
	if _event.is_action_pressed("action") and player.player_can_morph():
		return morph_ball
		
	return next_state

func process(_delta: float) -> PlayerState:
	if player.direction.y <= 0.5 :
		return idle
	elif player.direction.y > 0.5 :
		return crouch
	return next_state

func physics_process(delta: float) -> PlayerState:
	player.velocity.x -= player.velocity.x * slowDownSpeed * delta
	
	if player.is_on_floor() == false :
		return fall
		
	return next_state
