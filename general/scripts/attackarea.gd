@icon("res://general/icons/attack_area.svg")
class_name AttackArea
extends Area2D

@export var attack_damage : float = 0.0
@export var knockback_damage : float = 0 
#create an attack enum here, heavy ,piercing , slash, magic
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(on_body_entered)
	area_entered.connect(on_body_entered)
	
	monitorable = false
	monitoring = false
	visible = false
	pass

func on_body_entered(body : Node2D) -> void:
	if body is DamageArea :
		body.take_damage(self)
		var pos : Vector2 = global_position
		pos.x = body.global_position.x
		Visualfx.create_hit_dust_fx(pos)
		pass
	pass

 
func active_area( dur : float = 0.1) -> void :
	set_active()
	await get_tree().create_timer(dur).timeout
	set_active(false)
	pass

func set_active ( value : bool = true) -> void :
	monitoring = value
	visible = value
	pass

func flipattack( dirx : float) -> void:
	if dirx > 0 :
		scale.x = 1
	elif dirx < 0 :
		scale.x = -1
	pass

func compute_attack_properties(ax : float ,ay :float ,apx : float , apy : float, 
	dmg : float = 0 , kbf : float = 0 ) -> void :
	# this function will resize hitboxes
	collision_shape_2d.shape.size = Vector2(ax,ay)
	collision_shape_2d.position = Vector2(apx,apy)
	attack_damage = dmg
	knockback_damage = kbf
	pass

func reset_attack_properties(ax : float ,ay :float ,apx : float , apy : float) -> void :
	# this function will resize hitboxes
	collision_shape_2d.shape.size = Vector2(ax,ay)
	collision_shape_2d.position = Vector2(apx,apy)
	pass
