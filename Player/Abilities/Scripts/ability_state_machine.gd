class_name AbilityStateMachine extends Node

const GCD: float = 1

var states: Array[AbilityState]
#Track states, set when state is changed
var prev_state: AbilityState
var current_state: AbilityState

var cooldown_manager: CooldownManager

var global_cooldown: float = GCD
var is_on_gcd: bool = false

@onready var cast_ability: CastAbilityState = $CastAbility

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	#current_state = cast_ability
func _process(delta: float) -> void:
	#current_state.player.label.text = str(current_state.name)
		
	if is_on_gcd:
		global_cooldown -= delta
		if global_cooldown <= 0:
			reset_gcd()
		
	change_state( current_state.process(delta) )

func _physics_process(delta: float) -> void:
	change_state( current_state.physics(delta) )
	


func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("dash"):
		#if states.size() > 0:
			#for s in states:
				#if s is AbilityDashState:
					#change_state(s)
	change_state(current_state.handle_input(event))


func initialize( _player: Player ) -> void:
	states = []
	
	for c in get_children():
		if c is AbilityState:
			states.append(c)
		if c is CooldownManager:
			cooldown_manager = c
			cooldown_manager.state_machine = self
			cooldown_manager.init()
	if states.size() == 0:
		return
	
	states[0].player = _player
	states[0].state_machine = self
	
	for state in states:
		state.init()
	change_state( states[0] )
	process_mode = Node.PROCESS_MODE_INHERIT

func reset_gcd() -> void:
	is_on_gcd = false
	global_cooldown = GCD

func trigger_gcd() -> void:
	global_cooldown = GCD
	is_on_gcd = true

#validate if new state is new, not to infinitely loop current
func change_state( new_state: AbilityState ) -> void:
	if new_state == current_state || new_state == null:
		return

	
	if current_state:
		current_state.exit()
	
	prev_state = current_state
	current_state = new_state
	
	current_state.enter()
