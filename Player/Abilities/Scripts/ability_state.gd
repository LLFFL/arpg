class_name AbilityState extends Node

signal ability_started(state)

static var player: Player
static var state_machine: AbilityStateMachine

var is_on_cooldown: bool = false

func _ready() -> void:
	pass # Replace with function body.

func init() -> void:
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
	pass
