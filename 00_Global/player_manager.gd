extends Node

var player : Player
var game_won: bool = false
var game_times: Array[float] = []
var current_time: float = 0

func _ready() -> void:
	tree_exited.connect(_end_game)
	_load_game()

func _end_game():
	if game_times.size() <= 0:
		return
	var save_file = FileAccess.open("user://savegametime.save", FileAccess.WRITE)
	var json_string = JSON.stringify(game_times)
	
	save_file.store_line(json_string)
	pass

func _load_game():
	if not FileAccess.file_exists("user://savegametime.save"):
		return
	var save_file = FileAccess.open("user://savegametime.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string)
			continue
		for item in json.data:
			game_times.append(item)
		game_times.sort()

var level_upgrades: Array[Dictionary] =[
	{
		"level": 1,
		"unit_health": 30,
		"base_damage": 2.5,
		"base_defence": 3,
		"base_movement_speed": 62.0,
		"spawn_rate": 10,
		"units_spawned": 4
	},
	{
		"level": 2,
		"unit_health": 30,
		"base_damage": 2.75,
		"base_defence": 3.5,
		"base_movement_speed": 64.5,
		"spawn_rate": 9,
		"units_spawned": 4
	},
	{
		"level": 3,
		"unit_health": 35,
		"base_damage": 3.0,
		"base_defence": 4,
		"base_movement_speed": 67.0,
		"spawn_rate": 9,
		"units_spawned": 4
	},
	{
		"level": 4,
		"unit_health": 40,
		"base_damage": 3.25,
		"base_defence": 4.5,
		"base_movement_speed": 69.0,
		"spawn_rate": 9,
		"units_spawned": 4
	},
	{
		"level": 5,
		"unit_health": 45,
		"base_damage": 3.5,
		"base_defence": 5,
		"base_movement_speed": 72.0,
		"spawn_rate": 9,
		"units_spawned": 5
	},
	{
		"level": 6,
		"unit_health": 50,
		"base_damage": 3.75,
		"base_defence": 6,
		"base_movement_speed": 74.5,
		"spawn_rate": 8,
		"units_spawned": 5
	},
	{
		"level": 7,
		"unit_health": 55,
		"base_damage": 4.0,
		"base_defence": 6.5,
		"base_movement_speed": 74.5,
		"spawn_rate": 8,
		"units_spawned": 5
	},
	{
		"level": 8,
		"unit_health": 60,
		"base_damage": 4.25,
		"base_defence": 7,
		"base_movement_speed": 77.0,
		"spawn_rate": 8,
		"units_spawned": 5
	},
	{
		"level": 9,
		"unit_health": 65,
		"base_damage": 4.5,
		"base_defence": 8,
		"base_movement_speed": 77.0,
		"spawn_rate": 8,
		"units_spawned": 6
	},
	{
		"level": 10,
		"unit_health": 70,
		"base_damage": 4.75,
		"base_defence": 9,
		"base_movement_speed": 79.5,
		"spawn_rate": 7,
		"units_spawned": 6
	},
	{
		"level": 11,
		"unit_health": 75,
		"base_damage": 5.0,
		"base_defence": 9.5,
		"base_movement_speed": 79.5,
		"spawn_rate": 7,
		"units_spawned": 6
	},
	{
		"level": 12,
		"unit_health": 80,
		"base_damage": 5.25,
		"base_defence": 10.5,
		"base_movement_speed": 82.0,
		"spawn_rate": 7,
		"units_spawned": 6
	},
	{
		"level": 13,
		"unit_health": 85,
		"base_damage": 5.5,
		"base_defence": 11,
		"base_movement_speed": 82.0,
		"spawn_rate": 7,
		"units_spawned": 7
	},
	{
		"level": 14,
		"unit_health": 90,
		"base_damage": 5.75,
		"base_defence": 11.5,
		"base_movement_speed": 84.5,
		"spawn_rate": 6,
		"units_spawned": 7
	},
	{
		"level": 15,
		"unit_health": 95,
		"base_damage": 6.0,
		"base_defence": 12,
		"base_movement_speed": 87.0,
		"spawn_rate": 6,
		"units_spawned": 7
	},
	{
		"level": 16,
		"unit_health": 100,
		"base_damage": 6.5,
		"base_defence": 12.5,
		"base_movement_speed": 89.5,
		"spawn_rate": 6,
		"units_spawned": 7
	},
	{
		"level": 17,
		"unit_health": 105,
		"base_damage": 7.0,
		"base_defence": 13,
		"base_movement_speed": 94.5,
		"spawn_rate": 6,
		"units_spawned": 8
	},
	{
		"level": 18,
		"unit_health": 110,
		"base_damage": 7.5,
		"base_defence": 13.5,
		"base_movement_speed": 97.0,
		"spawn_rate": 5,
		"units_spawned": 8
	},
	{
		"level": 19,
		"unit_health": 115,
		"base_damage": 8.0,
		"base_defence": 14,
		"base_movement_speed": 99.5,
		"spawn_rate": 4,
		"units_spawned": 8
	},
	{
		"level": 20,
		"unit_health": 120,
		"base_damage": 8.75,
		"base_defence": 15,
		"base_movement_speed": 117.0,
		"spawn_rate": 4,
		"units_spawned": 8
	}
]
