class_name State_Idle extends State

@onready var walk: State = $"../Walk"

func init():
	state_machine.ability_state_machine.ability_ended.connect(update_anim)

func enter() -> void:
	update_anim()


func exit() -> void:
	pass

func process( _delta: float ) -> State:
	if player.direction != Vector2.ZERO:
		return walk
	if player.set_direction():
		update_anim()
	player.velocity = Vector2.ZERO
	return null

func physics( _delta: float ) -> State:
	return null

func handle_input( _event: InputEvent ) -> State:
	return null

func update_anim():
	player.update_animation("idle")
