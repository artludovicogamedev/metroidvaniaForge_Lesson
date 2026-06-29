class_name PlayerStateLedgeHang
extends PlayerState

 
var player_dropped_down : bool = false
var cornertoGrab : Vector2 = Vector2.ZERO
var ledge_grab_position : Vector2 = Vector2.ZERO

@export var fallspeed : float = 450

const PLAYER_HANG_OFFSET_Y := 48.0


func init() -> void:
	player.ledge_timer.timeout.connect(_on_ledge_timer_out)
	pass

func enter() -> void:
	snap_player_to_ledge()
	#player.collision_ledge_hang.disabled = false
	player_dropped_down = false
	player.can_move = false
	player.gravity_multiplier = 0
	player.animation_player.play("ledgehang")
	pass

func exit() -> void:
	player.velocity.y = fallspeed * 0.5
	player.can_move = true
	pass

func handle_input( event : InputEvent ) -> PlayerState :
	if((event.is_action_pressed("down") or event.is_action_pressed("jump")) 
		and player_dropped_down == false):
		player_dropped_down = true
		player.ledge_timer.start()
		player.ledgegrabtop.enabled = false
		player.ledgegrabbottom.enabled = false
		return fall
		
	if event.is_action_pressed("up"):
		player.can_move = true
		return ledge_climb
	return next_state

func process(_delta: float) -> PlayerState:
	return next_state

func physics_process(_delta: float) -> PlayerState:
	
	return next_state

func _on_ledge_timer_out()-> void :
	player.ledge_timer.stop()
	player.ledgegrabtop.enabled = false
	player.ledgegrabbottom.enabled = false

func snap_player_to_ledge()-> void :
	#var tilesize = player.collisionTiles.tile_set.tile_size #get the tile size of the tilemap layer (32x32)
	#var tilesize_correction = (tilesize / 2) as Vector2 #adjust center of tile 
	var cp # collision point 
	var local_cp #Collision point to local
	var tc # tile coordinates 
	var local_center # tile coordinates to local position
	var world_center 
	var hang_corner : Vector2 
	
	if player.ledgeDirection == Vector2.LEFT :
		if player.ledgegrabbottom.is_colliding() :
			cp = player.ledgegrabbottom.get_collision_point()
			local_cp = player.collisionTiles.to_local(cp)
			tc = player.collisionTiles.local_to_map(local_cp)
			local_center = player.collisionTiles.map_to_local(tc)
			world_center = player.collisionTiles.to_global(local_center)
			pass
		pass

	if player.ledgeDirection == Vector2.RIGHT :
		if player.ledgegrabbottom.is_colliding() :
			cp = player.ledgegrabbottom.get_collision_point()
			local_cp = player.collisionTiles.to_local(cp)
			tc = player.collisionTiles.local_to_map(local_cp)
			local_center = player.collisionTiles.map_to_local(tc)
			world_center = player.collisionTiles.to_global(local_center)
			pass
		pass
 
	#if player.ledgegrabbottom.is_colliding() :
		#cp = player.ledgegrabbottom.get_collision_point()
		#local_cp = player.collisionTiles.to_local(cp)
		#tc = player.collisionTiles.local_to_map(local_cp)
		#local_center = player.collisionTiles.map_to_local(tc)
		#world_center = player.collisionTiles.to_global(local_center)
		#pass
			
	if player.ledgeDirection == Vector2.RIGHT:
		hang_corner = world_center + Vector2(16, -16)
	else:
		hang_corner = world_center + Vector2(-16, -16)
	
	player.global_position = hang_corner + player.get_hang_offset()
	player.world_center.global_position = world_center
	player.hang_corner.global_position = hang_corner
	
	print()
	print("origin:", player.ledgegrabbottom.global_position)
	print("target:", player.ledgegrabbottom.to_global(player.ledgegrabbottom.target_position))
	print("ledgegrabbottom target pos :" ,player.ledgegrabbottom.target_position)
	print("ledgegrabbottom global pos :" ,player.ledgegrabbottom.global_position)
	print(" Collision Point Raycast : " ,cp, " to Local : ", local_cp)
	print(" Tile Coordinates from local_cp to " , tc)
	print(" Tile Coordinates to Local : " , local_center)
	print(" World Center : " , local_center)
	print(" Player sprite flip : ", player.playersprite.flip_h)
	print(" Player Position : " , player.global_position , " | Hang Corner : " , hang_corner , " | hang offset : " , player.get_hang_offset() )
	pass
