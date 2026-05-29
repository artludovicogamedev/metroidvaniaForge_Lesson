extends CanvasLayer

@onready var hp_margin: MarginContainer = %HPMargin
@onready var hp_bar: TextureProgressBar = %HPBar
@onready var boss_hp_bar: Control = %BossHPBar
@onready var label: Label = %Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Messages.boss_hp_changed.connect(update_boss_healthbar)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func update_boss_healthbar( curhp : float  , maxhp : float ) -> void :
	var val = ( curhp  / maxhp) * 100 
	hp_bar.value = val
	pass

func display_boss_hp(n : String) -> void :
	boss_hp_bar.visible = true
	label.text = n
	pass
	
