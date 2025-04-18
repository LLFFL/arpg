class_name State_Idle extends State

@onready var walk: State = $"../Walk"


func enter() -> void:
	state_machine.ability_state_machine.ability_ended.connect(update_anim)
	update_anim()


func exit() -> void:
	state_machine.ability_state_machine.ability_ended.disconnect(update_anim)
	pass

func process( _delta: float ) -> State:
	if player.direction != Vector2.ZERO:
		return walk
	if player.set_direction():
		update_anim()
	
	if player.soft_collision.is_colliding():
		player.velocity = player.soft_collision.get_push_vector() * _delta * 100
	else:
		player.velocity = Vector2.ZERO
	return null

func physics( _delta: float ) -> State:
	return null

func handle_input( _event: InputEvent ) -> State:
	return null

func update_anim():
	player.update_animation("idle")
