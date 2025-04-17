extends Node2D

var bases_dictionary: Dictionary
var resource_rate: int = 10
var minion_rate: int = 5
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
@onready var minion_side_control = %MinionSideControl
const EnemyDeathEffect = preload("res://assets/Action RPG Resources/Effects/EnemyDeathEffect.tscn")

func _ready():
	hurtbox.damaged.connect(take_damage)
	# awkward scenario where to be detected and chase player and bat set their own personal collision to be detectable
	
	$SpawnTimer.start(minion_rate)
	if (MainBase):
		minion_side_selection = [10,2] # keeping this away from the other bases since its not necessary to them
		minion_side_control.update(minion_side_selection)
		bat_spawn_location = Vector2(position.x, position.y - 50)
		hurtbox.set_collision_layer_value(2, true) # 2 and 5 are for chase detection all else is hurt/hit
		hurtbox.set_collision_layer_value(3, true)
		self.add_to_group('allied_base')
		minion_side_control.left_press.connect(change_minion_wave_side_selection)
		minion_side_control.right_press.connect(change_minion_wave_side_selection)
		
	if (LeftBase):
		bat_spawn_location = Vector2(position.x + 50, position.y)
		hurtbox.set_collision_layer_value(4, true) 
		hurtbox.set_collision_layer_value(5, true)
	if (RightBase):
		bat_spawn_location = Vector2(position.x - 50, position.y)
		hurtbox.set_collision_layer_value(4, true) 
		hurtbox.set_collision_layer_value(5, true)
		
func initialize(bases_dictionaryy: Dictionary):
	bases_dictionary = bases_dictionaryy # this is not a a typo

func spawn_minion(player_side:bool):
	if(LeftBase or RightBase):
		var i = 0
		while(i < enemy_minions_per_wave):
			i += 1
			var bat_spawn = BAT.instantiate()
			if (is_instance_valid(bases_dictionary['ally_base'])):
				bat_spawn.initialize(player_side, 
				(bases_dictionary['ally_base'].global_position)) 
			else: 
				bat_spawn.initialize(player_side, Vector2.ZERO)
			get_parent().add_child(bat_spawn)
			bat_spawn.position = bat_spawn_location
	else:
		var i = 0
		while(i < minion_side_selection[0]): # first index sends to the left
			bat_spawn_location = Vector2(position.x - 50, position.y)
			i += 1
			var bat_spawn = BAT.instantiate()
			bat_spawn.add_to_group("allied_minions")
			bat_spawn.initialize(player_side, bases_dictionary['enemy_base_L'].global_position)
			get_parent().add_child(bat_spawn)
			bat_spawn.position = bat_spawn_location
		i = 0
		while(i < minion_side_selection[1]): # second index sends to the right
			bat_spawn_location = Vector2(position.x + 50, position.y)
			i += 1
			var bat_spawn = BAT.instantiate()
			bat_spawn.add_to_group("allied_minions")
			bat_spawn.initialize(player_side, bases_dictionary['enemy_base_R'].global_position)
			get_parent().add_child(bat_spawn)
			bat_spawn.position = bat_spawn_location
			
			
func take_damage(attack: Attack) -> void:
	#print(attack.damage)
	stats.health -= attack.damage
	#print(stats.health)
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
		get_tree().call_group('allied_minions', 'update_target_base',
		 bases_dictionary['enemy_base_R'].global_position)
		redirect_minions_to_active_side()
	if(RightBase):
		get_tree().call_group('allied_minions', 'update_target_base', # this udpates currently living minions
		bases_dictionary['enemy_base_L'].global_position)
		redirect_minions_to_active_side() # this directs spawn to other base automatically
	queue_free()


func change_minion_wave_side_selection(increase_left: bool, increase_right: bool): # specifically reference allied base when calling this
	if (increase_left):
		if minion_side_selection[1] == 0:
			minion_side_control.update(minion_side_selection)
		else:
			minion_side_selection[1] -= 1
			minion_side_selection[0] += 1
			minion_side_control.update(minion_side_selection)
	if (increase_right):
		if minion_side_selection[0] == 0:
			minion_side_control.update(minion_side_selection)
		else:
			minion_side_selection[0] -= 1
			minion_side_selection[1] += 1
			minion_side_control.update(minion_side_selection)
	
func increase_allied_minions():
	minion_side_selection[0] += 1
func redirect_minions_to_active_side(): # the dead base calls to allied base to tell it to send minions elsewhere
	if LeftBase:
		get_tree().call_group("allied_base", 'send_all_minions_right')
	else:
		get_tree().call_group("allied_base", 'send_all_minions_left')
	
func send_all_minions_right():
	minion_side_selection[1] += minion_side_selection[0]
	minion_side_selection[0] = 0
	minion_side_control.side_is_dead(true, false, minion_side_selection)
func send_all_minions_left():
	minion_side_selection[0] += minion_side_selection[1]
	minion_side_selection[1] = 0
	minion_side_control.side_is_dead(false, true, minion_side_selection)
