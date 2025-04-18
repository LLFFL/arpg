class_name CharacterTest
extends CharacterBody2D


@export_group("Main Attributes")
@export var on_walk_move_speed: float = 300.0
@export var on_jump_move_speed: float = 400.0
@export var on_attack_move_speed: float = 90.0
@export var on_jump_and_attack_move_speed: float = 90.0

@export var jump_velocity: float = -400.0
@export var gravity_amplification: float = 1.0
@export var will_look_at_mouse: bool = false
@export var audio_scene: PackedScene

@export_group("Collsion Offsets")
@export var coll_move_offset: Vector2

@export_group("Weapons")
@export var start_attack: int
@export var weapons: Array[AttackBlueprint]

@export_group("Jump Delays")
@export var jump_anticipation_duration: float
@export var landind_recovery_duration: float


@onready var projectile_caller: ProjectileCaller2D = $ProjectileCaller2D
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var basic_timer: Timer = $BasicTimer

@onready var collision: CollisionShape2D = $Collision
@onready var base_coll_pos: Vector2 = collision.position

@onready var direction: int = 0
@onready var facing_direction: int = 1

var selected_attack: AttackBlueprint
var selected_projectile_id: int
var hover_projectile_id: int

var charge_delta: float


enum AllowActions{
	MOVE, JUMP, JUMP_CANCEL, ROTATE, LOOK_MOUSE
}
var attack_loop_allow_actions: int

enum States{
	IDLE, WALK, JUMP_ANTICIPATE, JUMP, FALL, LANDING_RECOVERY, ATTACK_CHARGE, ATTACK_ANTICIPATE, ATTACK, ATTACK_RECOVERY
}
var current_state: States = States.IDLE
var previous_state: States = States.IDLE

var next_state: States = States.IDLE
var next_animation_speed: float
var next_can_skip_states: bool



func _ready() -> void:
	basic_timer.timeout.connect(func() -> void: change_state(next_state, next_animation_speed, next_can_skip_states))
	selected_attack = weapons[start_attack]
	selected_projectile_id = start_attack
	hover_projectile_id = start_attack


func cycle_weapons(ammount: int) -> void:
	# if (current_state in [States.ATTACK_CHARGE, States.ATTACK_ANTICIPATE, States.ATTACK]):
	# 	return false

	if (hover_projectile_id + ammount) >= weapons.size():
		hover_projectile_id = 0
	elif (hover_projectile_id + ammount) < 0:
		hover_projectile_id = weapons.size() - 1
	else:
		hover_projectile_id += ammount



func special_charge() -> void:
	pass

