extends Node2D


func _ready():
	PlayerManager.game_won = false
	$TextureButton.disabled = true
	if !PlayerManager.game_started:
		var t = create_tween()
		for child in $Splashes.get_children():
			#t.tween_property(child,"modulate:a",1,3)
			t.tween_property(child,"modulate:a",0,0.1).set_delay(2)
			#t.tween_property(child,"modulate:a",0,1)
			t.tween_callback(child.hide)
		await t.finished
	else:
		$Splashes.visible = false
	$TextureButton.disabled = false
	pass
	# used to randomise frog order
	#for child in $HBoxContainer.get_children():
		#$HBoxContainer.move_child(child,randi_range(0,5))


func _on_screen_shake_button_toggled(toggled_on):
	Options.screen_shake_enabled = toggled_on
	if toggled_on:
		$ShakerComponent2D.play_shake()


func _on_shake_slider_drag_ended(value_changed):
	Options.screen_shake_intensity = $VBoxContainer/HBoxContainer3/ShakeSlider.value
	$ShakerComponent2D.intensity = $VBoxContainer/HBoxContainer3/ShakeSlider.value
	$ShakerComponent2D.play_shake()


func _on_texture_button_pressed() -> void:
	
	if !PlayerManager.game_started:
		get_tree().change_scene_to_file("res://christophe/World/game_world.tscn")
	else:
		var nodes = get_tree().root.get_children()
		for node in nodes:
			if node.has_method("resume"):
				node.resume()
		queue_free()
	pass # Replace with function body.
