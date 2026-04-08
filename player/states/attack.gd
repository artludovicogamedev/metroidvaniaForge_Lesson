class_name AttackState
extends PlayerState

const SLASH_AUDIO = preload("uid://cfelmr0dc4te3")

@export var combotimewindow : float = 0.1
@export var speed : float = 150

#Dash
@export var dashcooldownTime : float = 0.15
var dashcooldownTimer : Timer
var candash : bool = false

var attackfinished : bool = false
var attacktimer : float = 0
var combocounter : int = 0

@onready var attack_sprite_2d: Sprite2D = %AttackSprite2D

func init() -> void:
	attack_sprite_2d.visible = false
	pass
	
func enter() -> void:
	player.hasdashed = false
	candash = true
	handle_dash_time_cooldown()
	
	player.attack_area.visible = true
	AttackSequence()
	player.animation_player.animation_finished.connect(on_animation_finished)
	pass

func exit() -> void:
	attacktimer = 0
	combocounter = 0
	attack_sprite_2d.visible = false
	player.animation_player.animation_finished.disconnect(on_animation_finished)
	next_state = null
	pass

func handle_input( _event : InputEvent ) -> PlayerState :
	if _event.is_action_pressed("dash") and player.player_can_dash():
		return dash
		
	if _event.is_action_pressed("attack"):
		attacktimer = combotimewindow
	return next_state

func process(delta: float) -> PlayerState:
	attacktimer -= delta
	player.velocity.x = player.direction.x * speed
	return next_state

func physics_process(_delta: float) -> PlayerState:
	return null

func AttackSequence() -> void :
	attack_sprite_2d.visible = true
	var animname : String = "attack1"
	
	if combocounter > 0 :
		animname = "attack2"
	
	if player.previous_state == crouch :
		animname = "attack_crouch1"
	
	player.animation_player.play(animname)
	player.attack_area.active_area()
	#Audio.play_spatial_soundfx(SLASH_AUDIO , player.global_position , 0 ,5)
	player.attack_sfx.play()
	pass

func on_animation_finished(_a : String) -> void :
	end_attack()
	pass

func end_attack()-> void :
	if attacktimer > 0 :
		combocounter = wrapi(combocounter + 1 , 0 , 2)
		AttackSequence()
	else:
		if player.is_on_floor():
			if player.previous_state == crouch :
				next_state = crouch 
			else :
				next_state = idle
		else :
			next_state = fall
	pass

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
