class_name Player extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DIR_4 = [Vector2.RIGHT, Vector2.LEFT]
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
@onready var soft_collision: Area2D = $SoftCollision

@onready var move_state_machine: PlayerMoveStateMachine = $MoveStateMachine
@onready var ability_state_machine: AbilityStateMachine = $AbilityStateMachine

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var ability_animation: AnimationPlayer = $AbilityAnimation
@onready var stats: PlayerStats = $Stats
@onready var ui: Control = $"../CameraHandler/Camera2D/CanvasLayer/UI"
@onready var test: Node2D
@onready var player_hp_ui: TextureProgressBar = %PlayerHPUi

var dying: bool = false

func _ready() -> void:
	PlayerManager.player = self
	stats.no_health.connect(_on_death)
	move_state_machine.initialize(self)
	ability_state_machine.initialize(self)
	hurtbox.damaged.connect(damage)
	hurtbox.damaged2.connect(damage2)
	stats.dmg_status_changed.connect(func(active: bool, buff: bool):
		if !active:
			print('status ended')
		else:
			if buff:
				print("buff started")
			else:
				print("debuff startd")
		)
	ui.initialize_health_player(stats.max_health)
	ui.on_health_changed_player(stats.max_health)
func _process(delta: float) -> void:
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()
	direction.y *= 0.8
	var mouse_pos: Vector2 = get_global_mouse_position()
	mouse_direction = global_position.direction_to(mouse_pos).normalized()
	if dying:
		velocity = Vector2.ZERO
	
	#label.text = str(ability_state_machine.current_state.name) + "\n" + str(move_state_machine.current_state.name)
	#label.text = str(stats.base_damage) +'\n' + str(stats.base_defence) +'\n' + str(stats.base_movement_speed) +'\n' + str(stats.luck)
	#label.text = str(stats.gold) + "\n" + str(stats.luck)
	#if stats.dmg_timer:
		#label.text = str(stats.dmg_timer.time_left)
	#label.text = str(stats.base_damage_modifier)
	#label.text = str(ability_state_machine.key_pressed)
	#label.text = str(ability_state_machine.current_state.name) +" "+ str(ability_state_machine.current_state.is_on_cooldown)
	if animation_queue != "" && !ability_active:
		update_animation(animation_queue)

func _physics_process(delta: float) -> void:
	move_and_slide()

func update_animation(state: String) -> void:
	if dying:
		return
	if !ability_active:
		ability_animation.stop()
		if animation_queue == "":
			animation_player.play( state )
		else:
			animation_player.play(animation_queue)
			animation_queue = ""
		animation_player.seek(0.0, true)
	else:
		animation_queue = state

func update_ability_animation(state: String) -> void:
	if ability_active && !dying:
		animation_player.stop()
		sprite_2d.scale.x = -1 if get_local_mouse_position().x < 0 else 1
		ability_animation.play( state )

func set_direction() -> bool:
	if direction == Vector2.ZERO:
		return false
	
	var new_dir: Vector2 = cardinal_direction
	if direction.x < 0:
		new_dir = Vector2.LEFT
	elif direction.x > 0:
		new_dir = Vector2.RIGHT
	else:
		new_dir = cardinal_direction
	
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

func damage(attack: Attack) -> void:
	var dmg = attack.damage - stats.defence
	stats.health -= dmg if dmg > 0 else 0
	hurtbox.start_invincibility(0.4)
	hurtbox.create_hit_effect()
	var _direction = (position - get_global_mouse_position()).normalized()
	knockback = _direction * 240
	velocity = knockback
	#health change
	ui.on_health_changed_player(stats.health)
	# Animate the player when they get hit
	# Could change animation to remap intensity with attack
	$AudioStreamPlayer.play()
	var t = create_tween()
	t.tween_property($Sprite2D,"scale:y",1.3,0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property($Sprite2D,"scale:y",1,0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await t.finished
	t.kill()
	$Sprite2D.scale.y = 1

func damage2(projectile: InstancedProjectile2D) -> void:
	#print("Damage 2 triggered- Player current health:  ", stats.health)
	var dmg = projectile.resource.damage - stats.defence
	stats.health -= dmg if dmg > 0 else 0
	#UI change
	ui.on_health_changed_player(stats.health)
	hurtbox.start_invincibility(0.6)
	hurtbox.create_hit_effect()
	var _direction = (position - get_global_mouse_position()).normalized()
	knockback = _direction * 240
	velocity = knockback
	
	$AudioStreamPlayer.play()
	var t = create_tween()
	t.tween_property($Sprite2D,"scale:y",1.3,0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property($Sprite2D,"scale:y",1,0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await t.finished
	t.kill()
	$Sprite2D.scale.y = 1

signal player_died
func _on_death():
	dying = true
	hurtbox.set_deferred("monitorable", false)
	animation_player.stop()
	animation_player.play("death")
	pass

func _on_death_finished():
	player_died.emit()
	hurtbox.set_deferred("monitorable", true)
	dying = false
	pass
