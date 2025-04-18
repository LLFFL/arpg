extends Node2D



func _input(event):
	if event.is_action_pressed("ui_accept"):
		$vfx.setup()
		%vfx2.setup()
		#await get_tree().create_timer(0.2).timeout
		$vfx.start()
		%vfx2.start()
		#await $vfx.finished
		#$vfx.finished
		#$vfx.queue_free()
		#print("killed vfx")
	if event.is_action_released("ui_accept"):
		$vfx.force_stop()
		%vfx2.stop(0)
