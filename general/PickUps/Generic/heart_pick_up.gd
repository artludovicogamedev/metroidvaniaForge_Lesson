class_name HealthPickUp
extends CharacterBody2D

var bounce_cnt : int = 8

const HEALTH_UP = preload("uid://l3a5tdg75h0l")
@onready var area2d : Area2D = $Area2D

@export var heal_amount : float = 30 


func _ready() -> void:
	area2d.body_entered.connect(_on_body_entered)
	pass
	
func _physics_process(_delta: float) -> void:
	if bounce_cnt > 0 :
		velocity += get_gravity() * _delta
		var col : KinematicCollision2D = move_and_collide(velocity  * _delta)
		if col :
			bounce_cnt -= 1
			velocity = velocity.bounce(col.get_normal()) * 0.65
			
	pass

func _on_body_entered (n : Node2D) -> void :
	if n is Player : 
		n.player_hp += heal_amount
		area2d.body_entered.disconnect(_on_body_entered)
		Audio.play_spatial_soundfx(HEALTH_UP,global_position,0.5,0.5)
		queue_free()
	pass
	
