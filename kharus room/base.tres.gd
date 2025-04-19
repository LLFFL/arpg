extends Node2D

var bases_dictionary: Dictionary
var resource_rate: int = 10
var minion_rate: int = 3
var enemy_minions_per_wave: int = 0
var minion_side_selection: Array = [0,0] # this array will serve as number of minions to spawn per wave
const BAT = preload("res://scenes/Bat.tscn")
const ENEMY = preload("res://Units/Unit.tscn")
#@onready var stats = $StatsComponent
#@onready var stats: UnitStats = $Stats
@onready var stats: BaseStats = $Stats

@onready var hurtbox = $HurtBox
@export var SpawnOver: bool = false
@onready var bat_spawn_location = $SpawnLocation.position
@export var MainBase: bool
@export var LeftBase:bool
@export var RightBase:bool
@export var CameraShaker:ShakerComponent2D
@onready var minion_side_control = %MinionSideControl
const EnemyDeathEffect = preload("res://assets/Action RPG Resources/Effects/EnemyDeathEffect.tscn")
@onready var spawn_zone: CollisionShape2D = $SpawnZone/CollisionShape2D
@onready var target_marker: Marker2D = $TargetLocation
var target_location: Vector2
static var base1: bool = true
static var base2: bool = true
@onready var label: Label = $Label

var ally_timer: Timer
var enemy_timer: Timer

var spawn_timer: Timer
var upgrade_timer: Timer

func _ready():
	stats.units_updated.connect(increase_allied_minions)
	spawn_timer = Timer.new()
	spawn_timer.timeout.connect(_on_timer_timeout.bind(spawn_timer))
	add_child(spawn_timer)
	#ally_timer = Timer.new()
	#ally_timer.timeout.connect(_on_timer_timeout.bind(ally_timer))
	#enemy_timer = Timer.new()
	#enemy_timer.timeout.connect(_on_timer_timeout.bind(enemy_timer))
	
	target_location = target_marker.global_position
	hurtbox.damaged.connect(take_damage)
	# awkward scenario where to be detected and chase player and bat set their own personal collision to be detectable
	#$SpawnTimer.start(minion_rate)
	if (MainBase):
		#add_child(ally_timer)
		#ally_timer.start(stats.spawn_rate)
		PlayerManager.player.stats.baseStats = stats
		var flag = true
		var i = 0
		while i < stats.units_spawned:
			i += 1
			if flag:
				minion_side_selection[0] += 1
				flag = !flag
				continue
			else:
				minion_side_selection[1] += 1
				flag = !flag
				continue
		#for i in stats.units_spawned:
			#if flag:
				#minion_side_selection[0] += 1
				#flag = !flag
			#else:
				#minion_side_selection[1] += 1
				#flag = !flag
				
		#minion_side_selection = [0,1] # keeping this away from the other bases since its not necessary to them
		minion_side_control.update(minion_side_selection)
		#bat_spawn_location = Vector2(position.x, position.y - 50)
		hurtbox.set_collision_layer_value(2, true)
		hurtbox.set_collision_layer_value(3, true)
		self.add_to_group('allied_base')
		minion_side_control.left_press.connect(change_minion_wave_side_selection)
		minion_side_control.right_press.connect(change_minion_wave_side_selection)
	else:
		upgrade_timer = Timer.new()
		upgrade_timer.wait_time = 3
		upgrade_timer.timeout.connect(func():
			if LeftBase || RightBase:
				stats.level_up.emit()
				upgrade_timer.start()
			)
		add_child(upgrade_timer)
		#upgrade_timer.start()
	
	if (LeftBase):
		#add_child(enemy_timer)
		#enemy_timer.start(stats.spawn_rate)
		#bat_spawn_location = Vector2(position.x + 50, position.y)
		hurtbox.set_collision_layer_value(4, true) 
		#hurtbox.set_collision_layer_value(5, true)
	if (RightBase):
		#add_child(enemy_timer)
		#enemy_timer.start(stats.spawn_rate)
		#bat_spawn_location = Vector2(position.x - 50, position.y)
		hurtbox.set_collision_layer_value(4, true) 
		#hurtbox.set_collision_layer_value(5, true)

