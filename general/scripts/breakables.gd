@tool
@icon("res://general/icons/breakable.svg")
class_name Breakable
extends Node2D

signal destroyed
signal damage_taken

@export var hp : float = 3
@export var fixed_hit_count : bool = false 

@export_category("Particles")
@export var emission_offset : Vector2 = Vector2.ZERO
@export var hit_particles :Array[HitParticlesSettings]
@export var destroy_particles :Array[HitParticlesSettings]

@export_category("Audio")
@export var hit_audio : AudioStream = preload("uid://bysfi8jt35jr3")
@export var destroy_audio : AudioStream = preload("uid://b3rgbf3gbahc1")

enum PropType { NORMAL, NO_RESPAWN }
@export var prop_type : PropType = PropType.NORMAL


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if ( SaveManager.persistent_data.get( set_unique_name() ,"") == "isdestroyedfromscene" 
		and prop_type == PropType.NO_RESPAWN) :
		queue_free()
		return
	
	for c in get_children() :
		if c is DamageArea :
			c.damage_taken.connect(on_damage_taken)
	pass

func on_damage_taken (attack_area : AttackArea) -> void :
	if fixed_hit_count :
		hp -= 1
	else :
		hp -= attack_area.attack_damage

	var pos : Vector2 = global_position + emission_offset
	var dir : Vector2 = Vector2(1 , -1)
	
	if attack_area.global_position.x > global_position.x:
		dir *= - 1
	
	if hp > 0 :
		Audio.play_spatial_soundfx(hit_audio , pos)
		damage_taken.emit()
		for p in hit_particles :
			Visualfx.hit_particles( pos , dir , p)
	else : # when a prop is destroyed 
		Audio.play_spatial_soundfx(destroy_audio , pos)
		destroyed.emit()
		

			
		for p in destroy_particles :
			Visualfx.hit_particles( pos , dir , p)
		clear_collision()
		var tween : Tween = create_tween()
		tween.tween_property(self ,"modulate" , Color(modulate, 0) , 0.4 )
		await tween.finished 
		
		if prop_type == PropType.NO_RESPAWN: 
			SaveManager.persistent_data[ set_unique_name() ] = "isdestroyedfromscene"
			print("Saving: ", name, " " ,prop_type)
			
		queue_free()
	pass

func _get_configuration_warnings() -> PackedStringArray:
	if check_for_damage_areas() == false :
		return [ "Damage Area node is missing."]
	return []

func check_for_damage_areas() -> bool :
	for c in get_children():
		if c is DamageArea :
			return true
	return false

func clear_collision() -> void : 
	for c in get_children():
		if c is StaticBody2D :
			queue_free()

func set_unique_name () -> String :
	var uname :String = ResourceUID.path_to_uid(owner.scene_file_path) 
	uname += "/" + get_parent().name + "/" + name
	return uname
