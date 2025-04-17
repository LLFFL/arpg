class_name UnitStateMachine extends Node

var states: Array[UnitState]
var prev_state: UnitState
var current_state: UnitState

func _ready() -> void:
	pass
	#process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
	change_state( current_state.process(delta) )

func _physics_process(delta: float) -> void:
	change_state( current_state.physics(delta) )

func _unhandled_input(event: InputEvent) -> void:
	change_state(current_state.handle_input(event))


func initialize( _unit: Unit ) -> void:
	states = []
	
	for c in get_children():
		if c is UnitState:
			states.append(c)
			c.unit = _unit
			c.state_machine = self
	
	if states.size() == 0:
		return

	for state in states:
		state.init()
	change_state( states[0] )
	#process_mode = Node.PROCESS_MODE_INHERIT



func change_state( new_state: UnitState ) -> void:
	if new_state == current_state || new_state == null:
		return
	
	if current_state:
		current_state.unit.update_anim("RESET")
		current_state.exit()
	
	prev_state = current_state
	current_state = new_state
	
	current_state.enter()
