@icon("res://general/icons/player_sensor.svg")
class_name PLayerSensor
extends Area2D

signal player_entered
signal player_exited
signal start_search 


@export var search_duration : float = 2.0

var enemy : Enemy
var timer : float
var use_audio_sensor : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_collision_mask_value(1,false)
	set_collision_layer_value(1,false)
	
	if owner is Enemy :
		enemy = owner
		set_collision_mask_value(5,true)
		body_entered.connect(on_body_entered)
		body_entered.connect(on_body_exited)
		enemy.direction_changed.connect(on_direction_changed)
		
		if use_audio_sensor :
			Audio.player_made_sound.connect(_on_player_made_sound)
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if timer > 0 :
		timer -=delta
		if timer <= 0 :
			player_exited.emit()
			enemy.blackboard.target = null
	pass

func on_body_entered(n : Node2D) -> void :
	player_entered.emit()
	enemy.blackboard.target = n
	timer = 0
	pass
	
func on_body_exited(_n : Node2D) -> void :
	start_search.emit()
	timer = search_duration
	pass

func on_direction_changed(dir : float) -> void :
	if dir < 0 :
		scale.x = -1
	elif dir > 0:
		scale.x = 1
	pass

func _on_player_made_sound ( pos : Vector2 , volume : float ) -> void :
	print("player made sound " , pos , "|" , volume)
	pass
