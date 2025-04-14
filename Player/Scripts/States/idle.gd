class_name State_Idle extends State

@onready var walk: State = $"../Walk"

func enter() -> void:
	player.update_animation("idle")


func exit() -> void:
	pass

func process( _delta: float ) -> State:
	if player.direction != Vector2.ZERO:
		return walk
	if player.set_direction():
		player.update_animation("idle")
	player.velocity = Vector2.ZERO
	return null

func physics( _delta: float ) -> State:
	return null

func handle_input( _event: InputEvent ) -> State:
	#if _event.is_action_pressed("attack"):
		#return attack
	#if _event.is_action_pressed("interact"):
		#PlayerManager.interact_pressed.emit()
	return null
