class_name CastAbilityState extends AbilityState
#import where it can go
@onready var idle: IdleAbilityState = $"../Idle"
@onready var projectile_position: Marker2D = $"../../ProjectilePosition"

var spell_index: int
var in_porgress: bool

func enter() -> void:
	in_porgress = true
	match state_machine.key_pressed.keycode:
		KEY_1:
			spell_index = 0
		KEY_2:
			spell_index = 1
		KEY_3:
			spell_index = 2
		KEY_4:
			spell_index = 3
	if spell_index >= PlayerStats.upgrades.size():
		return
	ability_started.emit(self)
	player.ability_active = true
	
	var spell = PlayerStats.upgrades[spell_index]
	var projectile = PlayerStats.projectile_scene.instantiate() as Projectile
	
	projectile.spell = spell

	get_tree().root.add_child(projectile)
	projectile.global_position = projectile_position.global_position
	projectile.rotation = player.mouse_direction.angle()
	
	projectile.damage = spell.damage
	projectile.speed = spell.speed
	projectile.max_pierce = spell.max_pierce
	projectile.icon.texture = spell.icon_texture
	
	in_porgress = false
	pass

func exit() -> void:
	player.ability_active = false
	pass

func process( _delta: float ) -> AbilityState:
	if spell_index >= PlayerStats.upgrades.size() || !in_porgress:
		return idle
	return null

func physics( _delta: float ) -> AbilityState:
	return null

func handle_input( _event: InputEvent ) -> AbilityState:
	return null
