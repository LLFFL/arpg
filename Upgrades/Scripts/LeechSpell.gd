extends Node2D
const FIREBALL_HEAD = preload("res://Upgrades/Spells/Particles/fireballHead.tscn")
@export var leech_particles_scene: PackedScene
@export var heal_particles_scene: PackedScene

func apply_effects(_caster: Node, _target: Node = null) -> void:
	var cursor_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = cursor_pos
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 2  #SET ALLY MINION COLLISION LAYER HERE
	var result = space_state.intersect_point(query)
	print("leech cast")
	for hit in result:
		var minion = hit.collider
		if minion.has_method("damage"):
			var attack := Attack.new()
			attack.damage = 10
			minion.damage(attack)
			
			#FIX
			PlayerManager.player.stats.health += attack.damage
			
			if FIREBALL_HEAD:
				var fx1 = FIREBALL_HEAD.instantiate()
				fx1.global_position = minion.get_parent().global_position
				get_tree().current_scene.add_child(fx1)
				if fx1.has_method("restart"):
					fx1.restart()
				await get_tree().create_timer(0.5).timeout
				if is_instance_valid(fx1):
					fx1.queue_free()

			# Particles on player
			if FIREBALL_HEAD:
				var fx2 = FIREBALL_HEAD.instantiate()
				fx2.global_position = _caster.global_position
				get_tree().current_scene.add_child(fx2)
				if fx2.has_method("restart"):
					fx2.restart()
				await get_tree().create_timer(0.5).timeout
				if is_instance_valid(fx2):
					fx2.queue_free()

			break 
