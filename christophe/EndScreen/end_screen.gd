extends Node2D

@export var player_won = true

func _ready():
	
	if not player_won:
		$Player.texture = load("res://christophe/EndScreen/PlayerLost.png")
		$Frog.texture = load("res://christophe/EndScreen/FrogLost.png")
	
	var t = create_tween()
	
	%MenuButton.scale = Vector2(0,0)
	$TimeDecoration.scale = Vector2(0,0)
	
	# Player goes up, then the little friend
	
	$ShakerComponent2D.play_shake()
	#t.tween_property($ShakerComponent2D,"intensity",0.1,4).set_trans(Tween.TRANS_QUAD)
	t.tween_property($Frog,"global_position:y",165,2).set_trans(Tween.TRANS_BACK)
	t.tween_property($Player,"global_position:y",226,1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property($Units,"global_position:y",213,2).set_trans(Tween.TRANS_BACK).set_delay(0.1)
	t.tween_property($TimeDecoration,"scale",Vector2(1,1),1).set_trans(Tween.TRANS_BACK).set_delay(0.1).set_ease(Tween.EASE_OUT)
	t.tween_property(%MenuButton,"scale",Vector2(1,1),1).set_trans(Tween.TRANS_BACK).set_delay(0.1).set_ease(Tween.EASE_OUT)
	
	#await t.finished


func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://christophe/Menu/menu.tscn")
	
