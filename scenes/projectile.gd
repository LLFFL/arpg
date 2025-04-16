class_name Projectile
extends RigidBody2D

@onready var hit_box: Hitbox = $HitBox
@onready var trail_particles: GPUParticles2D = $TrailParticles


@export var speed := 150.0
@export var damage := 5.0
@export var max_pierce := 1
@onready var icon: Sprite2D = $Icon
@export var spell: Spell

var direction: Vector2
var angle: float = 0
var current_pierce_count := 0

func _ready():
	connect("body_entered", _on_body_entered)
	if hit_box:
		hit_box.damaged_enemy.connect(on_enemy_hit)
	if spell:
		#print("Projectile is a spell")
		icon.texture = spell.icon_texture
		icon.scale = spell.icon_scale
		spell.setup_particles(self)
	direction = Vector2.RIGHT.rotated(angle)
	icon.scale.x = -1 if direction.x < 0 else 1
	hit_box.hit_attack = Attack.new()
	hit_box.hit_attack.damage = damage
	#Check stats of character for modifiers

func _physics_process(delta: float) -> void:
	direction = Vector2.RIGHT.rotated(angle)
	
	
	linear_velocity = direction*speed
	
	apply_force(linear_velocity*delta)

func on_enemy_hit(_attack: Attack, hit_target: Node):
	print("Enemy hit with Projectile")
	if spell:
		print("Spell type:", spell.get_class())
		spell.apply_effects(self, hit_target)
		spell.apply_particle_effects(self, hit_target)
	current_pierce_count += 1
	if current_pierce_count >= max_pierce:
		queue_free()


func _on_body_entered(body: Node) -> void:
	queue_free()
