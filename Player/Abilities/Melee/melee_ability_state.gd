class_name MeleeAbilityState extends AbilityState

@onready var idle: IdleAbilityState = $"../Idle"
@onready var hit_box: Hitbox = $HitBox
@onready var spin: MeleeSpinAbilityState = $"../Spin"

var attack: Attack
var in_progress: bool = false
var hit_enemy: bool = false

var timer: Timer

func init():
	super()
	hit_box.damaged_enemy.connect(_on_enemy_damaged)

func enter() -> void:
	hit_enemy = false
	ability_started.emit(self)
	set_attack_values()
	in_progress = true
	player.ability_active = true
	player.update_ability_animation("melee_1")
	player.ability_animation.animation_finished.connect(_on_animation_finish)
	
	if timer:
		timer.queue_free()
	timer = Timer.new()
	timer.wait_time = 0.5
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	pass
#Combos here, state and input
#Every state has access to combo attack
#when exit melee state, create new ComboAttack,new in melee_ability_state
#half second window aftter slash that stores next attack IF you click it.
#When timer above ends, it exits the combo attack
func exit() -> void:
	player.ability_animation.animation_finished.disconnect(_on_animation_finish)
	player.ability_active = false
	
	if player.stats.melee_unlocks['spin'] && hit_enemy:
		combo_attack = ComboAttack.new()
		combo_attack.state = spin
		combo_attack.input = "Melee"
	
	timer.start()
	pass

func process( _delta: float ) -> AbilityState:
	hit_box.scale.x = -1 if player.get_local_mouse_position().x < 0 else 1
	if !in_progress:
		return idle
	return null

func physics( _delta: float ) -> AbilityState:
	return null

func handle_input( _event: InputEvent ) -> AbilityState:
	return null

func _on_timer_timeout():
	combo_attack = null
	timer.queue_free()

func _on_animation_finish(name: String):
	in_progress = false

func set_attack_values():
	attack = Attack.new()
	attack.damage = player.stats.damage
	attack.crit_chance = player.stats.crit_chance
	attack.source = player # added for passives
	hit_box.hit_attack = attack

func _on_enemy_damaged(_attack: Attack, body: Area2D):
	hit_enemy = true
	#Check active passive abilities to see if any should trigger, then trigger
	for passive in player.stats.passives:
		if passive.trigger == "on_enemy_damaged":
			print("on enemy damaged triggered, fireboom?")
			var effect = passive.effect
			if effect and effect.has_method("apply_effects"):
				effect.apply_effects(attack.source, body)
	pass
