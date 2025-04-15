class_name State_Walk extends State

@export var walk_speed: float = 100.0

@onready var idle: State = $"../Idle"

func enter() -> void:
	player.update_animation("run")


func exit() -> void:
	pass

func process( _delta: float ) -> State:
	if player.direction == Vector2.ZERO:
		return idle
	
	player.velocity = player.direction * walk_speed
	
	if player.set_direction():
		player.update_animation("run")
	
	return null

func physics( _delta: float ) -> State:
	return null

func handle_input( _event: InputEvent ) -> State:
	return null

func update_anim():
	player.update_animation("run")
