class_name BaseStats extends Stats

signal level_up
signal units_updated

func _ready() -> void:
	level_up.connect(_on_level_up)

var level: int = 1
@export var spawn_rate: float = 6
#@export var unit_per_pack: int = 1
@export var units_spawned: int = 1

func _on_level_up():
	level += 1
	spawn_rate -= 5
	if spawn_rate < 0:
		spawn_rate = 0.5
	units_spawned += 1
	units_updated.emit()
	#print(level)
