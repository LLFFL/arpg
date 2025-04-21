class_name AbilityState extends Node2D

signal ability_started(state)

static var player: Player
static var state_machine: AbilityStateMachine

var is_on_cooldown: bool = false

var base_cooldown: float
@export var cooldown: float

#Combos here, state and input
#Every state has access to combo attack
#when exit melee state, create new ComboAttack,new in melee_ability_state
#half second window aftter slash that stores next attack IF you click it.
class ComboAttack:
	var state: AbilityState
	var input: String

static var combo_attack: ComboAttack = null

func _ready() -> void:
	pass # Replace with function body.

func init() -> void:
	base_cooldown = cooldown
	combo_attack = null
	pass

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

func reset_cooldown() -> void:
	is_on_cooldown = false
	cooldown = base_cooldown
	pass
