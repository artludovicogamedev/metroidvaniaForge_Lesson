@icon("res://general/icons/enemy_hit_particles.svg")
class_name EnemyHitParticles
extends Marker2D

@export var hit_particles : Array[HitParticlesSettings]
@export var death_particles : Array[HitParticlesSettings]

var enemy_killed : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if owner is Enemy :
		owner.was_hit.connect( _on_hit)
		owner.was_killed.connect( _on_killed)
	else :
		for c in get_parent().get_children():
			if c is DamageArea:
				c.damage_taken.connect(_on_hit)
	pass # Replace with function body.

func _on_hit ( a : AttackArea ) -> void :
	var dir : Vector2 = global_position.direction_to(a.global_position)
	dir.x *= -1
	var particles = hit_particles
	
	if enemy_killed :
		particles = death_particles
	
	for p in particles :
		Visualfx.hit_particles(global_position,dir,p)
	pass
	
func _on_killed ( ) -> void :
	enemy_killed = true
	pass
