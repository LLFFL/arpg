class_name Player extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DIR_4 = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
#const LOOK_DIR = ["R", "RD", "D", "LD", "L", "LU", "U", "RU"]
const LOOK_DIR = [Vector2(1,0), Vector2(1,-1), Vector2(0,-1), Vector2(-1,-1), Vector2(-1,0), Vector2(-1,1), Vector2(0,1), Vector2(1,1)]

var cardinal_direction: Vector2 = Vector2.DOWN
var look_direction: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO
var mouse_direction: Vector2 = Vector2.ZERO

@onready var move_state_machine: PlayerMoveStateMachine = $MoveStateMachine
@onready var ability_state_machine: AbilityStateMachine = $AbilityStateMachine

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D




func _ready() -> void:
	move_state_machine.initialize(self)
	ability_state_machine.initialize(self)
	
func _process(delta: float) -> void:
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()
	var mouse_pos: Vector2 = get_global_mouse_position()
	mouse_direction = global_position.direction_to(mouse_pos).normalized()

func _physics_process(delta: float) -> void:
	move_and_slide()

func update_animation(state: String) -> void:
	animation_player.play( state + anim_direction())

func set_direction() -> bool:
	var look_id: int = int(round((direction + cardinal_direction * 0.1).angle() / TAU * DIR_4.size()))
	var new_direction: Vector2 = DIR_4[look_id]
	
	if new_direction == cardinal_direction:
		return false
	
	cardinal_direction = new_direction
	return true

func anim_direction() -> String:
	if cardinal_direction == Vector2.LEFT:
		return "Left"
	elif cardinal_direction == Vector2.RIGHT:
		return "Right"
	elif cardinal_direction == Vector2.UP:
		return "Up"
	elif cardinal_direction == Vector2.DOWN:
		return "Down"
	return ""

#one global: referenced as PlayerStats, responsible for input blocking on transitions and player hp as of 4/9/2025
#Mark Projectile code
var aim_position : Vector2 = Vector2(1, 0)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var half_viewport = get_viewport_rect().size / 2.0
		aim_position = (event.position - half_viewport)

#End projectile code
