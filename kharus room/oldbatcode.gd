extends CharacterBody2D
var knockback = Vector2.ZERO
const EnemyDeathEffect = preload('res://assets/Action RPG Resources/Effects/EnemyDeathEffect.tscn')
@onready var stats = $Stats
@export var ACCELERATION = 7
@export var MAX_SPEED = 70
@export var FRICTION = 3
@onready var sprite = $AnimatedSprite2D
@onready var hurtbox = $HurtBox
@onready var softCollision = $SoftCollision
@onready var wanderController = $WanderController
@onready var MAGIC_ARBITRARY_NUMBER = 10
@onready var animationPlayer = $AnimationPlayer

func _ready():
	randomize()
	state = pick_random_state([IDLE, WANDER])
	sprite.frame = randf_range(0, 4)

enum {
	IDLE,
	WANDER,
	CHASE
}
var state = CHASE

func _physics_process(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	
	"""the bat uses a randomized timer to switch between idling and wandering while always 'seeking' the player in a zone.
	its initial state and starting animation frame is randomized so that they arent all doing the exact same thing on spawn
	"""
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
			accelerate_toward_point(wanderController.target_position)

			sprite.flip_h = velocity.x < 0
			if global_position.distance_to(wanderController.target_position) <= MAGIC_ARBITRARY_NUMBER:
				update_wander()
				#the magic number thing is to give the wander state a margin so that its not jittering back and forth
				# because its hard to make the bat stop at an exact number when accelerating/deccelerating to a point
		CHASE: 
			var player = $PlayerDetectionZone.player
			if player != null:
				accelerate_toward_point(player.global_position)
				
			else:
				state = IDLE
				
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 700
	move_and_slide()

func seek_player():
	if $PlayerDetectionZone.can_see_player():
		state = CHASE
		
func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(randf_range(1, 3))

func accelerate_toward_point(point):
	var direction = position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION)
	sprite.flip_h = velocity.x < 0

func pick_random_state(state_list:Array):
	state_list.shuffle()
	return state_list.pop_front()

func _on_hurt_box_area_entered(area: Area2D) -> void:
	hurtbox.start_invincibility(0.4)
	hurtbox.create_hit_effect()
	var direction = (position - area.owner.position).normalized()
	stats.health -= area.damage
	knockback = direction * 240
	velocity = knockback      
		# this knocks back the bat on damage
		 # can ask area.owner for the knockback value or a global state script if you want it to be dynamic

func initialize(side: bool):
	if side:
		#player side
		$HurtBox.set_collision_mask_value(3, true)
		$HitBox.set_collision_layer_value(4, true)
		$PlayerDetectionZone.set_collision_mask_value(5, true)
		set_collision_layer_value(2, true)
		print($HitBox.get_collision_layer_value(3))
		print($HurtBox.get_collision_mask_value(4))
		print($HurtBox.get_collision_mask_value(3))
	else:
		#enemy
		$HurtBox.set_collision_mask_value(4, true)
		$HitBox.set_collision_layer_value(3, true)
		$PlayerDetectionZone.set_collision_mask_value(2, true)
		set_collision_layer_value(5, true)
		print($HurtBox.get_collision_mask_value(3))
func _on_stats_no_health() -> void:
	await get_tree().create_timer(0.3).timeout
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instantiate()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.position = position


func _on_hurt_box_invincibility_started() -> void:
	animationPlayer.play('Start')


func _on_hurt_box_invincibility_ended() -> void:
	
	animationPlayer.play('Stop')
