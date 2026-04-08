class_name Player
extends CharacterBody2D

const DEBUGGER = preload("uid://db0arhrb4qi4x")

#region /// signals
signal damage_taken()
#endregion
#region /// onready variables

@onready var playersprite: PlayerSprite = %playersprite
@onready var attack_playersprite: Sprite2D = %AttackSprite2D
@onready var collision_stand: CollisionShape2D = %CollisionStand
@onready var collision_crouch: CollisionShape2D = %CollisionCrouch
 
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var drop_down_shape_cast: ShapeCast2D = %DropDownShapeCast
@onready var ground_slam_shape_cast: ShapeCast2D = %GroundSlamShapeCast
@onready var walljumpleftraycast: RayCast2D = %walljumpleftraycast
@onready var walljumprightraycast: RayCast2D = %walljumprightraycast


@onready var point_light_2d: PointLight2D = %PointLight2D
@onready var cur_hp: Label = $Debugger/curHp
 
@onready var damage_area_stand: CollisionShape2D = %DamageAreaStand
@onready var damage_area_crouch: CollisionShape2D = %DamageAreaCrouch

@onready var attack_area: AttackArea = %AttackArea
@onready var damage_area: DamageArea = %DamageArea
@onready var ground_slam_attack_area: AttackArea = %GroundSlamAttackArea

#region // audio
@onready var hurt_sfx: AudioStreamPlayer2D = %HurtSFX
@onready var jump_sfx: AudioStreamPlayer2D = %JumpSFX
@onready var land_sfx: AudioStreamPlayer2D = %LandSFX
@onready var attack_sfx: AudioStreamPlayer2D = %AttackSFX
@onready var footstep_sfx: AudioStreamPlayer2D = %FootstepSFX
@onready var dash_sfx: AudioStreamPlayer2D = %DashSFX

#endregion

#endregion
#region /// export variables 
@export var player_hp : float = 20 :
	set( value ) :
		player_hp = clampf(value, 0 , player_max_hp)
		Messages.player_hp_changed.emit(player_hp, player_max_hp)
		
@export var player_max_hp : float = 20 :
	set( value ) :
		player_max_hp = value
		Messages.player_hp_changed.emit(player_hp, player_max_hp)

@export var player_mp : float = 20 :
	set( value ) :
		player_mp = clampf(value, 0 , player_max_mp)
		Messages.player_mp_changed.emit(player_mp, player_max_mp)
		
@export var player_max_mp : float = 20 :
	set( value ) :
		player_max_mp = value
		Messages.player_mp_changed.emit(player_mp, player_max_mp)

@export var double_jump : bool = false
@export var dash_skill : bool = false
@export var ground_slam : bool = false
@export var morph_roll : bool = false

@export var light_source_energy : float = 0.7
@export var movespeed : float = 150
@export var maxfallspeed : float = 600

@export var dashTimeCooldown : float = 0.1
@export var attackTimerCooldown : float = 0.2
#endregion

#region /// state machine variables 
var states : Array[PlayerState]

var current_state : PlayerState : # placeholder 
	get : return states.front() # returns first element of array 

var previous_state : PlayerState :
	get : return states[1]
	
#endregion

#region /// standard variables

var direction : Vector2 = Vector2.ZERO
var gravity : float = 980
var gravity_multiplier : float = 1.0
var hasdashed : bool = false
var caninteract : bool = false
#endregion

func _ready() -> void:
	#clear player if is already preset in node
	point_light_2d.energy = light_source_energy
	player_hp = player_max_hp
	player_mp = player_max_mp
	cur_hp.text = "HP:" + str(int(player_hp)) + "/" + str(int(player_max_hp))
	

	
	if get_tree().get_first_node_in_group("Player") != self:
		self.queue_free()	
	
	Messages.player_healed.connect(on_player_healed)
	Messages.back_to_title.connect(queue_free)
	Messages.input_hint_changed.connect(on_input_hint_changed)
	damage_area.damage_taken.connect(on_damage_taken)
	point_light_2d.enabled = false
	
	initialize_states()
	self.call_deferred("reparent" , get_tree().root)

