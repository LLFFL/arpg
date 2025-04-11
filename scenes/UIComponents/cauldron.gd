extends Control
var cauldron_interface_active = false
var humans_erased = false
var water_erased = false
var prosperity_erased = false
var waiting = false
signal wait_begin

var humans_are_erased_flavor_text = 'The humans of this land have been wiped out by a mysterious force'
var humans_are_not_erased_flavor_text = 'Click to erase the humans of this land'
var water_is_erased_flavor_text = 'All the water has dried up due to a mysterious force'
var water_is_not_erased_flavor_text = 'Click to erase the water of this land'
var prosperity_is_erased_flavor_text = 'This land has had all of it\'s Prosperity erased'
var prosperity_is_not_erased_flavor_text = 'Click to erase the prosperity of this land'

signal cauldron_interface_toggle
signal cauldron_interface_closed
signal humans_button_pressed
signal water_button_pressed
signal prosperity_button_pressed

func _ready() -> void:
	hide()





func call_cauldron_menu():
	show()
	#%RemoveHumans.grab_focus()
	cauldron_interface_active = true
	cauldron_interface_toggle.emit(cauldron_interface_active)
	
	
func close_cauldron_menu():
	PlayerProperties.people_toggle = humans_erased
	PlayerProperties.water_toggle = water_erased
	PlayerProperties.prosperity_toggle = prosperity_erased
	hide()
	


func _on_remove_humans_pressed() -> void:
	if (not waiting):
		%AudioStreamPlayer2D.play()
		humans_erased = not humans_erased
		water_erased = false
		prosperity_erased = false
		if (humans_erased):
			humans_button_pressed.emit(humans_are_erased_flavor_text)
		else:
			humans_button_pressed.emit(humans_are_not_erased_flavor_text)
		_on_wait_begin()
	
	

func _on_remove_water_pressed() -> void:
	if(not waiting):
		%AudioStreamPlayer2D.play()
		water_erased = not water_erased
		humans_erased = false
		prosperity_erased = false
		if (water_erased):
			water_button_pressed.emit(water_is_erased_flavor_text)
		else:
			water_button_pressed.emit(water_is_not_erased_flavor_text)
		_on_wait_begin()

func _on_remove_prosperity_pressed() -> void:
	if ( not waiting ):
		%AudioStreamPlayer2D.play()
		prosperity_erased = not prosperity_erased
		humans_erased = false
		water_erased = false
		if (prosperity_erased):
			prosperity_button_pressed.emit(prosperity_is_erased_flavor_text)
		else:
			prosperity_button_pressed.emit(prosperity_is_not_erased_flavor_text)
		_on_wait_begin()


func _on_wait_begin() -> void:
	if (not waiting):
		waiting = true
		await get_tree().create_timer(1).timeout
		waiting = false
