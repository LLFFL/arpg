extends Area2D

@export var spell_resource: Spell 
@export var cast_interval := 1.5  
@export var particle_scene: PackedScene 
@export var particle_node_name := "TargetParticles"

var cast_timer := 0.0
var player: Node2D = null

#Create a function to track how long player has been in range,
#if player in range > 3 sec, start meteorfall. ramp up partciles for those 3 secs

func _process(delta: float) -> void:
	if player and is_instance_valid(player):
		cast_timer -= delta
		if cast_timer <= 0:
			cast_spell()
			cast_timer = cast_interval
			
var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")
func cast_spell() -> void:
	#if spell_resource and player and is_instance_valid(player):
		var projectile = PlayerStats.projectile_scene.instantiate() as Projectile
		
		projectile.spell = spell_resource
		#Directions
		projectile.global_position = global_position
		var direction = (player.global_position - global_position).normalized()
		projectile.angle = direction.angle()
		projectile.direction = direction
		#Stats
		projectile.damage = spell_resource.damage
		projectile.speed = spell_resource.speed
		projectile.max_pierce = spell_resource.max_pierce
		spell_resource.setup_particles(projectile)
		get_tree().current_scene.add_child(projectile)


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
		print("Player entered body")
		player = body
		attach_particles()
			
func _on_body_exited(body: Node) -> void:
	if body == player:
		player = null
		remove_particles()
