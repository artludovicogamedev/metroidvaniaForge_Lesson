@icon("res://general/icons/enemy.svg")
@tool
class_name Enemy
extends CharacterBody2D

signal direction_changed(newdir)
signal was_hit( a : AttackArea)
signal damage_counter ()
signal was_killed()

@onready var attack_area: AttackArea = %AttackArea

@export var hp : float = 3 
@export var maxhp : float = 3 

@export var is_affected_by_gravity : bool = true
@export var is_facing_left_on_start : bool = false :
	set(value ) :
		is_facing_left_on_start = value
		_update_face_left()

@export_category("Audio")

var sprite : Sprite2D
var animation : AnimationPlayer
var damage_area : DamageArea
var hazard_area : HazardArea

var statemachine : EnemyStateMachine
var decisionengine : DecisionEngine
var blackboard : Blackboard
 
func _ready() -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)
		return
	SetUp()
	pass

func SetUp() -> void :
	blackboard = Blackboard.new()
	blackboard.health = hp
	Messages.boss_hp_changed.emit(blackboard.health, maxhp)
	for c in get_children():
		if c is AnimationPlayer and not animation :
			animation = c
		elif c is Sprite2D and not sprite:
			sprite = c 
		elif c is DamageArea and not damage_area :
			damage_area = c
			c.damage_taken.connect(on_damage_taken)
		elif c is HazardArea and not hazard_area :
			hazard_area = c
		elif c is EnemyStateMachine and not statemachine : 
			statemachine = c
		elif c is DecisionEngine and not decisionengine :
			decisionengine = c
	
	if statemachine and decisionengine :
		statemachine.setup(self,blackboard) 
		decisionengine.enemy = self
		decisionengine.blackboard = blackboard
	else :
		set_physics_process( false)
	pass

func _physics_process(delta: float) -> void:
	blackboard.update_distance_to_target(global_position)
	statemachine.change_state(decisionengine.decide())

	if is_affected_by_gravity :
		velocity += get_gravity() * delta * blackboard.gravity_multiplier
	statemachine.physics_update(delta)
	move_and_slide()
	pass

func change_direction(nd : float) -> void :
	blackboard.dir = nd
	direction_changed.emit(nd)
	if sprite :
		if nd < 0 :
			sprite.flip_h = true
			
		elif nd > 0:
			sprite.flip_h = false
		attack_area.flipattack(nd)
	pass

func play_animation(animname : String) -> void :
	if animation.has_animation(animname):
		animation.play(animname)
	else:
		printerr("missing animation :" , animname)
	pass

func on_damage_taken(a : AttackArea) -> void :
	blackboard.damage_source = a
	blackboard.health -= a.attack_damage
	if blackboard.health <= 0 :
		damage_area.queue_free()
		hazard_area.queue_free()
		was_killed.emit()
	was_hit.emit(a)
	damage_counter.emit()
	Messages.boss_hp_changed.emit(blackboard.health, maxhp)
	pass
	
func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	
	if not find_children("*" ,"AnimationPlayer" , false):
		warnings.append("Requires AnimationPlayer node")
		
	if not find_children("*" ,"Sprite2D" , false):
		warnings.append("Requires Sprite2D node")
		
	if not find_children("*" ,"DamageArea" , false):
		warnings.append("Requires DamageArea node")
		
	if not find_children("*" ,"HazardArea" , false):
		warnings.append("Requires HazardArea node")
		
	if not find_children("*" ,"EnemyStateMachine" , false):
		warnings.append("Requires EnemyStateMachine node")
		
	if not find_children("*" ,"DecisionEngine" , false):
		warnings.append("Requires DecisionEngine node")
	return warnings

func _update_face_left() -> void :
	if not Engine.is_editor_hint():
		return
	
	for c in get_children():
		if c is Sprite2D :
			c.flip_h = is_facing_left_on_start
	pass

func on_parried(parry_area: ParryArea):
	blackboard.parry_source = parry_area
