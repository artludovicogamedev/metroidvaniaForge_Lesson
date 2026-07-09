class_name PlayerBlockState
extends PlayerState


var parry_window_timer : float = 0 
var block_timer : float = 0 
var duration
var knockbackdirection : float = 1.0

@export var parry_window : float = .3
@export var movespeed : float = 100
@export var particles : Array [HitParticlesSettings]
@onready var damage_area: DamageArea = %DamageArea
@onready var parry_area: ParryArea = %ParryArea


var is_block_broken : bool = false
var is_parried : bool = false
var attack_received : bool = false
func init() -> void:
	damage_area.block_damage_taken.connect(_on_block_damage_taken)
	pass
	
func enter() -> void:
	handle_blocking_properties()
	player.animation_player.play("block")
	#play sfx here
	pass

func exit() -> void:
	block_timer = 0
	parry_window_timer = 0
	is_block_broken = false
	is_parried = false
	pass

func handle_input( _event : InputEvent ) -> PlayerState :
	if _event.is_action_released("block"):
		player.parry_area_collider.disabled = true
		player.blocking_area.disabled = true
		player.damage_area_stand.disabled = false
		player.damage_area_crouch.disabled = true
		return idle
	return null

func process(_delta: float) -> PlayerState:
	return null

func physics_process(_delta: float) -> PlayerState:
	parry_window_timer += _delta 
	block_timer += _delta
	if is_parried :
		return parry
	
	if attack_received and not is_block_broken:
		attack_received = false
		return blocked
	
	if is_block_broken :
		return block_break
	
	
	return null

func handle_blocking_properties() -> void :
	player.damage_area_stand.disabled = true
	player.damage_area_crouch.disabled = true
	player.parry_area_collider.disabled = true
	player.blocking_area.disabled = false
	parry_window_timer = 0
	is_parried = false
	if player.playersprite.flip_h :
		player.damage_area.reposition_damage_area(20,40,-14,-46)
		player.parry_area.reposition_parry_collider(20,40,-14,-46)
	else :
		player.damage_area.reposition_damage_area(20,40,14,-46)
		player.parry_area.reposition_parry_collider(20,40,14,-46)
	pass

func _on_block_damage_taken(_attackarea : AttackArea) -> void :
	#var attackreceived = attackarea 
	var a = _attackarea 
	if a.name == "HazardArea" :
		#prevents block to trigger when pressed and player is beside a hazard area
		return
	if parry_window_timer <= parry_window and block_timer < parry_window:
		is_parried = true
	
	if block_timer > parry_window and player.player_bp > 0 :
		attack_received = true
	
	if player.player_bp <= 0 :
		is_block_broken = true
	pass
