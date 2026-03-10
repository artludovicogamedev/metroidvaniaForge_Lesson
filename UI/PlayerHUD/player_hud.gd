extends CanvasLayer
@onready var hp_margin: MarginContainer = %HPMargin
@onready var hp_bar: TextureProgressBar = %HPBar

#@onready var mp_margin: MarginContainer = $Control/MPMargin
#@onready var mp_bar: TextureProgressBar = $Control/MPMargin/NinePatchRect/MPBar

func _ready() -> void:
	Messages.player_hp_changed.connect(update_player_healthbar)
	pass
	
func update_player_healthbar( curhp : float  , maxhp : float ) -> void :
	var val = ( curhp  / maxhp) * 100 
	hp_bar.value = val
	hp_margin.size.x = maxhp + 22
	
	pass

#func update_player_magic_bar( curmp : float  , maxmp : float ) -> void :
	#var val = ( curmp  / maxmp) * 100 
	#hp_bar.value = val
	#hp_margin.size.x = maxmp + 22
	#
	#pass
