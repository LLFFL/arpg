class_name Melee2AbilityState extends AbilityState

@onready var idle: IdleAbilityState = $"../Idle"

var in_progress: bool = false

var timer: Timer

func enter() -> void:
	print("Melee2 start")
	in_progress = true
	player.ability_active = true
	player.update_ability_animation("melee_2")
	player.ability_animation.animation_finished.connect(_on_animation_finish)
	pass
#Combos here, state and input
#Every state has access to combo attack
#when exit melee state, create new ComboAttack,new in melee_ability_state
#half second window aftter slash that stores next attack IF you click it.
#When timer above ends, it exits the combo attack
func exit() -> void:
	player.ability_animation.animation_finished.disconnect(_on_animation_finish)
	player.ability_active = false
	print("melee2 exit")
	pass

func process( _delta: float ) -> AbilityState:
	if !in_progress:
		return idle
	return null

func physics( _delta: float ) -> AbilityState:
	return null

func handle_input( _event: InputEvent ) -> AbilityState:
	return null

func _on_animation_finish(name: String):
	in_progress = false
