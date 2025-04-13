class_name MeleeAbilityState extends AbilityState

@onready var idle: IdleAbilityState = $"../Idle"
@onready var melee_2: Node = $"../Melee2"

var in_progress: bool = false

var timer: Timer

func enter() -> void:
	print("melee1 start")
	in_progress = true
	player.ability_active = true
	player.update_ability_animation("melee_1")
	player.ability_animation.animation_finished.connect(_on_animation_finish)
	
	if timer:
		timer.queue_free()
	timer = Timer.new()
	timer.wait_time = 0.5
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	pass
#Combos here, state and input
#Every state has access to combo attack
#when exit melee state, create new ComboAttack,new in melee_ability_state
#half second window aftter slash that stores next attack IF you click it.
#When timer above ends, it exits the combo attack
func exit() -> void:
	player.ability_animation.animation_finished.disconnect(_on_animation_finish)
	player.ability_active = false
	print("melee1 exit")
	combo_attack = ComboAttack.new()
	combo_attack.state = melee_2
	combo_attack.input = "Melee"
	timer.start()
	pass

func process( _delta: float ) -> AbilityState:
	if !in_progress:
		return idle
	return null

func physics( _delta: float ) -> AbilityState:
	return null

func handle_input( _event: InputEvent ) -> AbilityState:
	return null

func _on_timer_timeout():
	combo_attack = null
	timer.queue_free()

func _on_animation_finish(name: String):
	in_progress = false
