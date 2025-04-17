class_name UnitState extends Node

var unit: Unit
var state_machine: UnitStateMachine

func _ready() -> void:
	pass # Replace with function body.

func init() -> void:
	pass

func enter() -> void:
	pass


func exit() -> void:
	pass

func process( _delta: float ) -> UnitState:
	return null

func physics( _delta: float ) -> UnitState:
	return null

func handle_input( _event: InputEvent ) -> UnitState:
	return null
