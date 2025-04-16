class_name Stats extends Node2D

var entity: CharacterBody2D

#region Health
var max_health = 100: set = set_max_health
@onready var health = max_health: set = set_health

signal no_health
signal health_changed(value)
signal max_health_changed(value)
#endregion

signal entity_stunned(active: bool)
var stunned: bool = false

#region Damage 
signal dmg_status_changed(active: bool, buff: bool)
var dmg_timer: Timer

#base dmg of the player
var base_damage: float = 10.0

#damage of a ability/anthing that has it's own dmg
var base_effect_damage: float = 0
var effect_damage: float = 0

func reset_effect_damage():
	effect_damage = base_effect_damage

#dmg modifier for example 50% dmg increase here would be 1.5
var base_damage_modifier: float = 1
var damage_modifier: float = 1

#calculation for the damage output
var damage: float:
	get:
		return (base_damage + effect_damage) * damage_modifier
#endregion

#region Defence
signal defence_status_changed(active: bool, buff: bool)
var base_defence: float = 5.0

var base_defence_modifier: float = 1
var defence_modifier: float = 1
var defence_timer: Timer

var defence: float:
	get:
		return base_defence * defence_modifier
#endregion

#region Movement
signal movement_status_changed(active: bool, buff: bool) 
var movement_timer: Timer

var base_movement_speed: float = 100

var base_movement_speed_modifier: float = 1
var movement_speed_modifier: float = 1

var movement_speed: float:
	get:
		return base_movement_speed*movement_speed_modifier

#endregion

#region Luck and Crit
var base_luck: float = 0

var luck: float = 0

var base_crit_chance: float = 5
var crit_chance: float:
	get:
		var luck_mod = 10 if luck > 10 else luck
		return base_crit_chance + 6.5 * luck_mod
#endregion

#region Units
static var unit_packs: int = 1
static var unit_per_pack: int = 3

func upgrade_pack_number():
	unit_packs += 1

func upgrade_unit_quantity():
	unit_per_pack += 1
#endregion

#region Damage over time
var dot_timer: Timer
var dot_potency: float = 0
var dot_duration: float = 0
var dot_active: bool = false
signal dot_applied()
#endregion



#not sure what is that for
var in_transition: bool = false

func _ready() -> void:
	entity = get_parent() as CharacterBody2D

func set_max_health(value):
	max_health = value
	health = min((1 if health == null else health), max_health)
	emit_signal('max_health_changed', max_health)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

#used to apply dmg buff/debuff (permament when duration = 0 and temporary when != 0)
func dmg_buff(value: float, duration: float = 0):
	var p = value / 100
	if p == 0:
		return
	if duration == 0:
		base_damage_modifier += p
		damage_modifier += p
		return
	
	if abs(p) > abs(damage_modifier - base_damage_modifier):
		damage_modifier = base_damage_modifier + p
	elif dmg_timer && dmg_timer.time_left > 0:
		duration += dmg_timer.time_left
		dmg_timer.queue_free()
	
	dmg_timer = Timer.new()
	dmg_timer.timeout.connect(func():
		damage_modifier = base_damage_modifier
		dmg_status_changed.emit(false, true)
		dmg_timer.queue_free()
		)
	entity.add_child(dmg_timer)
	dmg_timer.start(duration)
	if damage_modifier > base_damage_modifier:
		dmg_status_changed.emit(true, true)
	elif damage_modifier < base_damage_modifier:
		dmg_status_changed.emit(true, false)

#same as above but for movement speed
func movement_speed_buff(value: float, duration: float = 0):
	var p = value / 100
	if p == 0:
		return
	if duration == 0:
		base_movement_speed_modifier += p
		movement_speed_modifier += p
		return
	
	if abs(p) > abs(movement_speed_modifier - base_movement_speed_modifier):
		movement_speed_modifier = base_movement_speed_modifier + p
	elif movement_timer && movement_timer.time_left > 0:
		duration += movement_timer.time_left
		movement_timer.queue_free()
	
	movement_timer = Timer.new()
	movement_timer.timeout.connect(func():
		movement_speed_modifier = base_movement_speed_modifier
		movement_status_changed.emit(false, true)
		movement_timer.queue_free()
		)
	entity.add_child(movement_timer)
	movement_timer.start(duration)
	if movement_speed_modifier > base_movement_speed_modifier:
		movement_status_changed.emit(true, true)
	elif movement_speed_modifier < base_movement_speed_modifier:
		movement_status_changed.emit(true, false)

#you know the drill
func defence_buff(value: float, duration: float = 0):
	var p = value / 100
	if p == 0:
		return
	if duration == 0:
		base_defence_modifier += p
		defence_modifier += p
		return
	
	if abs(p) > abs(defence_modifier - base_defence_modifier):
		defence_modifier = base_defence_modifier + p
	elif defence_timer && defence_timer.time_left > 0:
		duration += defence_timer.time_left
		defence_timer.queue_free()
	
	defence_timer = Timer.new()
	defence_timer.timeout.connect(func():
		defence_modifier = base_defence_modifier
		defence_status_changed.emit(false, true)
		defence_timer.queue_free()
		)
	entity.add_child(defence_timer)
	defence_timer.start(duration)
	if defence_modifier > base_defence_modifier:
		defence_status_changed.emit(true, true)
	elif defence_modifier < base_defence_modifier:
		defence_status_changed.emit(true, false)

func stun_entity(duration: float):
	if stunned:
		return
	stunned = true
	entity_stunned.emit(true)
	get_tree().create_timer(duration).timeout.connect(func():
			stunned = false
			entity_stunned.emit(false)
			)

func apply_dot(potency: float, duration: float):
	if (dot_potency / dot_duration) > (potency / duration):
		return
	if dot_timer && dot_timer.time_left > 0:
		dot_timer.queue_free()
	dot_potency = potency
	dot_timer = Timer.new()
	dot_duration = duration
	dot_timer.wait_time = duration
	dot_timer.timeout.connect(func():
		health = round(health)
		dot_active = false
		dot_potency = 0
		dot_timer.queue_free()
		)
	entity.add_child(dot_timer)
	dot_timer.start()
	dot_active = true
	dot_applied.emit()

func _process(delta: float) -> void:
	if stunned:
		entity.velocity = Vector2.ZERO
	
	if dot_active:
		health -= (dot_potency/dot_duration) * delta
