extends Node

@onready var double_jump: TextureRect = %DoubleJump
@onready var dash: TextureRect = %Dash
@onready var ground_slam: TextureRect = %GroundSlam
@onready var morph: TextureRect = %Morph

func _ready() -> void:
	var player : Player = get_tree().get_first_node_in_group("Player")
	double_jump.visible = player.double_jump
	dash.visible = player.dash_skill
	ground_slam.visible = player.ground_slam
	morph.visible = player.morph_roll
