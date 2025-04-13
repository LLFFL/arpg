extends Node
var max_health = 1: set = set_max_health
var base_damage: float = 1.0:
	set(value):
		base_damage = value
		#value = 
	get:
		return base_damage
var damage: float = base_damage: 
	set(value):
		damage = base_damage + value
	get:
		return damage
var ranged_damage: float = base_damage: 
	set(value):
		ranged_damage = base_damage + value
	get:
		return damage

var magic_damage: float = 0:
	set(value):
		magic_damage += value
	get:
		return magic_damage

var defence: float = 1.0:
	set(value):
		defence += value
	get:
		return defence
var base_movement_speed: float = 100:
	set(value):
		base_movement_speed += value
	get:
		return base_movement_speed
var movement_speed_modifier: float = 1:
	set(value):
		movement_speed_modifier += value
	get:
		return movement_speed_modifier
var movement_speed: float:
	get:
		return base_movement_speed*movement_speed_modifier
		
@onready var health = max_health: set = set_health

signal no_health
signal health_changed(value)
signal max_health_changed(value)

var in_transition: bool = false

func set_max_health(value):
	max_health = value
	health = min((1 if health == null else health), max_health)
	emit_signal('max_health_changed', max_health)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

#Upgrade spells
var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")

var upgrades : Array = []
#setter function
func add_upgrade(upgrade):
	#if upgrades.size() < 4:
		upgrades.append(upgrade)

	

#Spell Dictionairy
#Cast time, Base Damage, Projectile speed, ext

#Power Up dictionairy
#Arrow shotgun

#Melee Overview
var melee_unlocks: Dictionary = {
	#those unlocks are for next attacks in combo chain
	"attack_2": false,
	"attack_3": false,
}
