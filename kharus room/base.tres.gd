extends Node2D

var base_positions: Dictionary
var resource_rate: int = 10
var minion_rate: int = 10
var minions_per_wave: int = 4
const BAT = preload("res://scenes/Bat.tscn")
@onready var stats = $StatsComponent
@onready var hurtbox = $HurtBox
@export var SpawnOver: bool = false
@onready var bat_spawn_location = $SpawnLocation.position
@export var MainBase: bool
@export var LeftBase:bool
@export var RightBase:bool
const EnemyDeathEffect = preload("res://assets/Action RPG Resources/Effects/EnemyDeathEffect.tscn")

func _ready():
	hurtbox.damaged.connect(take_damage)
	# awkward scenario where to be detected and chase player and bat set their own personal collision to be detectable
	$SpawnTimer.start(minion_rate)
	if (MainBase):
		bat_spawn_location = Vector2(position.x, position.y + 50)
		hurtbox.set_collision_layer_value(2, true) # 2 and 5 are for chase detection all else is hurt/hit
		hurtbox.set_collision_layer_value(3, true)
	if (LeftBase):
		bat_spawn_location = Vector2(position.x + 50, position.y)
		hurtbox.set_collision_layer_value(4, true) 
		hurtbox.set_collision_layer_value(5, true)
	if (RightBase):
		bat_spawn_location = Vector2(position.x - 50, position.y)
		hurtbox.set_collision_layer_value(4, true) 
		hurtbox.set_collision_layer_value(5, true)
		
func initialize(base_positionss: Dictionary):
	base_positions = base_positionss # this is not a a typo

func spawn_minion(player_side:bool):
	var i = 0
	while(i < minions_per_wave):
		i += 1
		var bat_spawn = BAT.instantiate()
		bat_spawn.initialize(player_side, base_positions)
		get_parent().add_child(bat_spawn)
		bat_spawn.position = bat_spawn_location

func take_damage(attack: Attack) -> void:
	print(attack.damage)
	stats.health -= attack.damage
	print(stats.health)
	hurtbox.start_invincibility(0.2)
	hurtbox.create_hit_effect()

func _on_spawn_timer_timeout() -> void:
	spawn_minion(MainBase)
	$SpawnTimer.start(minion_rate)

func _on_stats_no_health() -> void:
	await get_tree().create_timer(0.3).timeout
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instantiate()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.position = position
