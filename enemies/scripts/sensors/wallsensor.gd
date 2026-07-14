class_name WallSensor
extends RayCast2D

signal wall_detected

var enemy : Enemy
var collision_detected : bool = false
var distance_from_wall : float
var first_wall_contact : float  = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_collision_mask_value(1,true)
	if owner is Enemy :
		enemy = owner
		enemy.direction_changed.connect(on_direction_changed)
	else:
		set_physics_process(false)
		enabled = false
	pass
	
func _process(_delta: float) -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if !enemy.is_on_floor():
		return
	
	enabled = true
	var _colliding :bool = is_colliding()
	
	if collision_detected != _colliding :
		collision_detected = _colliding
		var hit_point = get_collision_point()
		
		# Calculate the distance from the ray's global start position to the hit point
		if first_wall_contact and collision_detected :
			distance_from_wall = global_position.distance_to(hit_point)
			first_wall_contact = false
			
		if collision_detected :
			enemy.blackboard.wall_detected = true
			enemy.blackboard.wall_distance = distance_from_wall
			
			wall_detected.emit()
		else :
			enemy.blackboard.wall_detected = false
		
func update_jump_coordinates(_vx : float)-> void :
	
	pass

func on_direction_changed(dir : float) -> void :
	if dir < 0 :
		scale.x = -1
	elif dir > 0:
		scale.x = 1
	pass
