class_name CooldownManager extends Node2D

var state_machine: AbilityStateMachine
var states_on_cooldown: Array[AbilityState]


func init() -> void:
	for s in state_machine.states:
		s.ability_started.connect(_on_ability_start)


func _on_ability_start(_s: AbilityState) -> void:
	states_on_cooldown.append(_s)
	_s.is_on_cooldown = true
	_s.cooldown = _s.base_cooldown
	pass

func _process(delta: float) -> void:
	if states_on_cooldown.size() <= 0:
		return
	
	for s in states_on_cooldown:
		s.cooldown -= delta
		if s.cooldown <= 0:
			s.reset_cooldown()
			states_on_cooldown.erase(s)
	
	#for i in states_on_cooldown.size():
		#states_on_cooldown[i].cooldown -= delta
		#if states_on_cooldown[i].cooldown <= 0:
			#states_on_cooldown[i].reset_cooldown()
			#states_on_cooldown.remove_at(i)