func _process(delta: float) -> void:
	label.text = str(stats.spawn_rate)

func initialize(bases_dictionaryy: Dictionary):
	bases_dictionary = bases_dictionaryy # this is not a a typo

func spawn_minion(player_side:bool):
	var _rect: Rect2 = spawn_zone.shape.get_rect()
	if(LeftBase or RightBase):
		for i in stats.units_spawned:
			var _x = randi_range(_rect.position.x, _rect.position.x + _rect.size.x)
			var _y = randi_range(_rect.position.y, _rect.position.y + _rect.size.y)
			var unit = ENEMY.instantiate()
			if LeftBase:
				unit.enemy = true
			else:
				unit.enemy = false
			unit.ally = false
			unit.global_position = spawn_zone.global_position + Vector2(_x, _y)
			get_tree().current_scene.add_child(unit)
			if (is_instance_valid(bases_dictionary['ally_base'])):
				unit._initialize(player_side, bases_dictionary['ally_base'].target_location, stats)
			else:
				unit._initialize(player_side, PlayerManager.player.global_position, stats)
	if MainBase:
		for i in minion_side_selection[0]:
			var _x = randi_range(_rect.position.x, _rect.position.x + _rect.size.x)
			var _y = randi_range(_rect.position.y, _rect.position.y + _rect.size.y)
			var unit = ENEMY.instantiate()
			unit.ally = true
			unit.global_position = spawn_zone.global_position + Vector2(_x, _y)
			unit.add_to_group("allied_minions")
			get_tree().current_scene.add_child(unit)
			if bases_dictionary['enemy_base_L']: #Mark bandaid
				unit._initialize(player_side, bases_dictionary['enemy_base_L'].target_location, stats)
		
		for i in minion_side_selection[1]:
			var _x = randi_range(_rect.position.x, _rect.position.x + _rect.size.x)
			var _y = randi_range(_rect.position.y, _rect.position.y + _rect.size.y)
			var unit = ENEMY.instantiate()
			#unit.stats = stats
			unit.ally = true
			unit.global_position = spawn_zone.global_position + Vector2(_x, _y)
			unit.add_to_group("allied_minions")
			get_tree().current_scene.add_child(unit)
			if bases_dictionary['enemy_base_R']: #Mark bandaid
				unit._initialize(player_side, bases_dictionary['enemy_base_R'].target_location, stats)


func take_damage(attack: Attack) -> void:
	#print(attack.damage)
	var dmg = attack.damage - stats.defence
	stats.health -= dmg if dmg > 0 else 0
	#print(stats.health)
	$Core.play_hit_animation()
	CameraShaker.play_shake()
	#get_viewport().get_camera_2d().get_node("ShakerComponent2D").play_shake()
	#print(camera_shaker)
	#amera_shaker.play_shake()
	hurtbox.start_invincibility(0.2)
	hurtbox.create_hit_effect()

func _on_timer_timeout(_timer: Timer):
	if MainBase:
		print(stats.spawn_rate)
	spawn_minion(MainBase)
	_timer.start(stats.spawn_rate)


func _on_stats_no_health() -> void:
	await get_tree().create_timer(0.3).timeout
	var enemyDeathEffect = EnemyDeathEffect.instantiate()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.position = position
	if (LeftBase):
		base1 = false
		if base2:#Mark bandaid
			get_tree().call_group('allied_minions', 'update_target_base', bases_dictionary['enemy_base_R'].target_location)
			redirect_minions_to_active_side()
	if(RightBase):
		base2 = false
		if base1: #Mark bandaid
			get_tree().call_group('allied_minions', 'update_target_base', bases_dictionary['enemy_base_L'].target_location)
			redirect_minions_to_active_side() # this directs spawn to other boss automatically
	queue_free()


func change_minion_wave_side_selection(increase_left: bool, increase_right: bool):
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
	minion_side_control.update(minion_side_selection)

func redirect_minions_to_active_side():
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

func _on_game_start():
	spawn_timer.start(stats.spawn_rate)
