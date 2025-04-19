class_name PlayerStats extends Stats 

var baseStats: BaseStats

#region Gold Generation
var gold: int = 0

signal gold_generation_status_changed(active: bool, buff: bool)
var base_gold_generation_modifier: float = 1
var gold_generation_modifier: float = 1
var gold_generation_timer: Timer

#logic how luck influences gold gain
var gold_generation: float:
	get:
		var luck_mod = 0
		if luck >= 5:
			luck_mod = 1.5
		elif luck >= 10:
			luck_mod = 2.3
		elif luck > 15:
			luck_mod = 3.5
		else:
			luck_mod = 0
		return base_gold_generation_modifier + luck_mod

func gold_generation_buff(value: float, duration: float = 0):
	var p = value / 100
	if p == 0:
		return
	if duration == 0:
		base_gold_generation_modifier += p
		gold_generation_modifier += p
		return
	
	if abs(p) > abs(base_gold_generation_modifier - gold_generation_modifier):
		base_gold_generation_modifier = gold_generation_modifier + p
	elif gold_generation_timer && gold_generation_timer.time_left > 0:
		duration += gold_generation_timer.time_left
		gold_generation_timer.queue_free()
	
	gold_generation_timer = Timer.new()
	gold_generation_timer.timeout.connect(func():
		base_gold_generation_modifier = gold_generation_modifier
		gold_generation_status_changed.emit(false, true)
		gold_generation_timer.queue_free()
		)
	entity.add_child(gold_generation_timer)
	gold_generation_timer.start(duration)
	if base_gold_generation_modifier > gold_generation_modifier:
		gold_generation_status_changed.emit(true, true)
	elif base_gold_generation_modifier < gold_generation_modifier:
		gold_generation_status_changed.emit(true, false)
#endregion

var passives: Array[Dictionary] = []

func add_passive(pickup: Pickup) -> void:
	if pickup.passive_upgrade:
		passives.append({
			"trigger": pickup.passive_upgrade.trigger,
			"effect": pickup.passive_upgrade.effect
		})

#Upgrade spells
var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")

var upgrades : Array = []
#setter function
func add_upgrade(upgrade):
	#if upgrades.size() < 4:
		upgrades.append(upgrade)

func add_gold(value: int):
	gold += int(round(value * gold_generation))

func upgrade_damage(value: float):
	base_damage += value
	$"../UpgradeParticles/AttackBuffParticles".amount += 1
	$"../UpgradeParticles/AttackBuffParticles".restart()

func upgrade_movement_speed(value: float):
	base_movement_speed += value
	$"../UpgradeParticles/SpeedBuffParticles".amount += 1
	$"../UpgradeParticles/SpeedBuffParticles".restart()

func upgrade_luck():
	luck += 1
	
	$"../UpgradeParticles/LuckBuffParticles".amount += 1
	$"../UpgradeParticles/LuckBuffParticles".restart()
	
	

func upgrade_defence(value: float):
	base_defence += value
	$"../UpgradeParticles/DefenseBuffParticles".amount += 1
	$"../UpgradeParticles/DefenseBuffParticles".restart()

func upgrade_units():
	baseStats.level_up.emit()

#Spell Dictionairy
#Cast time, Base Damage, Projectile speed, ext

#Power Up dictionairy
#Arrow shotgun

#Melee Overview
var melee_unlocks: Dictionary = {
	#those unlocks are for next attacks in combo chain
	"spin": false,
	"slash": false,
	"slash_proj": false,
}
