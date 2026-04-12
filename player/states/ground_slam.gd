class_name GroundSlam
extends PlayerState

const LAND_SFX = preload("uid://dsrkjn1cjrvcs")
const HIT_PARTICLES_WOOD_LARGE = preload("uid://c6xuoxg0c74ib")
const HIT_PARTICLES_WOOD_MEDIUM = preload("uid://dyddftd5jckww")
const HIT_PARTICLES_WOOD_SMALL = preload("uid://cju4debmygdcu")
const BREAK_WOOD = preload("uid://b3rgbf3gbahc1")
const BOOM_SFX = preload("uid://bvury3lpmjyyv")



@export var groundslamvelocity : float = 400
@export var effect_delay : float = 0.05
@export var effectDuration : float = 0.2
var effect_timer : float = 0

func init() -> void:
	pass
	
func enter() -> void:
	player.animation_player.play("groundslam")
	player.playersprite.create_tween_fx(.4)
	player.dash_sfx.play()
	player.damage_area.start_invulnerable()
	player.ground_slam_attack_area.set_active()
	pass

func exit() -> void:
	Visualfx.camera_shake_fx(10)
	Visualfx.create_land_dust_fx(player.global_position)
	player.land_sfx.play()
	player.damage_area.end_invulnerable()
	player.ground_slam_attack_area.set_active(false)
	pass

func handle_input( _event : InputEvent ) -> PlayerState :
	return next_state

func process(delta: float) -> PlayerState:
	check_collisions(delta)
	effect_timer -= delta
	
	if effect_timer < 0 :
		effect_timer = effectDuration
		player.playersprite.create_player_afterimage()
		
	return next_state


func physics_process(_delta: float) -> PlayerState:
	player.velocity= Vector2( 0, groundslamvelocity) 
	if player.is_on_floor():
		#player.add_debugger(Color.DARK_BLUE)
		if not check_collisions(_delta) :
			return idle
	return next_state

func check_collisions( delta : float ) -> bool :
	player.ground_slam_shape_cast.target_position.y = groundslamvelocity * delta
	player.ground_slam_shape_cast.force_shapecast_update()
	
	if player.ground_slam_shape_cast.is_colliding():
		for i in player.ground_slam_shape_cast.get_collision_count():
			var c = player.ground_slam_shape_cast.get_collider(i)
			var pos : Vector2 = player.ground_slam_shape_cast.get_collision_point(i)
			c.queue_free()
			Visualfx.create_hit_dust_fx(pos)
			Visualfx.camera_shake_fx(10)
			
			if c.get_parent() is Breakable :
				var brk : Breakable = c.get_parent()
				brk.queue_free()
				Audio.play_spatial_soundfx(brk.destroy_audio,pos,-3,-13)
				for prtcles in brk.destroy_particles :
					Visualfx.hit_particles(pos, Vector2.DOWN , prtcles)
				pass
			
			
			#region // temporary fx
			#below are optional hit particles and may change depending on what material
			#player destroyed
			#to fix later
			Visualfx.hit_particles(pos, Vector2.DOWN , HIT_PARTICLES_WOOD_LARGE)
			Visualfx.hit_particles(pos, Vector2.DOWN , HIT_PARTICLES_WOOD_MEDIUM)
			Visualfx.hit_particles(pos, Vector2.UP , HIT_PARTICLES_WOOD_SMALL)
			Audio.play_spatial_soundfx(BREAK_WOOD,pos,1.5,4)
			#endregion
		return true
	return false