func change_state(_state: States, current_animation_speed: float = 1.0, can_skip_stages: bool = true, _next_animation_speed: float = 1.0) -> void:
	previous_state = current_state
	current_state = _state

	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && can_skip_stages):
		if (selected_attack.on_change_transition_actions & (1 << current_state)):
			position = collision.global_position - base_coll_pos
			collision.position = base_coll_pos
			change_state(determine_attack_state(current_state), 1.0, can_skip_stages)
			return

	match current_state:
		States.IDLE:
			collision.position = base_coll_pos
		States.JUMP_ANTICIPATE:
			set_timed_state_change(States.JUMP, jump_anticipation_duration, "jump_anticipate", current_animation_speed, can_skip_stages)
		States.JUMP:
			velocity.y = jump_velocity
			animator.play("jump", -1, current_animation_speed)
		States.FALL:
			animator.play("fall", -1, current_animation_speed)
		States.LANDING_RECOVERY:
			velocity = Vector2.ZERO
			position += collision.position - base_coll_pos
			collision.position = base_coll_pos
			set_timed_state_change(States.IDLE, landind_recovery_duration, "landing_recovery", current_animation_speed, can_skip_stages)
		States.ATTACK_CHARGE:
			attack_loop_allow_actions = selected_attack.charging_actions
			if (selected_attack.attack_charge_time <= 0):
				change_state(States.ATTACK_ANTICIPATE)
				return
			#set_timed_state_change(States.ATTACK_ANTICIPATE, selected_attack.attack_charge_time, "attack_charge", animation_speed, can_skip_stages)
			animator.play("attack_charge", -1, current_animation_speed)
			animator.advance(0)
			if (selected_attack.charge_audio != null):
				create_audio_player(selected_attack.charge_audio, selected_attack.charge_heastart, selected_attack.charge_db)
			special_charge()
		States.ATTACK_ANTICIPATE:
			attack_loop_allow_actions = selected_attack.anticipate_actions
			if (selected_attack.attack_anticipate_time <= 0):
				change_state(States.ATTACK)
				return
			set_timed_state_change(States.ATTACK, selected_attack.attack_anticipate_time, "attack_delay", current_animation_speed, can_skip_stages)
		States.ATTACK:
			attack_loop_allow_actions = selected_attack.execute_actions
			spawn_projectile()
			if (selected_attack.attack_duration_time <= 0):
				change_state(States.ATTACK_RECOVERY)
				return
			set_timed_state_change(States.ATTACK_RECOVERY, selected_attack.attack_duration_time, "attack", current_animation_speed, true)
			if (selected_attack.release_audio != null):
				create_audio_player(selected_attack.release_audio, selected_attack.release_heastart, selected_attack.release_db)
		States.ATTACK_RECOVERY:
			attack_loop_allow_actions = selected_attack.recovery_actions
			if (selected_attack.attack_recovery_time <= 0):
				change_state(States.IDLE)
				return
			set_timed_state_change(States.IDLE, selected_attack.attack_recovery_time, "attack_recovery", current_animation_speed, can_skip_stages)



func create_audio_player(audio_stream: AudioStream, audio_headstart: float, audio_db: float) -> void:
	var buffer: TimedAudio = audio_scene.instantiate()
	add_child(buffer)
	buffer.timed_free(audio_stream, audio_headstart, audio_db)



func spawn_projectile() -> void:
	var _position: Vector2 = position + Vector2(selected_attack.attack_offset.x * facing_direction, selected_attack.attack_offset.y)
	var destination: Vector2
	if (selected_attack.direction_override != Vector2.ZERO):
		destination = _position + Vector2(selected_attack.direction_override.x * facing_direction, selected_attack.direction_override.y)
	else:
		destination = get_global_mouse_position()

	projectile_caller.request_projectile(hover_projectile_id, _position, destination)



func set_timed_state_change(_next_state: States, time_delay: float, animation_name: String, current_animation_speed: float, can_skip: bool, _next_animation_speed: float = 1.0) -> void:
	next_state = _next_state
	next_animation_speed = _next_animation_speed
	next_can_skip_states = can_skip
	basic_timer.start(time_delay * current_animation_speed)
	animator.play(animation_name, -1, current_animation_speed)
	animator.advance(0)



func determine_attack_state(_current_state: States) -> States:
	if (selected_attack.attack_charge_time > 0 && _current_state != States.ATTACK_CHARGE && _current_state != States.ATTACK_ANTICIPATE):
		return States.ATTACK_CHARGE
	elif (selected_attack.attack_anticipate_time > 0 && _current_state != States.ATTACK_ANTICIPATE):
		return States.ATTACK_ANTICIPATE
	else:
		return States.ATTACK




