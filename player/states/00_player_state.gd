@icon("res://player/states/state.svg")
class_name PlayerState extends Node

var player : Player
var next_state : PlayerState

#region /// state references

# must contain a reference to all other states 

@onready var idle: PlayerStateIdle = %Idle
@onready var run: PlayerStateRun = %Run
@onready var jump: PlayerStateJump = %Jump
@onready var fall: PlayerStateFall = %Fall
@onready var crouch: PlayerStateCrouch = %Crouch
#@onready var dash: DashState = %Dash
@onready var attack: AttackState = %Attack
@onready var hurt: PlayerHurtState = %Hurt
@onready var death: DeathState = %Death
#@onready var ground_slam: GroundSlam = %GroundSlam
#@onready var morph_ball: MorphBall = %MorphBall
@onready var ledge_hang: PlayerStateLedgeHang = %LedgeHang
@onready var ledge_climb: PlayerStateLedgeClimb = %LedgeClimb
@onready var dodge_roll: PlayerStateDodgeRoll = %DodgeRoll
@onready var block: PlayerBlockState = %Block
@onready var parry: PlayerParryState = %Parry
@onready var block_break: PlayerBlockBreak = %BlockBreak
@onready var blocked: PlayerBlockedState = %Blocked



#endregion


func init() -> void:
	pass

func enter() -> void:
	#call this function whenver you enter a new state
	pass

func exit() -> void:
	pass

func handle_input( _event : InputEvent ) -> PlayerState :
	return next_state

func process(_delta: float) -> PlayerState:
	
	return next_state

func physics_process(_delta: float) -> PlayerState:
	return next_state