func _process(_delta: float) -> void:
	update_direction()
	change_state( current_state.process(_delta))
	pass

func _physics_process(_delta: float) -> void:
	#apply player gravity (basic implementation for now)
	velocity.y += gravity * _delta * gravity_multiplier
	velocity.y = clampf(velocity.y , -1000.0 , maxfallspeed)
	move_and_slide()
	change_state( current_state.physics_process(_delta))
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("jump") and velocity.y < 0 :
		velocity.y *= 0.5
	
	if event.is_action_pressed("action"):
		Messages.player_interacted.emit(self)
	
	elif event.is_action_pressed("pause"):
		get_tree().paused = true
		var pause_menu : PauseMenu = load("res://UI/pauseMenu/PauseMenu.tscn").instantiate()
		add_child(pause_menu)
		return
	
	change_state( current_state.handle_input(event))
	
	pass
	
func initialize_states() -> void:
	#function setup the state machine  
	states = []
	
	#gather all states under State node
	for c in $States.get_children():
		if c is PlayerState:
			states.append(c)
			c.player = self
			 
	#usually prevent bugs 
	if states.size() == 0:
		return
		
	#initialize state 
	for state in states:
		state.init()
	
	change_state(current_state) #grab first state / IDLE
	current_state.enter() # this is the first enter state called through out the game.
	$Label.text = current_state.name
	
	pass
	
func change_state(new_state : PlayerState) -> void:
	#makes sure that a state passed in is valid 
	#makes sure that the state is not the current state
	if new_state == null :
		return
	elif new_state == current_state:
		return
		
	if current_state :
		current_state.exit()
	
	states.push_front( new_state ) 	#pushes new state as current state
	current_state.enter()
	
	states.resize(3) #prevents states array from having so many stored states
	$Label.text = current_state.name
	pass

func update_direction() -> void :
	var prev_direction : Vector2 = direction
	#this code is intended only for game designs that doesnt use the thumb stick
	#direction = Input.get_vector("left","right","up","down")
	
	# this code will handle design where you use a controller with thumb stick
	var x_axis = Input.get_axis("left","right")
	var y_axis = Input.get_axis("up","down")
	
	direction = Vector2(x_axis,y_axis)
	
	if prev_direction.x != direction.x :
		attack_area.flipattack(direction.x)
		
		if direction.x < 0 :
			#left
			playersprite.flip_h = true
			attack_playersprite.flip_h = true
			attack_playersprite.position.x = -32
		elif direction.x > 0 :
			#right
			playersprite.flip_h = false
			attack_playersprite.flip_h = false
			attack_playersprite.position.x = 32
	pass

func enable_point_light_2d(value : bool) -> void :
	point_light_2d.enabled = value
	pass

func add_debugger( color : Color = Color.RED) -> void :
	var d : Node2D = DEBUGGER.instantiate()
	get_tree().root.add_child(d)
	d.global_position = global_position
	d.modulate = color
	await get_tree().create_timer(3.0).timeout
	d.queue_free()
	pass

func on_player_healed( amount : float )->void : 
	player_hp += amount
	
	if player_hp > player_max_hp:
		player_hp = player_max_hp
		
	cur_hp.text = "HP:" + str(int(player_hp)) + "/" + str(int(player_max_hp))
	pass

func on_damage_taken(attackarea: AttackArea) -> void :
	if current_state == current_state.death :
		return
	player_hp -= attackarea.attack_damage
	damage_taken.emit()
	pass

func on_input_hint_changed(inputhint : String) -> void :
	if inputhint == "interact" :
		caninteract = true
	else :
		caninteract = false
		pass

func player_can_dash( ) -> bool :
	return dash_skill and not hasdashed

func player_can_morph() -> bool :
	if morph_roll == false or caninteract:
		return false
	return true