func _process(_delta: float) -> void:

	direction = 0
	if Input.is_key_pressed(KEY_A):
		direction -= 1
	if Input.is_key_pressed(KEY_D):
		direction += 1

	match current_state:
		# States.IDLE, States.WALK when Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# 	collision.position = base_coll_pos
		# 	determine_attack_state()
		States.IDLE, States.WALK when Input.is_action_just_pressed("ui_accept") && !is_on_air():
			velocity = Vector2.ZERO
			change_state(States.JUMP_ANTICIPATE)
		States.IDLE when direction != 0:
			change_state(States.WALK)
		States.WALK when direction == 0:
			change_state(States.IDLE)
		States.LANDING_RECOVERY when Input.is_action_just_pressed("ui_accept") && basic_timer.time_left <= (landind_recovery_duration * 0.6):
			basic_timer.stop()
			change_state(States.JUMP_ANTICIPATE, 0.35)
		States.ATTACK_CHARGE:

			charge_delta += _delta
			if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
				if (charge_delta > selected_attack.attack_charge_time && selected_attack.charge_trigger == ProjectileConstants.WeaponChargeTrigger.ON_READY):
					change_state(States.ATTACK_ANTICIPATE, 1.0, false)
					charge_delta = 0
				return
			
			if (charge_delta > selected_attack.attack_charge_time):
				change_state(States.ATTACK_ANTICIPATE, 1.0, false)
				charge_delta = 0
				return

			if (selected_attack.charge_type == ProjectileConstants.WeaponChargeType.CONTINOUS):
				charge_delta = 0
			elif (selected_attack.charge_type == ProjectileConstants.WeaponChargeType.MANDATORY):
				return
			change_state(States.IDLE)

		var no_match when Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if (selected_projectile_id != hover_projectile_id):
				selected_projectile_id = hover_projectile_id
				selected_attack = weapons[hover_projectile_id]

			if (selected_attack.on_update_transition_actions & (1 << no_match)):
				position = collision.global_position - base_coll_pos
				collision.position = base_coll_pos
				change_state(determine_attack_state(current_state), 1.0, false)
	
	#print(States.keys()[current_state])




func _physics_process(_delta: float) -> void:

	if is_on_air():
		velocity += get_gravity() * _delta * gravity_amplification

	match current_state:
		States.IDLE:
			flip_sprite_if_mouse(will_look_at_mouse)
			velocity.x = move_toward(velocity.x, 0, on_walk_move_speed)
			animator.play("idle")
		States.WALK:
			flip_sprite_if_needed(direction)
			velocity.x = direction * on_walk_move_speed
			collision.position = base_coll_pos + (coll_move_offset * direction)
			animator.play("walk")
		States.JUMP:
			flip_sprite_if_needed(direction)
			velocity.x = direction * on_jump_move_speed
			if (velocity.y > 0):
				change_state(States.FALL)
		States.FALL:
			flip_sprite_if_needed(direction)
			velocity.x = direction * on_jump_move_speed
			if (!is_on_air()):
				change_state(States.LANDING_RECOVERY)
		States.ATTACK_CHARGE, States.ATTACK_ANTICIPATE, States.ATTACK, States.ATTACK_RECOVERY:
			velocity.x = 0
			if (attack_loop_allow_actions & (1 << AllowActions.MOVE)):
				velocity.x = direction * on_attack_move_speed
			if (attack_loop_allow_actions & (1 << AllowActions.JUMP_CANCEL)):
				if (Input.is_action_pressed("ui_accept") && !is_on_air()):
					basic_timer.stop()
					change_state(States.JUMP)
					move_and_slide()
					return
			if (attack_loop_allow_actions & (1 << AllowActions.JUMP)):
				if (is_on_air() && velocity.x != 0):
					velocity.x = direction * on_jump_and_attack_move_speed
				if (Input.is_action_pressed("ui_accept") && !is_on_air()):
					velocity.y = jump_velocity
			if (attack_loop_allow_actions & (1 << AllowActions.ROTATE)):
				flip_sprite_if_needed(direction)
			if (attack_loop_allow_actions & (1 << AllowActions.LOOK_MOUSE)):
				flip_sprite_if_mouse(true)
	
	move_and_slide()

	


func flip_sprite_if_mouse(can_look_at_moves: bool) -> void:
	if (can_look_at_moves):
		if (get_global_mouse_position().x >= position.x):
			flip_sprite_if_needed(1)
		else:
			flip_sprite_if_needed(-1)

func flip_sprite_if_needed(_direction: int) -> void:
	if (_direction > 0):
		sprite.flip_h = false
		facing_direction = 1
	elif (_direction < 0):
		sprite.flip_h = true
		facing_direction = -1


		

func is_on_air() -> bool:
	if (is_on_floor()):
		return false
	
	if (position.y >= 0):
		if (current_state in [States.JUMP, States.FALL]):
			if (position.y >= (collision.position.y + 40) * -1):
				return false
			return true
		velocity.y = 0;
		position.y = 0
		return false

	return true
