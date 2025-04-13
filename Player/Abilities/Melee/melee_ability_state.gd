class_name MeleeAbilityState extends AbilityState

@onready var idle: IdleAbilityState = $"../Idle"
@onready var cast_ability: CastAbilityState = $"../CastAbility"


var timer: Timer

func enter() -> void:
	print("bam")
	timer = Timer.new()
	timer.wait_time = 0.5
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	pass

func exit() -> void:
	print("Exit")
	combo_attack = ComboAttack.new()
	combo_attack.state = cast_ability
	combo_attack.input = "attack"
	timer.start()
	pass

func process( _delta: float ) -> AbilityState:
	return null

func physics( _delta: float ) -> AbilityState:
	return null

func handle_input( _event: InputEvent ) -> AbilityState:
	if _event.is_action_pressed("roll"):
		return idle
	return null

func _on_timer_timeout():
	combo_attack = null
	timer.queue_free()
