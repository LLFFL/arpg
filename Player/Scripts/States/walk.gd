class_name State_Walk extends State

@onready var idle: State = $"../Idle"


func enter() -> void:
	state_machine.ability_state_machine.ability_ended.connect(update_anim)
	player.update_animation("run")
	player.animation_player.speed_scale = 1.5
	


func exit() -> void:
	state_machine.ability_state_machine.ability_ended.disconnect(update_anim)
	player.animation_player.speed_scale = 1
	pass

func process( _delta: float ) -> State:
	if player.direction == Vector2.ZERO:
		return idle
	
	if !player.dying:
		player.velocity = player.direction * player.stats.movement_speed
	else:
		return idle
	
	if player.set_direction():
		player.update_animation("run")
	
	return null

func physics( _delta: float ) -> State:
	return null

func handle_input( _event: InputEvent ) -> State:
	return null

func update_anim():
	player.update_animation("run")
