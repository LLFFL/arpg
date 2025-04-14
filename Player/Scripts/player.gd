class_name Player extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DIR_4 = [Vector2.RIGHT, Vector2.LEFT]
#const LOOK_DIR = ["R", "RD", "D", "LD", "L", "LU", "U", "RU"]
const LOOK_DIR = [Vector2(1,0), Vector2(1,-1), Vector2(0,-1), Vector2(-1,-1), Vector2(-1,0), Vector2(-1,1), Vector2(0,1), Vector2(1,1)]

var cardinal_direction: Vector2 = Vector2.RIGHT
var look_direction: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO
var mouse_direction: Vector2 = Vector2.ZERO
var knockback = Vector2.ZERO
var animation_queue: String = ""
@onready var hurtbox = %HurtBox 
@onready var label: Label = $Label

var ability_active: bool = false

@onready var move_state_machine: PlayerMoveStateMachine = $MoveStateMachine
@onready var ability_state_machine: AbilityStateMachine = $AbilityStateMachine

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var ability_animation: AnimationPlayer = $AbilityAnimation


func _ready() -> void:
	PlayerManager.player = self
	move_state_machine.initialize(self)
	ability_state_machine.initialize(self)
	hurtbox.damaged.connect(damage)
	
func _process(delta: float) -> void:
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()
	var mouse_pos: Vector2 = get_global_mouse_position()
	mouse_direction = global_position.direction_to(mouse_pos).normalized()
	
	label.text = str(ability_state_machine.current_state.name)

	#label.text = str(ability_state_machine.current_state.name) +" "+ str(ability_state_machine.current_state.is_on_cooldown)
	if animation_queue != "" && !ability_active:
		update_animation(animation_queue)

func _physics_process(delta: float) -> void:
	move_and_slide()

func update_animation(state: String) -> void:
	if !ability_active:
		if animation_queue == "":
			animation_player.play( state )
		else:
			animation_player.play(animation_queue)
			animation_queue = ""
	else:
		animation_queue = state

func update_ability_animation(state: String) -> void:
	if ability_active:
		sprite_2d.scale.x = -1 if get_local_mouse_position().x < 0 else 1
		ability_animation.play( state )

func set_direction() -> bool:
	if direction == Vector2.ZERO:
		return false
	
	var new_dir: Vector2 = cardinal_direction
	if direction.x < 0:
		new_dir = Vector2.LEFT
	else:
		new_dir = Vector2.RIGHT
	
	if ability_active:
		if get_local_mouse_position().x < 0:
			new_dir = Vector2.LEFT
		else:
			new_dir = Vector2.RIGHT
	
	if new_dir == cardinal_direction:
		return false
	cardinal_direction = new_dir
	
	sprite_2d.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	
	return true

func anim_direction() -> String:
	if cardinal_direction == Vector2.LEFT:
		return "Left"
	elif cardinal_direction == Vector2.RIGHT:
		return "Right"
	return ""

#one global: referenced as PlayerStats, responsible for input blocking on transitions and player hp as of 4/9/2025
#Mark Projectile code
var aim_position : Vector2 = Vector2(1, 0)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var half_viewport = get_viewport_rect().size / 2.0
		aim_position = (event.position - half_viewport)

#End projectile code
#Mark magic
@onready var projectile_position: Marker2D = $ProjectilePosition
func _input(event):
	if event is InputEventKey and event.pressed:
		var spawn_pos = projectile_position.global_position
		var mouse_pos = get_global_mouse_position()
		var direction = mouse_pos - spawn_pos
		match event.keycode:
			KEY_1:
				cast_spell(0, spawn_pos, direction)
			KEY_2:
				cast_spell(1, spawn_pos, direction)
			KEY_3:
				cast_spell(2, spawn_pos, direction)
			KEY_4:
				cast_spell(3, spawn_pos, direction)
				
func cast_spell(index: int, cast_position: Vector2, mouse_direction: Vector2):
	if index >= PlayerStats.upgrades.size():
		return

	var spell = PlayerStats.upgrades[index]
	var projectile = PlayerStats.projectile_scene.instantiate() as Projectile
	
	projectile.spell = PlayerStats.upgrades[index]

	get_tree().root.add_child(projectile)
	projectile.global_position = cast_position
	projectile.rotation = mouse_direction.angle()
	
	projectile.damage = spell.damage
	projectile.speed = spell.speed
	projectile.max_pierce = spell.max_pierce
	projectile.icon.texture = spell.icon_texture

func damage(attack: Attack) -> void:
	PlayerStats.health -= attack.damage
	hurtbox.start_invincibility(0.4)
	hurtbox.create_hit_effect()
	var _direction = (position - get_global_mouse_position()).normalized()
	knockback = _direction * 240
	velocity = knockback
