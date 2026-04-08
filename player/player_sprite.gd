class_name PlayerSprite
extends Sprite2D

var tween : Tween

func _ready() -> void:
	pass
	
func create_tween_fx( d : float = 0.5 , color : Color = Color(0.0,1.5,0.95)) -> void :
	if tween :
		tween.kill()
	modulate = color
	tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, d)
	pass

func create_player_afterimage() -> void :
	var effect : Node2D = Node2D.new()
	var p : Node2D = get_parent()
	
	p.add_sibling(effect)
	effect.get_parent().move_child(effect,0)
	effect.z_index = 2
	effect.global_position = p.global_position
	effect.modulate = Color(0.0,1.5,0.75)
	
	var spritecopy : Sprite2D = duplicate()
	effect.add_child(spritecopy)
	
	var t : Tween = create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(effect, "modulate" , Color(1,1,1,0),0.2)
	t.chain().tween_callback(effect.queue_free)
	pass
