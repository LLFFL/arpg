extends Node2D
#Need to finalize an input
@export var firing_position : Marker2D

#@onready var player : Player = get_owner()

var projectile_scene : PackedScene = preload("res://scenes/Projectile.tscn")

func _physics_process(delta: float) -> void:
	#if Input.is_action_just_pressed("tilde"):
	#	if sign(player.aim_position.x) != sign(firing_position.position.x):
	#	firing_position.position.x *= -1
	#	#Spawn a bullet, and set the orientation based on angle between ProjectilePos & Cursor
	#	var spawned_projectile := projectile_scene.instantiate()
	#	var mouse_direction := get_global_mouse_position() - firing_position.global_position
		
	#	get_tree().root.add_child(spawned_projectile)
	#	spawned_projectile.global_position = firing_position.global_position
	#	spawned_projectile.rotation = mouse_direction.angle()
	#	#apply power ups
		#for powerups in player.upgrades:
		#	strategy.apply_powerups(spawned_projectile)
	pass
