class_name Projectile_HurtBox
extends Area2D

signal projectile_hit_enemy

@onready var projectile : Projectile = get_owner()

func _ready() -> void:
	self.add_to_group("projectiles")
	area_entered.connect(on_area_entered)
	
	
func on_area_entered(area: Area2D):
	if area.has_method("damage"):
		var attack := Attack.new()
		attack.damage = projectile.damage
		area.damage(attack)
		print("area.damage(attack) called for ", attack)
		projectile_hit_enemy.emit()
	#if area is Hitbox:
		#var attack := Attack.new()
		#attack.damage = projectile.damage
		#area.damage(attack)
		#projectile_hit_enemy.emit()
