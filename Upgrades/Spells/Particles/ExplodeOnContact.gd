extends Area2D
## Plays audio and particles explosion on meteor spell

var has_played = false

func _on_body_entered(body):
	if has_played:return
	has_played = true
	#pass # Replace with function body.
	get_viewport().get_camera_2d().get_node("ShakerComponent2D").play_shake()
	$Explosition/AudioStreamPlayer2D.play()
	$Explosition.restart()
	$Explosition.global_position = global_position
	$Explosition.reparent(get_parent().get_parent())
