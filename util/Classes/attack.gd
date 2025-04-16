class_name Attack
# Strictly a data class
#used for passing attack information
#between hit & hurtboxes
#Similar to our previous PlayerProperties
var crit_chance: float = 1.0
var damage: float = 10.0:
	get:
		if randf_range(0, 100) <= crit_chance:
			return damage * 1.5
		else:
			return damage
var source: Node = null
