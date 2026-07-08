@icon("res://general/icons/parry_area.svg")
class_name ParryArea
extends Area2D

signal parried_attack()
@export var attack_damage : float = 0.0
@export var knockback_damage : float = 0 
#create an attack enum here, heavy ,piercing , slash, magic
@onready var parry_area_collider: CollisionShape2D = %ParryAreaCollider

func _ready() -> void:
	pass

func parry_attack() -> void :
	parried_attack.emit()
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

func reposition_parry_collider(ax : float ,ay :float ,apx : float , apy : float) -> void :
	parry_area_collider.shape.size = Vector2(ax,ay)
	parry_area_collider.position = Vector2(apx,apy)
	pass
