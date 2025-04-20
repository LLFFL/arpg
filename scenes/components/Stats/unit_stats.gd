class_name UnitStats extends Stats

func get_damage() -> float:
	return base_damage * damage_modifier

func get_crit() -> float:
	return 0



func set_stats(_stats: BaseStats):
	base_damage = _stats.unit_damage
	base_damage_modifier = 1
	base_movement_speed = _stats.unit_movement_speed
	base_movement_speed_modifier = 1
	base_defence = _stats.unit_defence
	base_defence_modifier = 1
	max_health = _stats.unit_health
	health = max_health
