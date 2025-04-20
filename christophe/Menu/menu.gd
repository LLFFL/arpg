extends Node2D


func _ready():
	pass
	# used to randomise frog order
	#for child in $HBoxContainer.get_children():
		#$HBoxContainer.move_child(child,randi_range(0,5))




func _on_start_button_pressed():
		get_tree().change_scene_to_file("res://christophe/World/game_world.tscn")


func _on_screen_shake_button_toggled(toggled_on):
	Options.screen_shake_enabled = toggled_on
	if toggled_on:
		$ShakerComponent2D.play_shake()


func _on_shake_slider_drag_ended(value_changed):
	Options.screen_shake_intensity = $VBoxContainer/HBoxContainer3/ShakeSlider.value
	$ShakerComponent2D.intensity = $VBoxContainer/HBoxContainer3/ShakeSlider.value
	$ShakerComponent2D.play_shake()
