@icon ("res://general/icons/save_point.svg")
class_name SavePoint
extends Node2D

@onready var area_2d: Area2D = $Node2D/Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	area_2d.body_entered.connect(_on_player_entered)
	area_2d.body_exited.connect(_on_player_exited)
	pass

func _on_player_entered( _n : Node)->void :
	Messages.player_interacted.connect(on_player_interacted)
	Messages.input_hint_changed.emit("action")
	pass

func _on_player_exited( _n : Node)->void :
	Messages.player_interacted.disconnect(on_player_interacted)
	Messages.input_hint_changed.emit("")
	pass

func on_player_interacted(player :Player)->void:
	Messages.player_healed.emit(player.player_max_hp)
	SaveManager.save_game()
	animation_player.play("game_saved")
	animation_player.seek( 0 )
	#save game
	#heal player
	#play animation - OK
	pass
