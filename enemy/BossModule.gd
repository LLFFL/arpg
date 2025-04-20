extends Area2D
@onready var projectile_caller: ProjectileCaller2D = $ProjectileCaller2D

@export var spell_resource: Spell 
@export var cast_interval := 1.5
@export var cast_interval2 := 10.0  
@export var particle_scene: PackedScene 
@export var particle_node_name := "TargetParticles"
const PROJECTILE = preload("res://scenes/Projectile.tscn")
var cast_timer := 0.3
var cast_timer2 := 5.0
var duration := 10
var player: Node2D = null
#deviator
var x_deviation := 50
var direction_pos
#var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")
#Create a function to track how long player has been in range,
#if player in range > 3 sec, start meteorfall. ramp up partciles for those 3 secs 
func _process(delta: float) -> void:
	#player = null
	if player and is_instance_valid(player):
		cast_timer -= delta
		cast_timer2 -= delta
		if cast_timer <= 0:
			cast_spell()
			cast_timer = cast_interval
		if cast_timer2 <= 0:
			cast_spell2()
			cast_timer2 = cast_interval2

func cast_spell() -> void:
	var spawn_pos := position
	if get_parent().is_in_group("fire_base"):
		spawn_pos.y -= 300 
	else: 
		var x_deviation_percent := randf_range(-x_deviation, x_deviation) 
		spawn_pos = player.get_global_position()
		spawn_pos.x -=200 
		#spawn_pos.y += (1 + x_deviation_percent)
		direction_pos = player.get_global_position()
		#direction_pos.y -= 1
		cast_timer += 1.5
	if get_parent().is_in_group("fire_base"):
		projectile_caller.request_projectile(0, spawn_pos, player.get_global_position())
	else:
		projectile_caller.request_projectile(0, spawn_pos, direction_pos)

func cast_spell2() -> void:
	projectile_caller.request_projectile(1, position, player.get_global_position())
	
	#if spell_resource and player and is_instance_valid(player):
	#var projectile = PROJECTILE.instantiate() as Projectile
	#projectile.spell = spell_resource
	##Directions
	#projectile.global_position = global_position
	#var direction = (player.global_position - global_position).normalized()
	#projectile.angle = direction.angle()
	#projectile.direction = direction
	##Stats
	#projectile.damage = spell_resource.damage
	#projectile.speed = spell_resource.speed
	#projectile.max_pierce = spell_resource.max_pierce
	#spell_resource.setup_particles(projectile)
	#get_tree().current_scene.add_child(projectile)
	#projectile.hit_box.set_collision_mask_value(3, true)


func attach_particles():
	if not has_node(particle_node_name):
		var part = particle_scene.instantiate()
		part.name = particle_node_name
		if part.has_method("restart"):
			part.emitting = true
			part.restart()
		add_child(part)

func remove_particles():
	if has_node(particle_node_name):
		get_node(particle_node_name).queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Player in area")
		player = body
		attach_particles()
			
func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		remove_particles()


func _on_area_entered(area: Node2D) -> void:
	if area.is_in_group("player"):
		print("Player in area")
		player = area
		attach_particles()

func _on_area_exited(area: Node2D) -> void:
	if area == player:
		player = null
		remove_particles()
