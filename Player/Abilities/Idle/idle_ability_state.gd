class_name IdleAbilityState extends AbilityState

func enter() -> void:
	pass

func exit() -> void:
	pass

func process( _delta: float ) -> AbilityState:
	return null

func physics( _delta: float ) -> AbilityState:
	return null

func handle_input( _event: InputEvent ) -> AbilityState:
	return null
