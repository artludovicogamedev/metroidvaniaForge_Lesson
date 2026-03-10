extends CanvasLayer

#region  /// on ready variables
@onready var main_menu: VBoxContainer = %MainMenu
@onready var new_game_menu: VBoxContainer = %NewGameMenu
@onready var load_game_menu: VBoxContainer = %LoadGameMenu

@onready var new_game: Button = %NewGame
@onready var load_game: Button = %LoadGame

@onready var new_slot_01: Button = %NewSlot01
@onready var new_slot_02: Button = %NewSlot02
@onready var new_slot_03: Button = %NewSlot03

@onready var load_slot_01: Button = %LoadSlot01
@onready var load_slot_02: Button = %LoadSlot02
@onready var load_slot_03: Button = %LoadSlot03

@onready var animation_player: AnimationPlayer = $Control/MainMenu/Logo/AnimationPlayer
#endregion

func _ready() -> void:
	show_main_menu()
	animation_player.animation_finished.connect(on_animation_finished)
	#connect button signals
	new_game.pressed.connect(show_new_game_menu)
	load_game.pressed.connect(show_load_menu)
	
	#connect new game button
	new_slot_01.pressed.connect(on_new_game_pressed.bind(0))
	new_slot_02.pressed.connect(on_new_game_pressed.bind(1))
	new_slot_03.pressed.connect(on_new_game_pressed.bind(2))

	#connect load game button
	load_slot_01.pressed.connect(on_load_game_pressed.bind(0))
	load_slot_02.pressed.connect(on_load_game_pressed.bind(1))
	load_slot_03.pressed.connect(on_load_game_pressed.bind(2)) 
	
	#connect audio
	#setup main menu
	#transition logo 
	pass


func show_main_menu() -> void :
	main_menu.visible = true
	new_game_menu.visible = false 
	load_game_menu.visible = false
	new_game.grab_focus()
	pass

func show_new_game_menu() -> void :
	main_menu.visible = false
	new_game_menu.visible = true 
	load_game_menu.visible = false
	new_slot_01.grab_focus()
	
	if SaveManager.check_if_file_exists(0) : 
		new_slot_01.text = "Replace slot 01"

	if SaveManager.check_if_file_exists(1) : 
		new_slot_02.text = "Replace slot 02"
		
	if SaveManager.check_if_file_exists(2) : 
		new_slot_03.text = "Replace slot 03"
		
	pass
	
func show_load_menu() -> void :
	main_menu.visible = false
	new_game_menu.visible = false 
	load_game_menu.visible = true
	load_slot_01.grab_focus()
	
	#load slot will be disabled if there are no saved files
	load_slot_01.disabled = not SaveManager.check_if_file_exists(0)
	load_slot_02.disabled = not SaveManager.check_if_file_exists(1)
	load_slot_03.disabled = not SaveManager.check_if_file_exists(2)
	pass
	
func on_animation_finished( anim : String) -> void :
	if anim == "game_intro" :
		animation_player.play("game_title_loop")
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if main_menu.visible == false :
			#audio
			show_main_menu()
	pass

func on_new_game_pressed(slot : int) -> void:
	SaveManager.create_new_game_save(slot)
	pass

func on_load_game_pressed(slot : int) -> void:
	SaveManager.load_game(slot)
	pass
