extends Resource
class_name Passive

@export_enum("on_enemy_damaged", "on_kill", "on_ability_started", "on_melee_hit")
var trigger: String

@export var effect: Spell 
