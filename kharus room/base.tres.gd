extends Node2D

var enemy_base_position: Vector2
var resource_rate: int = 10
var minion_rate: int = 2
var player_side: bool = false
@export var SpawnOver: bool = false
const BAT = preload("res://scenes/Bat.tscn")
@export var MainBase: bool
@export var LeftBase:bool
@export var RightBase:bool
#TODO how to make base damage with stats and hurtboxes etc

func _ready():
	$SpawnTimer.start(minion_rate)
	if (MainBase):
		$SpawnLocation.position = Vector2(0, 100)
	if (LeftBase):
		$SpawnLocation.position = Vector2(0, 100)
	if (RightBase):
		$SpawnLocation.position = Vector2(0, -100)

func initialize(coords, side):
	enemy_base_position = coords
	if (side):
		player_side = true

func spawn_minion(player_side:bool):
	var bat_spawn = BAT.instantiate()
	bat_spawn.initialize(player_side, enemy_base_position)
	get_parent().add_child(bat_spawn)
	if(not SpawnOver):
		bat_spawn.position = position
	else:
		bat_spawn.position = Vector2(position.x, position.y - 50)
	
	

func _on_spawn_timer_timeout() -> void:
	spawn_minion(player_side)
	$SpawnTimer.start(minion_rate)
