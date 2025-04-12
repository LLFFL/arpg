extends CharacterBody2D

enum {
	ROLL,
	ATTACK,
	MOVE
}
var state = MOVE
const SPEED = 120.0
var roll_vector = Vector2.DOWN
var ROLL_SPEED = 250.0
const ACCELERATION = 900
var stats = PlayerStats

#one global: referenced as PlayerStats, responsible for input blocking on transitions and player hp as of 4/9/2025

@onready var animation_tree = $AnimationTree
@onready var animation_player = $AnimationPlayer
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var hurtbox = $HurtBox
@onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
	animation_tree.active = true
	stats.no_health.connect(queue_free)

func _process(delta: float) -> void: 
	if(PlayerStats.in_transition):
		return
		
	match state:
		MOVE:
			move_state(delta)
			
		ATTACK:
			attack_state(delta)
			
		ROLL:
			roll_state(delta)
	
func attack_state(delta):
	#responsible for player attack logic: animation, hitbox timing, and state transitions
	animation_state.travel('Attack') 
	"""all states that are related to animations will have similar logic and described functioning so I wont be commenting 
	all of them after this"""
	# see specific animations in the player's animation player to see attacking logic
	# on 4th frame attack_animation_finished() is called to reset the player back to MOVE state
	# beginning of every attack animation frame the hitbox pivot rotation is 'keyed in' to move the sword hitbox 
	#to the correct side. 2nd frame the attack hitbox is enabled, and last frame it is disabled
	# all states that are related to animations will be similar to this described functioning so I wont be commenting 
	# essentially just open a specific animation and scroll down through the 'tracks' and look for 'keyed' in functions
	# and property toggling
	
func roll_state(delta):
	animation_state.travel('Roll')
	velocity = roll_vector * ROLL_SPEED
	move_and_slide()

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("left", "right")
	input_vector.y = Input.get_axis("up", "down")
	input_vector = input_vector.normalized()
	if (input_vector):
		roll_vector = input_vector
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		# 4 animations for each direction are set in a 'blend position' in the animation tree so that when the state machine
		# tells it to play an animation for run or idle or roll etc... it plays the correct directional animation by 
		# setting the 'blend position' based on input vector
		animation_state.travel('Run')
		velocity = velocity.move_toward(input_vector * SPEED, ACCELERATION * delta)
	else:
		animation_state.travel('Idle')
		velocity = Vector2.ZERO             
	move_and_slide()
	
	if ( Input.is_action_just_pressed("roll") ):
		state = ROLL
	
	if(Input.is_action_just_pressed("attack")):
		state = ATTACK

func roll_animation_finished():
	state = MOVE
# these functions are called by the animations
func attack_animation_finished(): 
	velocity = Vector2.ZERO
	state = MOVE


func _on_hurt_box_area_entered(area: Area2D) -> void:
	stats.health -= 1
	hurtbox.start_invincibility(1)
	hurtbox.create_hit_effect()


func _on_hurt_box_invincibility_started() -> void:
	blinkAnimationPlayer.play('Start')


func _on_hurt_box_invincibility_ended() -> void:
	print('player invin ended')
	blinkAnimationPlayer.play('Stop')
