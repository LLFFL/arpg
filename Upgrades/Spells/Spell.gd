extends Pickup
class_name Spell

@export var icon_texture: Texture2D
@export var icon_scale: Vector2 = Vector2(1, 1)

@export var damage: float = 5.0
@export var speed: float = 150.0
@export var max_pierce: int = 1

@export var trail_particles_scene_gpu: PackedScene
@export var trail_particles_scene_cpu: PackedScene
@export var impact_particles_scene_gpu: PackedScene
@export var impact_particles_scene_cpu: PackedScene
@export var body_particles_scene_cpu: PackedScene
@export var body_particles_scene_gpu: PackedScene


@export var y_axis_offset: float = 0.0
@export var angle_offset_deg: float = 0.0

func apply_effects(_projectile: Node, _hit_target: Node) -> void:
	pass
	
func setup_particles(projectile: Node2D) -> void:
	var trail_scene: Node2D = null
	var body_scene: Node2D = null

	if trail_particles_scene_gpu:
		trail_scene = trail_particles_scene_gpu.instantiate() as Node2D
	elif trail_particles_scene_cpu:
		trail_scene = trail_particles_scene_cpu.instantiate() as Node2D

	if body_particles_scene_gpu:
		body_scene = body_particles_scene_gpu.instantiate() as Node2D
	elif body_particles_scene_cpu:
		body_scene = body_particles_scene_cpu.instantiate() as Node2D
		
	if body_scene:
		var body = body_scene.get_node_or_null("CPUParticles2D")
		if body == null:
			body = body_scene.get_node_or_null("GPUParticles2D")

		if body and body is Node:
			body.name = "BodyParticles"
			body.emitting = true
			body_scene.position.y += y_axis_offset  # Optional: vertical offset
			body_scene.rotation_degrees += angle_offset_deg  # Optional: angle tweak
			projectile.add_child(body_scene)



	if trail_scene:
		var trail = trail_scene.get_node_or_null("CPUParticles2D")
		if trail == null:
			trail = trail_scene.get_node_or_null("GPUParticles2D")
	
		if trail and trail is Node:
			trail.name = "TrailParticles"
			trail.emitting = true
			trail_scene.position.y += y_axis_offset
			trail_scene.rotation_degrees += angle_offset_deg
			projectile.add_child(trail_scene)
			
	



func apply_particle_effects(projectile: Node, hit_target: Node) -> void:
	var origin := (projectile as Node2D).global_position
	var tree := (projectile as Node).get_tree()

	var burst: Node2D = null

	if impact_particles_scene_gpu:
		burst = impact_particles_scene_gpu.instantiate() as GPUParticles2D
	elif impact_particles_scene_cpu:
		burst = impact_particles_scene_cpu.instantiate() as CPUParticles2D

	if burst:
		burst.global_position = origin
		tree.current_scene.add_child(burst)
		burst.restart()

		await tree.create_timer(0.5).timeout
		if is_instance_valid(burst):
			burst.queue_free()
