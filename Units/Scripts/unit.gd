class_name Unit extends CharacterBody2D

var target_location: Vector2
var direction: Vector2 = Vector2.ZERO
@onready var state_machine: UnitStateMachine = $StateMachine
@onready var stats: Stats = $Stats
@onready var enemy_detection_zone: Area2D = $EnemyDetectionZone
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var hurt_box: HurtBox = $HurtBox
@onready var blink: AnimationPlayer = $Blink
@onready var hitbox: Hitbox = $Sprite2D/Hitbox
@onready var soft_collision: Area2D = $SoftCollision
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var ally: bool = false
var targets: Array[CharacterBody2D] = []

var temp_target: CharacterBody2D = null

func _ready() -> void:
	if ally:
		hurt_box.set_collision_layer_value(3, true)
		hitbox.set_collision_mask_value(4, true)
		enemy_detection_zone.set_collision_mask_value(5, true)
		set_collision_layer_value(2, true)
		set_collision_mask_value(5, true)
	else:
		hurt_box.set_collision_layer_value(4, true)
		hitbox.set_collision_mask_value(3, true)
		enemy_detection_zone.set_collision_mask_value(2, true)
		set_collision_layer_value(5, true)
		set_collision_mask_value(2, true)
	state_machine.initialize(self)
	stats.no_health.connect(_on_no_health)
	hurt_box.damaged.connect(damage)
	pass # Replace with function body.

func _initialize(Ally: bool, base_position: Vector2):
	var tween = create_tween()
	self.scale = Vector2(0,0)
	tween.tween_property(self,"scale",Vector2(1,1),0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	target_location = base_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if targets.size() > 0:
		temp_target = targets[0]
	else:
		temp_target = null
	var _target = target_location if temp_target == null else temp_target.global_position
	if global_position.direction_to(_target).x > 0:
		sprite_2d.scale.x = 1
	else:
		sprite_2d.scale.x = -1
	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector() * delta * stats.movement_speed
	#if temp_target:
		#label.text = str(temp_target.name)
	#label.text = str(targets)
	#label.text = "hurtbox layer: " + str(hurt_box.collision_layer) + "\n" + "hitbox mask" + str(hitbox.collision_mask)

func update_anim(action: String):
	animation_player.play(action)

func _physics_process(delta: float) -> void:
	move_and_slide()

func damage2(arg: Projectile2D) -> void:
	var dmg = arg.resource.damage
	stats.health -= dmg
	hurt_box.start_invincibility(0.4)
	hurt_box.create_hit_effect()
	var _direction = (global_position - get_global_mouse_position()).normalized()
	#velocity = dmg.attack_direction * 240

func damage(attack: Attack) -> void:
	stats.health -= attack.damage
	hurt_box.start_invincibility(0.4)
	hurt_box.create_hit_effect()
	var _direction = (global_position - get_global_mouse_position()).normalized()
	velocity = attack.attack_direction * 240
	var t = create_tween()
	t.tween_property(self,"scale:y",randf_range(1.1,2.5),0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(self,"scale:y",1,0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await t.finished
	t.kill()
	self.scale.y = 1
	
	
		
func _on_no_health():
	queue_free()


func _on_hurt_box_invincibility_ended() -> void:
	blink.play("stop")
	pass # Replace with function body.


func _on_hurt_box_invincibility_started() -> void:
	blink.play("start")
	pass # Replace with function body.
