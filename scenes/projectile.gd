class_name Projectile
extends RigidBody2D

@onready var hit_box: Hitbox = $HitBox
#@onready var trail_particles: GPUParticles2D = $TrailParticles


@export var speed := 150.0
@export var damage := 5.0
@export var max_pierce := 1
@onready var icon: Sprite2D = $Icon
@export var spell: Spell

## duration before the projectile starts to fade out
@export var fade_after = 1.0

## How long the projectile fade out
@export var fade_duration = 2.0


var direction: Vector2
var angle: float = 0
var current_pierce_count := 0

func _ready():
	# small tween to make projectile fade in real fast
	self.modulate.a = 0
	var t = create_tween()
	t.tween_property(self,"modulate:a", 1, 0.05).set_trans(Tween.TRANS_QUAD)
	
	connect("body_entered", _on_body_entered)
	if hit_box:
		hit_box.damaged_enemy.connect(on_enemy_hit)
	if spell:
		#print("Projectile is a spell")
		icon.texture = spell.icon_texture
		icon.scale = spell.icon_scale
		damage = spell.damage
		spell.setup_particles(self)
	direction = Vector2.RIGHT.rotated(angle)
	icon.scale.x = -1 if direction.x < 0 else 1
	hit_box.hit_attack = Attack.new()
	hit_box.hit_attack.damage = damage
	#Timer to dequeue
	
	await t.finished
	t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.tween_property(self,"modulate:a", 0, fade_duration).set_delay(fade_after)
	
	await t.finished
	if is_instance_valid(self):
		queue_free()
	
	#Check stats of character for modifiers
	
	##Test to not kys
	#var parent := get_parent()
	#print(parent, "is the node")
	#if parent:
	#	var hurtbox := parent.get_node_or_null("HurtBox")
	#	if hurtbox and hurtbox is Area2D:
	#		var ignore_layer: int = hurtbox.collision_layer
	#		collision_mask &= ~ignore_layer
#

func _physics_process(delta: float) -> void:
	#direction = Vector2.RIGHT.rotated(angle)
	
	
	linear_velocity = direction*speed
	
	apply_force(linear_velocity*delta)

func on_enemy_hit(_attack: Attack, hit_target: Node):
	if spell:
		spell.apply_effects(self, hit_target)
		spell.apply_particle_effects(self, hit_target)
	current_pierce_count += 1
	if current_pierce_count >= max_pierce:
		queue_free()


func _on_body_entered(body: Node) -> void:
	queue_free()
