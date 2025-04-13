class_name Projectile
extends CharacterBody2D

@export var hurtbox : Projectile_HurtBox


@export var speed := 150.0
@export var damage := 5.0
@export var max_pierce := 1
@onready var icon: Sprite2D = $Icon
@export var spell: Spell
var current_pierce_count := 0

func _ready():
	if hurtbox:
		hurtbox.projectile_hit_enemy.connect(on_enemy_hit)
	if spell:
		icon.texture = spell.icon_texture
		icon.scale = spell.icon_scale
	#Check stats of character for modifiers
func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	
	velocity = direction*speed
	
	var collision := move_and_collide(velocity*delta)
	
	if collision:
		queue_free()

func on_enemy_hit():
	current_pierce_count += 1
	
	if current_pierce_count >= max_pierce:
		queue_free()
