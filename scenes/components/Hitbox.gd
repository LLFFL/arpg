class_name Hitbox
extends Area2D
#This gets hit by hurtbox.
#Should be used by enemies by default.

@export var damage: int = 1

signal damaged(attack: Attack)


func projectile_damage(attack: Attack):
	damaged.emit(attack)



func _on_area_entered(area: Area2D) -> void:
	if area.has_method("damage"):
		var attack := Attack.new()
		#attack.damage = projectile.damage
		area.damage(attack)
		print("area.damage(attack) called for ", attack)
		#projectile_hit_enemy.emit()
