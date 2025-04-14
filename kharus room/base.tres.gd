extends Node2D

var base_positions: Dictionary
var resource_rate: int = 10
var minion_rate: int = 2
const BAT = preload("res://scenes/Bat.tscn")
@onready var hurtbox = $HurtBox
@export var SpawnOver: bool = false
@onready var bat_spawn_location = $SpawnLocation.position
@export var MainBase: bool
@export var LeftBase:bool
@export var RightBase:bool
#TODO how to make base damage with stats and hurtboxes etc

func _ready():
	hurtbox.set_collision_layer_value(3, true)
	hurtbox.set_collision_layer_value(2, true) 
	# awkward scenario where to be detected and chase player and bat set their own personal collision to be detectable
	$SpawnTimer.start(minion_rate)
	if (MainBase):
		bat_spawn_location = Vector2(position.x, position.y + 50)
	if (LeftBase):
		bat_spawn_location = Vector2(position.x + 50, position.y)
	if (RightBase):
		bat_spawn_location = Vector2(position.x - 50, position.y)

func initialize(base_positionss: Dictionary):
	base_positions = base_positionss # this is not a a typo

func spawn_minion(player_side:bool):
	var bat_spawn = BAT.instantiate()
	bat_spawn.initialize(player_side, base_positions)
	get_parent().add_child(bat_spawn)
	bat_spawn.position = bat_spawn_location


func _on_spawn_timer_timeout() -> void:
	spawn_minion(MainBase)
	$SpawnTimer.start(minion_rate)
