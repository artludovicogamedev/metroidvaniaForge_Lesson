@icon ("res://general/icons/enemy.svg")
class_name SlimeEnemy
extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hazard_area: HazardArea = $HazardArea
@onready var damage_area: DamageArea = $DamageArea
@onready var edge_detector: EdgeDetector = $EdgeDetector

@export var enemyhp : float = 3
@export var isfacingleft : bool = false
@export var movespeed : float = 30
@export var death_sound : AudioStream

var dir : float = 1 

var movetween : Tween

func _ready() -> void:
	animation_player.play("move")
	animation_player.animation_finished.connect(on_animation_finished)
	edge_detector.edge_detected.connect(on_edge_detected)
	damage_area.damage_taken.connect(on_damage_taken)
	change_direction(-1.0 if isfacingleft else 1.0)
	pass

func _physics_process(delta: float) -> void:
	if is_on_wall():
		change_direction(-dir)
		
	velocity += get_gravity() * delta
	velocity.x = dir * movespeed 
	move_and_slide()
	pass


func change_direction( new_dir : float ) -> void :
	dir = new_dir
	edge_detector.direction_change(dir)
	if dir < 0 :
		sprite_2d.flip_h = true
	else:
		sprite_2d.flip_h = false
	pass

func on_edge_detected () -> void :
	if is_on_floor():
		print("edge detected")
		change_direction(-dir)
	pass

func on_damage_taken(attackarea : AttackArea) -> void :
	enemyhp -= attackarea.attack_damage
	knockback(attackarea.global_position)
	if enemyhp	> 0 :
		animation_player.play("hurt")
	else :
		animation_player.play("death")
		Audio.play_spatial_soundfx(death_sound,position,.5,.12)
		damage_area.queue_free()
		hazard_area.queue_free()
	pass

func on_animation_finished(anim : String) -> void :
	if anim == "hurt" :
		animation_player.play("move")
	else :
		
		queue_free()
	pass

func knockback( atkpos : Vector2 ) -> void : 
	var fromvalue : float = dir
	var tovalue : float = dir 
	
	if atkpos.x < global_position.x :
		fromvalue += 2
	else:
		fromvalue -= 2
	
	if movetween :
		movetween.kill()
		
	dir = fromvalue
	movetween = create_tween()
	movetween.tween_property(self ,"dir", tovalue , 0.3)
	
	pass
