@icon("res://general/icons/damage_area.svg")
class_name DamageArea
extends Area2D 

signal damage_taken(attackarea)
signal block_damage_taken(attackarea)
@export var damageaudio : AudioStream
@onready var blocking_area: CollisionShape2D = %BlockingArea

func _ready() -> void:
	pass
	
func take_damage(attackarea : AttackArea) -> void :
	damage_taken.emit(attackarea)
	block_damage_taken.emit(attackarea)
	Audio.play_audio_stream(damageaudio)
	pass

func make_invulnerable(dur : float = 1.0) -> void :
	process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(dur).timeout
	process_mode = Node.PROCESS_MODE_INHERIT
	pass

func start_invulnerable() -> void :
	process_mode = Node.PROCESS_MODE_DISABLED
	pass

func end_invulnerable() -> void :
	process_mode = Node.PROCESS_MODE_INHERIT
	pass

func reposition_damage_area(ax : float ,ay :float ,apx : float , apy : float) -> void :
	blocking_area.shape.size = Vector2(ax,ay)
	blocking_area.position = Vector2(apx,apy)
	pass
