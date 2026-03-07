class_name Player
extends CharacterBody2D

const DEBUGGER = preload("uid://db0arhrb4qi4x")

#region /// onready variables

@onready var player_sprite: Sprite2D = $Sprite2D
@onready var collision_stand: CollisionShape2D = $CollisionStand
@onready var collision_crouch: CollisionShape2D = $CollisionCrouch
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var drop_down_shape_cast: ShapeCast2D = %DropDownShapeCast
@onready var point_light_2d: PointLight2D = %PointLight2D


#endregion
#region /// export variables 
@export var movespeed : float = 150
@export var maxfallspeed : float = 600
@export var doubleJumpUnlocked : bool = false
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

#endregion

func _ready() -> void:
	#clear player if is already preset in node
	
	if get_tree().get_first_node_in_group("Player") != self:
		self.queue_free()
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
		if direction.x < 0 :
			player_sprite.flip_h = true
		elif direction.x > 0 :
			player_sprite.flip_h = false
	pass

func enable_point_light_2d(value : bool) -> void :
	print("call function : " + str(value))
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
