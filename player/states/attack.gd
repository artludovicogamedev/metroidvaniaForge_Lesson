class_name AttackState
extends PlayerState

var atkCnt : int = 0 
var attackName : String = "attack"
var attacktimer : float = 0
var attackIsInProgress : bool = false
var attackTimerTimeOut : bool = false
var is_air_attack : bool = false
var combowindow : float = 0 
var timer : float = 0
var playerdir : float = 0 
@export var speed : float = 100
@export var maxAttackCnt = 5

func init() -> void:
	player.attack_timer.timeout.connect(_on_attack_timer_timeout)
	player.idle_timer.timeout.connect(_on_idle_timer_timeout)
	pass
	
func enter() -> void:
	check_player_direction()
	
	if player.is_on_floor():
		MeleeAttackSettings()
	
	if !player.is_on_floor():
		AirAttackSettings()
	pass

func exit() -> void:
	attackTimerTimeOut = false
	attackIsInProgress = false
	next_state = null
	timer = 0
	combowindow = 0
	pass

func handle_input( _event : InputEvent ) -> PlayerState :
	if _event.is_action_pressed("attack"):
		return attack
	return next_state

func process(_delta: float) -> PlayerState:
	if attackTimerTimeOut :
		attackIsInProgress = false
		if atkCnt == 5 or is_air_attack:
			is_air_attack = false
			return fall
		else :
			return idle
	return next_state

func physics_process(delta: float) -> PlayerState:
	timer += delta
	handle_attack_settings(atkCnt)
	return null

func MeleeAttackSettings() -> void :
	if attackIsInProgress == false:
		atkCnt += 1
		player.velocity.x = 0 # pressing forward will move the player for the next attack slightly
		attackTimerTimeOut = false
		attackName = "attack" + str(atkCnt); 
		handle_attack_area_collision(atkCnt)
		player.animation_player.play(attackName)
		player.attack_sfx.play()
		player.idle_timer.stop()
		determine_attack_timer()
		pass
	pass
	
func AirAttackSettings()-> void :
	if attackIsInProgress == false:
		attackTimerTimeOut = false
		is_air_attack = true
		handle_attack_area_collision(8)
		player.animation_player.play("air_attack1")
		player.idle_timer.stop()
		player.attack_sfx.play()
		determine_attack_timer()
		pass
	pass
func _on_attack_timer_timeout() -> void : 
	player.attack_timer.stop()
	attackTimerTimeOut = true
	timer = 0
	pass

func _on_idle_timer_timeout() -> void : 
	player.idle_timer.stop()
	atkCnt = 0
	combowindow = 0
	pass

 
func on_animation_finished(_a : String) -> void :
	pass

func determine_attack_timer() -> void : 
	attacktimer = player.animation_player.current_animation_length
	if atkCnt == 1 :
		combowindow = .5
	if atkCnt == 2 :
		combowindow = .5
	if atkCnt == 3 :
		combowindow = .5
	if atkCnt == 4 :
		combowindow = .5
	if atkCnt == 5 :
		combowindow = .5

	player.idle_timer.start(attacktimer + combowindow)
	player.attack_timer.start(attacktimer)
	pass
func check_player_direction() -> void:
	if player.playersprite.flip_h :
		playerdir = -1
	else :
		playerdir = 1
	pass

func check_for_attck_cnt() -> bool : 
	if( atkCnt > 5) :
		return true
	return false

func handle_attack_settings( cnt : int ) -> void :
	# control player velocity / physics here.
	var attack_count = cnt
	
	#if attack_count == 4 :
		#player.velocity.x = player.velocity.x + (playerdir * 2)
	if attack_count == 5 :
		if timer >= 0.2 and timer <= 0.34 :
			player.velocity.x = player.velocity.x + (playerdir * 2)
			player.velocity.y = -160
			player.attack_area.compute_attack_properties(48,24,18,-20 ,2,1)
		if timer >= 0.6 :
			player.gravity_multiplier = 1.5
	pass

func handle_attack_area_collision( ac : int ) -> void :
	var atckCnt = ac
	
	if atckCnt == 1 :
		player.attack_area.compute_attack_properties(44,70,62,-35 ,1,1)
	
	if atckCnt == 2 :
		player.attack_area.compute_attack_properties(54,18,50,-40 ,1,1)

	if atckCnt == 3 :
		player.attack_area.compute_attack_properties(52,58,68,-35 ,1,1)
		
	if atckCnt == 4 :
		player.attack_area.compute_attack_properties(70,100,60,-50 ,1,1)
		
	if atckCnt == 5 :
		player.attack_area.compute_attack_properties(24,44,28,-38 ,1,1)
	
	if atckCnt == 8 :#air attack
		player.attack_area.compute_attack_properties(64,24,40,-37 ,1,1)
	pass
