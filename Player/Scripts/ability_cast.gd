class_name CastAbilityState extends AbilityState
#import where it can go
@onready var idle: IdleAbilityState = $"../Idle"
@onready var projectile_position: Marker2D = $"../../ProjectilePosition"
const LeechSpell = preload("res://Upgrades/Scripts/LeechSpell.gd")
var spell_index: int
var in_progress: bool

func enter() -> void:
	in_progress = true
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
	
	player.ability_active = true # its for animation in player.gd
	
	var spell = PlayerStats.upgrades[spell_index]
	var projectile = PlayerStats.projectile_scene.instantiate() as Projectile
	
	projectile.spell = spell

	projectile.global_position = projectile_position.global_position
	projectile.angle = player.mouse_direction.angle()
	
	projectile.damage = spell.damage
	projectile.speed = spell.speed
	projectile.max_pierce = spell.max_pierce
	
	get_tree().root.add_child(projectile)
	projectile.icon.texture = spell.icon_texture
	
	in_progress = false
	pass

func exit() -> void:
	player.ability_active = false # its for animation in player.gd
	pass

func process( _delta: float ) -> AbilityState:
	if spell_index >= PlayerStats.upgrades.size() || !in_progress:
		return idle
	return null

func physics( _delta: float ) -> AbilityState:
	return null

func handle_input( _event: InputEvent ) -> AbilityState:
	return null
