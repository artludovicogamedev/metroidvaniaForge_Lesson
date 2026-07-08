class_name Player
extends CharacterBody2D

const DEBUGGER = preload("uid://db0arhrb4qi4x")

#region /// signals
signal damage_taken()
#endregion
#region /// onready variables

@onready var playersprite: PlayerSprite = %PlayerSprite
@onready var attack_playersprite: Sprite2D = %AttackSprite2D
@onready var collision_stand: CollisionShape2D = %CollisionStand
@onready var collision_crouch: CollisionShape2D = %CollisionCrouch
@onready var collision_ledge: CollisionShape2D = %CollisionLedge
#@onready var collision_ledge_hang: CollisionShape2D = $CollisionLedgeHang
@onready var hang_point: Marker2D = %HangPoint
@onready var world_center: Marker2D = %world_center
@onready var hang_corner: Marker2D = %hang_corner


#@onready var hang_offset := global_position - hang_point.global_position

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var drop_down_shape_cast: ShapeCast2D = %DropDownShapeCast
@onready var ground_slam_shape_cast: ShapeCast2D = %GroundSlamShapeCast #not needed
@onready var walljumpleftraycast: RayCast2D = %walljumpleftraycast
@onready var walljumprightraycast: RayCast2D = %walljumprightraycast
@onready var ledgegrabtop: RayCast2D = %ledgegrabtop
@onready var ledgegrabbottom: RayCast2D = %ledgegrabbottom
@onready var platformbelow: RayCast2D = %platformbelow

@onready var platformabove: RayCast2D = %platformabove
@onready var camera_2d: PlayerCamera = %Camera2D
@onready var point_light_2d: PointLight2D = %PointLight2D
#@onready var cur_hp: Label = $Debugger/curHp

@onready var attack_area: AttackArea = %AttackArea
@onready var damage_area: DamageArea = %DamageArea
@onready var parry_area: ParryArea = %ParryArea

@onready var damage_area_stand: CollisionShape2D = %DamageAreaStand
@onready var damage_area_crouch: CollisionShape2D = %DamageAreaCrouch 
@onready var blocking_area: CollisionShape2D = %BlockingArea
@onready var parry_area_collider: CollisionShape2D = %ParryAreaCollider

#@onready var ground_slam_attack_area: AttackArea = %GroundSlamAttackArea
#@onready var test_alert_label: Label = %Label2 #not needed


#region // audio
@onready var hurt_sfx: AudioStreamPlayer2D = %HurtSFX
@onready var jump_sfx: AudioStreamPlayer2D = %JumpSFX
@onready var land_sfx: AudioStreamPlayer2D = %LandSFX
@onready var attack_sfx: AudioStreamPlayer2D = %AttackSFX
@onready var footstep_sfx: AudioStreamPlayer2D = %FootstepSFX
@onready var dash_sfx: AudioStreamPlayer2D = %DashSFX
@onready var dodge_roll_sfx: AudioStreamPlayer2D = %DodgeRollSFX
@onready var parry_impact_sfx: AudioStreamPlayer2D = %ParryImpactSFX
@onready var blocked_sfx: AudioStreamPlayer2D = %BlockedSFX
@onready var block_break_sfx: AudioStreamPlayer2D = %BlockBreakSFX

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

#block hit points
@export var player_bp : float = 10 :
	set( value ) :
		player_bp = clampf(value, 0 , player_max_bp)
		Messages.player_bp_changed.emit(player_bp, player_max_bp)

@export var player_max_bp : float = 10 :
	set( value ) :
		player_max_bp = value
		Messages.player_bp_changed.emit(player_bp, player_max_bp)

@export var player_hp_regen_rate : float = 1.0
@export var player_mp_regen_rate : float = 1.0
@export var player_block_regen_rate : float = 1.0
@export var double_jump : bool = false
@export var dash_skill : bool = false
@export var ground_slam : bool = false #not used
@export var morph_roll : bool = false #not used

@export var light_source_energy : float = 0.7
@export var movespeed : float = 150
@export var maxfallspeed : float = 600

@export var dashTimeCooldown : float = 0.1
@export var attackTimerCooldown : float = 0.2

#tile map coordinates /#ledge hanging variables
var collisionTiles : TileMapLayer
var ledgeDirection : Vector2 = Vector2.ZERO
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
var knockback_force : float = 0
var can_move : bool = true
var alert_player : bool = false
var ledge_direction : Vector2 = Vector2.ZERO
var successful_parry : bool = false
#endregion


#region /// timers
@onready var attack_timer: Timer = %AttackTimer
@onready var idle_timer: Timer = %IdleTimer
@onready var combo_timer: Timer = %ComboTimer
@onready var ledge_timer: Timer = %LedgeTimer

#endregion 
func _ready() -> void:
	#clear player if is already preset in node
	point_light_2d.energy = light_source_energy
	player_hp = player_max_hp
	player_mp = player_max_mp

	
	if get_tree().get_first_node_in_group("Player") != self:
		self.queue_free()	
	
	Messages.player_healed.connect(on_player_healed)
	Messages.back_to_title.connect(queue_free)
	Messages.input_hint_changed.connect(on_input_hint_changed)
	SceneManager.play_cinematic.connect(on_cinematic_mode)
	SceneManager.cinematic_sequence_finished.connect(on_cinematic_finished)
	damage_area.damage_taken.connect(on_damage_taken)
	damage_area.block_damage_taken.connect(on_block_damage_taken)
	point_light_2d.enabled = false
	
	initialize_states()
	self.call_deferred("reparent" , get_tree().root)

func _process(_delta: float) -> void:
	if not can_move :
		return
	recover_block_hp(_delta)
	update_raycast_facing()
	update_direction()
	change_state( current_state.process(_delta))
	pass

func _physics_process(_delta: float) -> void:
	if can_move == false :
		return
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
	#$Label.text = current_state.name
	
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
	#$Label.text = current_state.name
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

func update_raycast_facing()-> void :
	if playersprite.flip_h == true:
		ledgegrabtop.rotation_degrees = 180
		ledgegrabbottom.rotation_degrees = 180
		ledgeDirection = Vector2.RIGHT
		hang_point.position.x = -11		
		
	if playersprite.flip_h == false:
		ledgegrabtop.rotation_degrees = 0
		ledgegrabbottom.rotation_degrees = 0
		ledgeDirection = Vector2.LEFT
		hang_point.position.x = 11
	pass
	
func get_hang_offset() -> Vector2:
	return global_position - hang_point.global_position
	
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
	#cur_hp.text = "HP:" + str(int(player_hp)) + "/" + str(int(player_max_hp))
	pass

func on_damage_taken(attackarea: AttackArea) -> void :
	if current_state == current_state.death or current_state == current_state.block:
		return
		
	player_hp -= attackarea.attack_damage
	knockback_force = attackarea.knockback_damage
	damage_taken.emit()
	pass

func on_block_damage_taken(attackarea: AttackArea) -> void :
	if current_state == current_state.death or current_state != current_state.block:
		return
	player_bp -= attackarea.attack_damage
	knockback_force = attackarea.knockback_damage
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

func on_cinematic_mode() -> void :
	#test_alert_label.visible = true
	alert_player = true

func on_cinematic_finished() -> void :
	SceneManager.play_cinematic.disconnect(on_cinematic_mode)
	can_move = true
	#test_alert_label.visible = false
	alert_player = false

func recover_block_hp (d) -> void :
	var deltatime = d
	if player_bp >= player_max_bp:
		player_bp = player_max_bp

	player_bp = player_bp + ( player_max_bp * player_block_regen_rate ) * deltatime 
	pass
