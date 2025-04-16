class_name AbilityStateMachine extends Node2D

const GCD: float = 0.3

var states: Array[AbilityState]
var prev_state: AbilityState
var current_state: AbilityState

var cooldown_manager: CooldownManager

var global_cooldown: float = GCD
var is_on_gcd: bool = false

var key_pressed: InputEvent = null

signal ability_ended()

@onready var cast_ability: CastAbilityState = $CastAbility


#Each child node should be its own specific move.

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
	if is_on_gcd:
		global_cooldown -= delta
		if global_cooldown <= 0:
			reset_gcd()
	if PlayerManager.player.stats.stunned:
		return
	change_state( current_state.process(delta) )

func _physics_process(delta: float) -> void:
	if PlayerManager.player.stats.stunned:
		return
	change_state( current_state.physics(delta) )


func _unhandled_input(event: InputEvent) -> void:
	if PlayerManager.player.stats.stunned:
		return
	if event is InputEventMouseButton or event is InputEventKey:
		key_pressed = event
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
	
	if new_state != states[0] && (is_on_gcd || new_state.is_on_cooldown):
		return
	
	if current_state:
		current_state.exit()
		PlayerManager.player.stats.reset_effect_damage()
		if current_state != states[0]:
			ability_ended.emit()
	
	prev_state = current_state
	current_state = new_state
	
	current_state.enter()
	#key_pressed = null
