@icon("res://general/icons/loot_drop.svg")
class_name LootDropper
extends Marker2D

@export var items : Array [LootData]

func _ready() -> void:
	if owner is Enemy :
		owner.was_killed.connect(drop_loot)
	elif owner is Breakable:
		owner.destroyed.connect(drop_loot)
	pass

func drop_loot() -> void :
	for i in items :
		if i.droprate <= randf():
			continue
			
		var dropscene = load(i.item)
		var drpcnt : int = randi_range(i.mindrop , i.maxdrop)
		
		for j in drpcnt :
			var drop  = dropscene.instantiate()
			owner.add_sibling.call_deferred(drop)
			drop.global_position = global_position
			if drop is CharacterBody2D :
				drop.velocity = Vector2(randf_range(-50,50) , randf_range(-200,200))
		pass
	pass
