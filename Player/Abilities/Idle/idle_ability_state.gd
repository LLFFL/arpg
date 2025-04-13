class_name IdleAbilityState extends AbilityState
#import where it can go
@onready var cast_ability: CastAbilityState = $"../CastAbility"
@onready var melee: MeleeAbilityState = $"../Melee"


func enter() -> void:
	pass

func exit() -> void:
	combo_attack = null
	pass

func process( _delta: float ) -> AbilityState:
	return null

func physics( _delta: float ) -> AbilityState:
	return null

#If in combo attack, check if in combo attack then decide if Ability is melee or ability
func handle_input( _event: InputEvent ) -> AbilityState:
	if combo_attack != null:
		if _event.is_action_pressed(combo_attack.input):
			return combo_attack.state
	if _event.is_action_pressed("tilde"):
		return cast_ability
	if _event.is_action_pressed("Melee"):
		return melee
	return null
