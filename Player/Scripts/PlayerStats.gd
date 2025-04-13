extends Node
@export var max_health = 1: set = set_max_health
@export var base_damage: float = 1.0:
	set(value):
		base_damage = value
		#value = 
	get:
		return base_damage
@export var damage: float = base_damage: 
	set(value):
		damage = base_damage + value
	get:
		return damage
@export var ranged_damage: float = base_damage: 
	set(value):
		ranged_damage = base_damage + value
	get:
		return damage

@export var magic_damage: float = 0:
	set(value):
		magic_damage += value
	get:
		return magic_damage

@export var defence: float = 1.0:
	set(value):
		defence += value
	get:
		return defence
@export var base_movement_speed: float = 100:
	set(value):
		base_movement_speed += value
	get:
		return base_movement_speed
@export var movement_speed_modifier: float = 1:
	set(value):
		movement_speed_modifier += value
	get:
		return movement_speed_modifier
@export var movement_speed: float:
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
@export var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")

var upgrades : Array = []
#setter function
func add_upgrade(spell):
	#if upgrades.size() < 4:
		upgrades.append(spell)

	

#Spell Dictionairy
#Cast time, Base Damage, Projectile speed, ext

#Power Up dictionairy
#Arrow shotgun

#Melee Overview
