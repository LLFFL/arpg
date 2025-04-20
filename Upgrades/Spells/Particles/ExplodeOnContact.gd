extends Area2D
## Plays audio and particles explosion on meteor spell

func _on_body_entered(body):
	#pass # Replace with function body.
	get_viewport().get_camera_2d().get_node("ShakerComponent2D").play_shake()
	$Explosition/AudioStreamPlayer2D.play()
	$Explosition.restart()
	$Explosition.global_position = global_position
	$Explosition.reparent(get_parent().get_parent())
