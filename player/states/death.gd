class_name DeathState
extends PlayerState


const DEATH_OST = preload("uid://buonel7qknouj")
func init() -> void:
	pass
	
func enter() -> void:
	player.animation_player.play("death") 
	player.hurt_sfx.play()
	Audio.play_music(DEATH_OST)
	await player.animation_player.animation_finished
	PlayerHud.show_game_over_screen()
	player.velocity.x = 0
	pass

func exit() -> void:
	Audio.play_music(null)
	pass

func handle_input( _event : InputEvent ) -> PlayerState :
	return null

func process(_delta: float) -> PlayerState:
	
	return null

func physics_process(_delta: float) -> PlayerState:
	return null

func _return_to_title() -> void :
	pass
