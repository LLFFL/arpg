class_name CastAbilityState extends AbilityState
#import where it can go
@onready var idle: IdleAbilityState = $"../Idle"
@export var firing_position : Marker2D
var isCasting: bool
var projectile_scene : PackedScene = preload("res://scenes/Projectile.tscn")
var mouse_direction
var timer: Timer

func enter() -> void:
	print("casting")
	timer = Timer.new()
	timer.wait_time = 2
	timer.timeout.connect(castSkill)
	add_child(timer)
	timer.start()
	isCasting = true
	pass

func exit() -> void:
	timer.queue_free()
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
	if _event.is_action_pressed("tilde"):
		isCasting = true
	if _event.is_action_released("tilde"):
		isCasting = false
	return null

func castSkill():
	if !isCasting:
		return 
	var spawned_projectile := projectile_scene.instantiate()
	get_tree().root.add_child(spawned_projectile)
	spawned_projectile.global_position = firing_position.global_position
	spawned_projectile.rotation = mouse_direction.angle()
	isCasting = false
	
