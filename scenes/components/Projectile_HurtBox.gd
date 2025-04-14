class_name Projectile_HurtBox
extends Area2D

signal projectile_hit_enemy(hit_target: Node)

@onready var projectile : Projectile = get_owner()

func _ready() -> void:
	self.add_to_group("projectiles")
	area_entered.connect(on_area_entered)
	
	
func on_area_entered(area: Area2D):
	print(area)
	if area.has_method("projectile_damage"):
		var attack := Attack.new()
		attack.damage = projectile.damage
		area.projectile_damage(attack)
		print("area.damage(attack) called for ", attack)
		projectile_hit_enemy.emit(area)
	#if area is Hitbox:
		#var attack := Attack.new()
		#attack.damage = projectile.damage
		#area.damage(attack)
		#projectile_hit_enemy.emit()
