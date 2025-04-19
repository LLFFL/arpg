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
var enemy_base_position: Vector2
#Targetting System
var targets: Array = []
@onready var targeting: Area2D = $Targeting


func _ready():
	randomize()
	sprite.frame = randf_range(0, 4)

enum {
	CHASE,
	DEFAULT
}
var state = CHASE

func _physics_process(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	

	match state:
		CHASE: 
			var enemy = $PlayerDetectionZone.enemy
			if enemy != null:
				accelerate_toward_point(enemy.global_position)
			else:
				state = DEFAULT
		DEFAULT:
			seek_enemy()
			accelerate_toward_point(enemy_base_position)
			
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 700
	move_and_slide()

func seek_enemy():
	if $PlayerDetectionZone.can_see_enemy():
		state = CHASE
		

func accelerate_toward_point(point):
	var direction = position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION)
	sprite.flip_h = velocity.x < 0

func _on_hurt_box_area_entered(area: Area2D) -> void:
	hurtbox.start_invincibility(0.4)
	hurtbox.create_hit_effect()
	var direction = (position - area.owner.position).normalized()
	stats.health -= area.damage
	knockback = direction * 240
	velocity = knockback      
		# this knocks back the bat on damage
		 # can ask area.owner for the knockback value or a global state script if you want it to be dynamic

func initialize(side: bool, enemy_base_coords: Vector2):
	if side:
		#player side
		enemy_base_position = enemy_base_coords
		$HurtBox.set_collision_mask_value(3, true)
		$HitBox.set_collision_layer_value(4, true)
		$PlayerDetectionZone.set_collision_mask_value(5, true)
		set_collision_layer_value(2, true)
	else:
		#enemy
		enemy_base_position = enemy_base_coords
		$HurtBox.set_collision_mask_value(4, true)
		$HitBox.set_collision_layer_value(3, true)
		$PlayerDetectionZone.set_collision_mask_value(2, true)
		set_collision_layer_value(5, true)
		
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
