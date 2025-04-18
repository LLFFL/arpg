class_name CastAbilityState extends AbilityState
#import where it can go
@onready var idle: IdleAbilityState = $"../Idle"
@onready var projectile_position: Marker2D = $"../../ProjectilePosition"
const LeechSpell = preload("res://Upgrades/Scripts/LeechSpell.gd")
var spell_index: int
var in_progress: bool
@onready var projectile_caller_2d: ProjectileCaller2D = $"../../ProjectileCaller2D"

func enter() -> void:
	var destination = get_global_mouse_position()
	projectile_caller_2d.request_projectile(0, global_position, destination)
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
	if spell_index >= player.stats.upgrades.size():
		return
	ability_started.emit(self)
	
	player.ability_active = true # its for animation in player.gd
	#add ProjectileCaller here, replace it with the  player.stats.upgrades[spell_index]
	#projectile_caller_2d.request_projectile(0, get_global_position(), get_global_mouse_position())

	projectile_caller_2d.request_projectile(0, projectile_position.global_position, get_global_mouse_position())
	
	#var spell2 = projectile_caller_2d.projectile_resources
	#spell2 = player.stats.upgrades[spell_index]
	#var spell = player.stats.upgrades[spell_index]
	#var projectile = player.stats.projectile_scene.instantiate() as Projectile
	
	#projectile.spell = spell2

	#projectile.global_position = projectile_position.global_position
	#projectile.angle = player.mouse_direction.angle()
	#
	#projectile.damage = spell2.damage
	#projectile.speed = spell2.speed
	#projectile.max_pierce = spell2.max_pierce
	#
	#get_tree().root.add_child(projectile)
	#projectile.icon.texture = spell2.icon_texture
	
	in_progress = false
	pass

func exit() -> void:
	player.ability_active = false # its for animation in player.gd
	pass

func process( _delta: float ) -> AbilityState:
	if spell_index >= player.stats.upgrades.size() || !in_progress:
		return idle
	return null

func physics( _delta: float ) -> AbilityState:
	return null

func handle_input( _event: InputEvent ) -> AbilityState:
	return null
