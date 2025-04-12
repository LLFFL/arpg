class_name CastAbilityState extends AbilityState
#import where it can go
@onready var idle: IdleAbilityState = $"../Idle"
@export var firing_position : Marker2D
var isCasting: bool
#@onready var player : Player = get_owner()
#@onready var player2: Player = $"../.."
#var castTime: SceneTreeTimer
var projectile_scene : PackedScene = preload("res://scenes/Projectile.tscn")
var mouse_direction
@onready var skill_timer: Timer = $SkillTimer

func enter() -> void:
	print("Casting")
	isCasting = true
	#skill_timer.wait_time = player.skillCastTime
	skill_timer.start()
	skill_timer.timeout.connect(castSkill)
	#Spawn a bullet, and set the orientation based on angle between ProjectilePos & Cursor
	#channel
	#if action is pressed
	#flag = is casting
		#on enter, timer, on timeout cast spell
		#State
	#else: return idle

		#apply power ups
		#for powerups in player.upgrades:
		#	strategy.apply_powerups(spawned_projectile)
		
	pass

func exit() -> void:
	skill_timer.stop()
	pass

func process( _delta: float ) -> AbilityState:
	if !isCasting:
		return idle
	if sign(player.aim_position.x) != sign(firing_position.position.x):
		firing_position.position.x *= -1
	mouse_direction = player.get_global_mouse_position() - firing_position.global_position
	return null

func physics( _delta: float ) -> AbilityState:
	return null

func handle_input( _event: InputEvent ) -> AbilityState:
	#get the input pressed down that made the machine enter CastAbility
	if _event.is_action_pressed("tilde"):
		isCasting = true
	if _event.is_action_released("tilde"):
		isCasting = false
	return null

func castSkill():
	if !isCasting:
		return 
	var spawned_projectile := projectile_scene.instantiate()
	#player.add_child(spawned_projectile)
	get_tree().root.add_child(spawned_projectile)
	spawned_projectile.global_position = firing_position.global_position
	spawned_projectile.rotation = mouse_direction.angle()
	isCasting = false
	
