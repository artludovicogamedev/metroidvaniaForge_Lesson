extends CanvasLayer
@onready var hp_margin: MarginContainer = %HPMargin
@onready var hp_bar: TextureProgressBar = %HPBar
@onready var mp_margin: MarginContainer = %MPMargin
@onready var mp_bar: TextureProgressBar = %MPBar

#game over controls
@onready var game_over: Control = %GameOver
@onready var load_game: Button = %LoadGame
@onready var quit_button: Button = %QuitButton

#@onready var mp_margin: MarginContainer = $Control/MPMargin
#@onready var mp_bar: TextureProgressBar = $Control/MPMargin/NinePatchRect/MPBar

func _ready() -> void:
	Messages.player_hp_changed.connect(update_player_healthbar)
	Messages.player_mp_changed.connect(update_player_magic_bar)
	
	load_game.pressed.connect(_on_load_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	game_over.visible = false
	pass
	
func update_player_healthbar( curhp : float  , maxhp : float ) -> void :
	var val = ( curhp  / maxhp) * 100 
	hp_bar.value = val
	hp_margin.size.x = maxhp + 22
	pass

func update_player_magic_bar( curmp : float  , maxmp : float ) -> void :
	var val = ( curmp  / maxmp) * 100 
	mp_bar.value = val
	mp_margin.size.x = maxmp + 22
	pass

func _on_load_button_pressed() -> void : 
	#load the last saved game.
	SaveManager.load_game(SaveManager.current_slot)
	clear_game_over_screen()
	pass

func _on_quit_button_pressed() -> void : 
	SceneManager.transition_scene("uid://bpj6xhviyw3tn", "" ,Vector2.ZERO , "up")
	pass

func show_game_over_screen() -> void :
	load_game.visible = false
	quit_button.visible = false
	
	game_over.modulate.a = 0
	game_over.visible = true
	
	var tween : Tween = create_tween()
	tween.tween_property(game_over,"modulate",Color.WHITE, 4.0)
	await tween.finished

	load_game.visible = true
	quit_button.visible = true
	load_game.grab_focus()
	
	pass
	
func clear_game_over_screen() -> void :
	load_game.visible = false
	quit_button.visible = false
	
	await SceneManager.scene_entered
	
	game_over.visible = false
	var player = Player
	player = get_tree().get_first_node_in_group("Player")
	player.queue_free()
	pass
