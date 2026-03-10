extends Node

@warning_ignore_start("unused_signal")
signal player_interacted(player :Player)
signal player_healed(amount : float)
signal input_hint_changed(hint : String)
signal player_hp_changed( hp : float , maxhp : float)
signal back_to_title()
@warning_ignore_restore("unused_signal")
