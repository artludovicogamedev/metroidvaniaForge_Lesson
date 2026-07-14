class_name BSCutScene
extends EnemyState

var duration : float = 0
var timer : float = 0
var themesong_started : bool = false
@onready var male_grunt_2: AudioStreamPlayer = %MaleGrunt2

func enter() -> void :
	var anim : String = animation_name if animation_name else "Cinematic"
	enemy.play_animation(anim)
	male_grunt_2.play()
	#blackboard.theme_song.play()
	duration = enemy.animation.current_animation_length
	enemy.velocity.x = 0 
	timer = 0
	blackboard.can_decide = false
	pass

func re_enter() -> void :
	#when enemy re-enter same state
	pass

func exit() -> void :
	#when enemy moves to next state
	blackboard.can_decide = true
	BossHud.display_boss_hp(blackboard.enemy_name,blackboard.health,blackboard.maxhealth)
	SceneManager.cinematic_sequence_finished.emit()
	enemy.attack_area.reset_attack_properties(48,120,72,-60)
	pass

func physics_update(_delta: float) -> void:
	timer += _delta
	if timer >= duration:
		blackboard.can_decide = true
		blackboard.cinematic_state_played = false
		
	if enemy.sprite.frame == 40 and themesong_started == false:
		themesong_started = true
	pass
