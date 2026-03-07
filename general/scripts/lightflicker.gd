class_name LightFlicker
extends PointLight2D

@export var flicker_intensity : float = 0.1
@export var flicker_frequency : float = 0.2
var og_enery : float = 1.0

func _ready() -> void:
	og_enery = energy
	flicker()
	pass

func flicker()-> void :
	var new_val : float = randf_range(-1,1) * flicker_intensity
	energy = og_enery + new_val
	await get_tree().create_timer( flicker_frequency + 
		randf_range(flicker_frequency * -0.3 , flicker_frequency * 0.3)).timeout
	flicker()
	pass
