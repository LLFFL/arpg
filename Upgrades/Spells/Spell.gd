extends Pickup
class_name Spell

@export var icon_texture: Texture2D
@export var icon_scale: Vector2 = Vector2(1, 1)

@export var animation_frames: SpriteFrames  
@export var animation_name: String = "default"

@export var damage: float = 5.0
@export var speed: float = 150.0
@export var max_pierce: int = 1

func apply_effects(projectile: Node, hit_target: Node) -> void:
	if hit_target.has_method("damage"):
		var attack := Attack.new()
		attack.damage = damage
		hit_target.damage(attack)
