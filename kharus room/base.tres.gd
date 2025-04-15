extends Node2D

var base_positions: Dictionary
var resource_rate: int = 10
var minion_rate: int = 10
var enemy_minions_per_wave: int = 4
var minion_side_selection: Array # this array will serve as number of minions to spawn per wave
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
		minion_side_selection = [2,2] # keeping this away from the other bases since its not necessary to them
		bat_spawn_location = Vector2(position.x, position.y - 50)
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
	if(LeftBase or RightBase):
		var i = 0
		while(i < enemy_minions_per_wave):
			i += 1
			var bat_spawn = BAT.instantiate()
			bat_spawn.initialize(player_side, base_positions['ally_base_position'])
			get_parent().add_child(bat_spawn)
			bat_spawn.position = bat_spawn_location
	else:
		var i = 0
		while(i < minion_side_selection[1]): # second index sends to the right
			bat_spawn_location = Vector2(position.x - 50, position.y)
			i += 1
			var bat_spawn = BAT.instantiate()
			bat_spawn.add_to_group("allied_minions")
			bat_spawn.initialize(player_side, base_positions['enemy_base_position_L'])
			get_parent().add_child(bat_spawn)
			bat_spawn.position = bat_spawn_location
		i = 0
		while(i < minion_side_selection[0]): # first index sends to the left
			bat_spawn_location = Vector2(position.x + 50, position.y)
			i += 1
			var bat_spawn = BAT.instantiate()
			bat_spawn.add_to_group("allied_minions")
			bat_spawn.initialize(player_side, base_positions['enemy_base_position_R'])
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
	var enemyDeathEffect = EnemyDeathEffect.instantiate()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.position = position
	if (LeftBase):
		get_tree().call_group('allied_minions', 'update_target_base', base_positions['enemy_base_position_R'])
	else:
		get_tree().call_group('allied_minions', 'update_target_base', base_positions['enemy_base_position_L'])
	queue_free()


func change_minion_wave_side_selection(increase_left: bool, increase_right: bool):
	if (increase_left):
		if minion_side_selection[1] == 0:
			return minion_side_selection
		else:
			minion_side_selection[1] -= 1
			minion_side_selection[0] += 1
			return minion_side_selection
	else:
		if minion_side_selection[0] == 0:
			return minion_side_selection
		else:
			minion_side_selection[0] -= 1
			minion_side_selection[1] += 1
			return minion_side_selection
	
func increase_allied_minions():
	minion_side_selection[0] += 1
