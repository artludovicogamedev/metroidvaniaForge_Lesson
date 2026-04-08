@tool
@icon("res://general/icons/ability_pickup.svg")
class_name AbilityPickUp
extends Node2D

enum Type { DOUBLE_JUMP, GROUND_SLAM ,MORPHROLL, DASH}

@onready var breakable: Breakable = $Breakable
@onready var orb_anim: AnimationPlayer = %OrbAnim
@onready var ability_anim: AnimationPlayer = %AbilityAnim
@onready var orb_sprite: Sprite2D = %OrbSprite
@onready var abilitysprite: Sprite2D = %Abilitysprite


@export var type :Type = Type.DOUBLE_JUMP :
	set(value) :
		type = value 
		_set_animation()
	
func _ready() -> void:
	_set_animation()
	
	if Engine.is_editor_hint():
		return
	
	if SaveManager.persistent_data.get( get_ability_name() ,"") == "obtained" :
		queue_free()
		return
	#persistence/ save data
	#connect to destroy signal
	breakable.destroyed.connect(on_destroyed)
	breakable.damage_taken.connect(on_damage_taken)
	pass

func _set_animation() -> void : 
	if not ability_anim :
		ability_anim = %AbilityAnim
	ability_anim.play(get_ability_name())
	pass

func get_ability_name() -> String :
	match type :
		Type.DOUBLE_JUMP :
			return "double_jump"
		Type.DASH :
			return "dash_skill"
		Type.GROUND_SLAM :
			return "ground_slam"
		Type.MORPHROLL :
			return "morph_roll"
	return ""

func on_destroyed() -> void :
	orb_anim.play("destroy")
	SaveManager.persistent_data[ get_ability_name() ] = "obtained"
	player_reward_ability()
	await orb_anim.animation_finished
	queue_free()
	pass

func on_damage_taken() -> void :
	orb_sprite.frame+=1
	pass

func player_reward_ability () -> void :
	var player : Player = get_tree().get_first_node_in_group("Player")
	match type :
		Type.DOUBLE_JUMP:
			player.double_jump = true
		Type.GROUND_SLAM:
			player.ground_slam = true
		Type.MORPHROLL:
			player.morph_roll = true
		Type.DASH:
			player.dash_skill = true
	pass
