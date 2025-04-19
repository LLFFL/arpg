class_name BaseStats extends Stats

signal level_up
signal units_updated

func _ready() -> void:
	level_up.connect(_on_level_up)

var level: int = 1
var spawn_rate: float =  PlayerManager.level_upgrades[0].spawn_rate
var units_spawned: int = PlayerManager.level_upgrades[0].units_spawned
var unit_health: float = PlayerManager.level_upgrades[0].unit_health

var unit_damage: float = PlayerManager.level_upgrades[0].base_damage
var unit_defence: float = PlayerManager.level_upgrades[0].base_defence
var unit_movement_speed: float = PlayerManager.level_upgrades[0].base_movement_speed

func get_damage():
	return base_damage * damage_modifier * level

func _on_level_up():
	level += 1
	var index = level -1
	unit_damage = PlayerManager.level_upgrades[index].base_damage
	unit_defence = PlayerManager.level_upgrades[index].base_defence
	unit_movement_speed = PlayerManager.level_upgrades[index].base_movement_speed
	spawn_rate = PlayerManager.level_upgrades[index].spawn_rate
	units_spawned = PlayerManager.level_upgrades[index].units_spawned
	unit_health = PlayerManager.level_upgrades[index].unit_health 
	units_updated.emit()
