class_name Hitbox
extends Area2D
#This gets hit by hurtbox.
#Should be used by enemies by default.
@onready var bat: Node = $".."

@export var damage: int = 1

signal damaged(attack: Attack)


func projectile_damage(attack: Attack):
	#damaged.emit(attack)
	bat.damage(attack)
