class_name Melee2AbilityState extends AbilityState

@onready var idle: IdleAbilityState = $"../Idle"
@onready var hit_box: Hitbox = $HitBox

var attack: Attack
var in_progress: bool = false
var timer: Timer


func init():
	super()
	hit_box.damaged_enemy.connect(_on_enemy_damaged)

func enter() -> void:	
	ability_started.emit(self)
	set_attack_values()
	in_progress = true
	player.ability_active = true
	player.update_ability_animation("melee_2")
	player.ability_animation.animation_finished.connect(_on_animation_finish)
	
	if timer:
		timer.queue_free()
	timer = Timer.new()
	timer.wait_time = 0.5
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)


func exit() -> void:
	player.ability_animation.animation_finished.disconnect(_on_animation_finish)
	player.ability_active = false
	
	if PlayerStats.melee_unlocks['attack_3']:
		pass
		#combo_attack = ComboAttack.new()
		#combo_attack.state = melee_2
		#combo_attack.input = "Melee"
	
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

func _on_animation_finish(name: String):
	in_progress = false

func set_attack_values():
	attack = Attack.new()
	attack.damage = PlayerStats.damage
	hit_box.hit_attack = attack

func _on_enemy_damaged():
	pass

func _on_timer_timeout():
	combo_attack = null
	timer.queue_free()
