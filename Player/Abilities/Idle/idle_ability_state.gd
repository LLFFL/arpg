class_name IdleAbilityState extends AbilityState
#import where it can go
@onready var cast_ability: CastAbilityState = $"../CastAbility"

func enter() -> void:
	pass

func exit() -> void:
	pass

func process( _delta: float ) -> AbilityState:
	return null

func physics( _delta: float ) -> AbilityState:
	return null

func handle_input( _event: InputEvent ) -> AbilityState:
	if _event.is_action_pressed("tilde"):
		return cast_ability
	return null
