class_name Hitbox
extends Area2D
#This gets hit by hurtbox.
#Should be used by enemies by default.
@onready var bat: Node = $".."

var hit_attack: Attack

signal damaged_enemy(attack: Attack, body: Area2D)

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("damage"):
		if !hit_attack:
			hit_attack = Attack.new()
		damaged_enemy.emit(hit_attack, area)
		area.damage(hit_attack)
		print("area.damage(attack) called for ", hit_attack)
