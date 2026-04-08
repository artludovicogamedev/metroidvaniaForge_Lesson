class_name PlayerHurtState
extends PlayerState


@export var particles : Array [HitParticlesSettings]
@export var invulnerableduration : float = 1.0
@export var movespeed : float = 100


var hurttime : float = 0
var knockbackdirection : float = 1.0
@onready var damage_area: DamageArea = %DamageArea


func init() -> void:
	damage_area.damage_taken.connect(_on_damage_taken)
	pass
	
func enter() -> void:
	player.animation_player.play("hurt") 
	hurttime = invulnerableduration
	damage_area.make_invulnerable(invulnerableduration)
	player.hurt_sfx.play()
	Visualfx.camera_shake_fx(3)
	#timer
	#audio 
	
	pass

func exit() -> void:
	pass

func handle_input( _event : InputEvent ) -> PlayerState :
	return null

func process(_delta: float) -> PlayerState:
	hurttime -= _delta

		
	if hurttime <= 0 :
		if player.player_hp <= 0 :
			return death
			
		if !player.is_on_floor():
			return fall
		else:
			return idle
	return null

func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = movespeed * knockbackdirection
	
	return null

func _on_damage_taken(attackarea : AttackArea) -> void :
	if player.current_state == death :
		return
		
	player.change_state(self)
	
	
	if attackarea.global_position.x < player.global_position.x :
		knockbackdirection = 1.0
	else :
		knockbackdirection = -1.0
		
	var pos : Vector2 = player.global_position + Vector2(0 , -30)
	for p in particles :
		Visualfx.hit_particles( pos , Vector2(knockbackdirection , 0) , p)
	pass
