#visual effects
extends Node

const DUST_EFFECT = preload("uid://n3pxfdm6f1yn")
const HIT_PARTICLES = preload("uid://21p6kkpl65o6")

signal camera_shake(strength : float)

func _create_dust_effect (pos : Vector2) -> DustEffect:
	var dust : DustEffect = DUST_EFFECT.instantiate()
	add_child(dust)
	dust.global_position = pos
	return dust

func create_jump_dust_fx (pos : Vector2) -> void :
	var jd : DustEffect = _create_dust_effect(pos)
	jd.start_effect(DustEffect.TYPE.jump)

func create_land_dust_fx (pos : Vector2) -> void :
	var jd : DustEffect = _create_dust_effect(pos)
	jd.start_effect(DustEffect.TYPE.land)

func create_hit_dust_fx (pos : Vector2) -> void :	 
	
	var posx = pos.x
	var posy = pos.y
	
	pos = Vector2(posx,posy)
	
	var jd : DustEffect = _create_dust_effect(pos)
	jd.start_effect(DustEffect.TYPE.hit)
	pass

func camera_shake_fx(strength : float = 1.0) -> void :
	camera_shake.emit(strength)
	pass

func hit_particles( pos : Vector2 ,dir : Vector2 , settings : HitParticlesSettings) -> void :
	var hp : HitParticles = HIT_PARTICLES.instantiate()
	add_child(hp)
	
	hp.global_position = pos
	hp.start_effect(settings, dir)
	
	pass
	
