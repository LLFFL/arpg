extends Node

var player : Player

var level_upgrades: Array[Dictionary] =[
	{
		"level": 1,
		"unit_health": 20,
		"base_damage": 10,
		"base_defence": 3,
		"base_movement_speed": 20,
		"spawn_rate": 10,
		"units_spawned": 1
	},
	{
		"level": 2,
		"unit_health": 30,
		"base_damage": 12,
		"base_defence": 6,
		"base_movement_speed": 30,
		"spawn_rate": 9,
		"units_spawned": 1
	},
	{
		"level": 3,
		"unit_health": 30,
		"base_damage": 12,
		"base_defence": 6,
		"base_movement_speed": 30,
		"spawn_rate": 9,
		"units_spawned": 1
	}
]

func _ready() -> void:
	print(level_upgrades[0].level)
