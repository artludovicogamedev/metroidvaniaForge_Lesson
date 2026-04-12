@icon("res://general/icons/edge_sensor.svg")
class_name EdgeDetector
extends RayCast2D

signal edge_detected 
var collision_detected : bool = true

func _ready() -> void:
	set_collision_mask_value(1,true)
	set_collision_mask_value(2,true)
	pass
	
func _physics_process(_delta: float) -> void:
	var _colliding :bool = is_colliding()
	if collision_detected != _colliding :
		
		collision_detected = _colliding
		if not collision_detected :
			
			edge_detected.emit()
	pass

func direction_change(new_dir : float)-> void :
	if new_dir < 0 and position.x > 0 or new_dir > 0 and position.x < 0 :
		position.x *= -1
 
	pass
