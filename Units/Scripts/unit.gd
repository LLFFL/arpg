class_name Unit extends CharacterBody2D

var target_location: Vector2
var direction: Vector2 = Vector2.ZERO
@onready var state_machine: UnitStateMachine = $StateMachine
@onready var stats: UnitStats = $Stats
@onready var enemy_detection_zone: Area2D = $EnemyDetectionZone
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var hurt_box: HurtBox = $HurtBox
@onready var blink: AnimationPlayer = $Blink
@onready var hitbox: Hitbox = $Sprite2D/Hitbox
@onready var soft_collision: Area2D = $SoftCollision
@onready var animation_player: AnimationPlayer = $AnimationPlayer
#add laters to the ready
@onready var gold_detection_zone: Area2D = $GoldDetectionZone
const MONEY = preload("res://christophe/Shop/money.tscn")
#var stats: UnitStats = null
var ally: bool = false
var enemy: bool = false
var targets: Array[CharacterBody2D] = []

var temp_target: CharacterBody2D = null
var struct_target: Area2D = null

func _ready() -> void:
	if ally:
		sprite_2d.texture = load("res://assets/ally_unit.png")
		hurt_box.set_collision_layer_value(3, true)
		hitbox.set_collision_mask_value(4, true)
		enemy_detection_zone.set_collision_mask_value(5, true)
		set_collision_layer_value(2, true)
		set_collision_mask_value(5, true)
		set_collision_mask_value(19, true)
	else:
		if enemy:
			sprite_2d.texture = load("res://assets/enemy_1.png")
		else:
			sprite_2d.texture = load("res://assets/enemy_fire.png")
		gold_detection_zone.set_collision_mask_value(2, true)
		hurt_box.set_collision_layer_value(4, true)
		hitbox.set_collision_mask_value(3, true)
		enemy_detection_zone.set_collision_mask_value(2, true)
		set_collision_layer_value(5, true)
		set_collision_mask_value(2, true)
	state_machine.initialize(self)
	stats.no_health.connect(_on_no_health)
	hurt_box.damaged.connect(damage)
	hitbox.hit_attack = Attack.new()
	pass # Replace with function body.

func _initialize(Ally: bool, base_position: Vector2, _stats: BaseStats):
	var tween = create_tween()
	self.scale = Vector2(0,0)
	tween.tween_property(self,"scale",Vector2(1,1),0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	target_location = base_position
	stats.set_stats(_stats)

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
	
	hitbox.hit_attack.damage = stats.damage
	#if struct_target:
		#label.text = str(struct_target)
	#label.text = str(stats.damage)
	#if temp_target:
		#label.text = str(temp_target.name)
	#label.text = str(targets)
	#label.text = "hurtbox layer: " + str(hurt_box.collision_layer) + "\n" + "hitbox mask" + str(hitbox.collision_mask)

func update_anim(action: String):
	animation_player.play(action)

func _physics_process(delta: float) -> void:
	move_and_slide()

func damage2(arg: Projectile2D) -> void:
	var dmg = arg.resource.damage - stats.defence
	stats.health -= dmg if dmg > 0 else 0
	hurt_box.start_invincibility(0.4)
	hurt_box.create_hit_effect()
	var _direction = (global_position - get_global_mouse_position()).normalized()
	#velocity = dmg.attack_direction * 240

func damage(attack: Attack) -> void:
	var dmg = attack.damage - stats.defence
	stats.health -= dmg if dmg > 0 else 0
	hurt_box.start_invincibility(0.4)
	hurt_box.create_hit_effect()
	var _direction = (global_position - get_global_mouse_position()).normalized()
	velocity = attack.attack_direction * 240
	$AudioStreamPlayer2D.play()
	var t = create_tween()
	t.tween_property(self,"scale:y",randf_range(1.1,1.6),0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(self,"scale:y",1,0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await t.finished
	t.kill()
	self.scale.y = 1
	
	
		
func _on_no_health():
	for body in gold_detection_zone.get_overlapping_bodies():
		if body.is_in_group("player"):
			#instanciate MONEY
			var coin = MONEY.instantiate()
			get_parent().get_parent().add_child(coin)
			coin.global_position = global_position
			body.stats.add_gold(1)
			print("gold given")
	kill_unit()

func kill_unit():
	queue_free()

func _on_hurt_box_invincibility_ended() -> void:
	blink.play("stop")
	pass # Replace with function body.


func _on_hurt_box_invincibility_started() -> void:
	blink.play("start")
	pass # Replace with function body.

func update_target_base(_loc: Vector2):
	target_location = _loc
