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

@export var y_axis_offset: float = 0.0
@export var angle_offset_deg: float = 0.0

func apply_effects(_projectile: Node, _hit_target: Node) -> void:
	pass
	
func setup_particles(projectile: Node2D) -> void:
	if trail_particles_scene_gpu:
		var trail := trail_particles_scene_gpu.instantiate() as GPUParticles2D
		trail.name = "TrailParticles"
		projectile.add_child(trail)
	elif trail_particles_scene_cpu:
		var trail := trail_particles_scene_cpu.instantiate() as CPUParticles2D
		trail.name = "TrailParticles"
		projectile.add_child(trail)

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
