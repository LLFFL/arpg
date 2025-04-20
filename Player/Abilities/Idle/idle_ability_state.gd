class_name IdleAbilityState extends AbilityState
#import where it can go
@onready var cast_ability: CastAbilityState = $"../CastAbility"
@onready var thrust: MeleeAbilityState = $"../Thrust"
const LeechSpell = preload("res://Upgrades/Scripts/LeechSpell.gd")

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
	if Input.is_action_just_pressed("r_cast"):
		#print("r_cast pressed")
		var spell := LeechSpell.new()
		get_tree().current_scene.add_child(spell) 
		#spell.player_healed.connect(ui._on_player_healed)
		spell.apply_effects(player)
		
	if combo_attack != null:
		if _event.is_action_pressed(combo_attack.input):
			return combo_attack.state
	
#	if _event is InputEventKey and _event.pressed:
#		if _event.keycode in [KEY_1, KEY_2, KEY_3, KEY_4]:
#			return cast_ability
	
	if _event.is_action_pressed("Melee"):
		return thrust
	
	return null
