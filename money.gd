extends Node2D


var t:Tween

func _ready():
	var initial_position = %Sprite2D.position
	%Sprite2D.scale = Vector2.ZERO
	
	t = create_tween()
	t.tween_property(%Sprite2D,"scale",Vector2(1,1),0.3).set_trans(Tween.TRANS_QUAD)
	
	await t.finished
	t.kill()
	t = create_tween().set_loops(0).set_trans(Tween.TRANS_QUAD)
	t.tween_property(%Sprite2D,"position:y",initial_position.y-5,1.5)
	t.parallel().tween_property($SmallShadow,"modulate:a",0.6,1.5)
	t.tween_property(%Sprite2D,"position:y",initial_position.y,1.5)
	t.parallel().tween_property($SmallShadow,"modulate:a",1,1.5)
	await get_tree().create_timer(.75).timeout	
	picked_up()

func picked_up():
	%Sprite2D.hide()
	$SmallShadow.hide()
	%Sprite2D/AudioStreamPlayer2D.pitch_scale = randf_range(0.9,1.2)
	t.kill()
	%Sprite2D/AudioStreamPlayer2D.play()
	await %Sprite2D/AudioStreamPlayer2D.finished
	queue_free()
