extends Node2D
const FIREBALL_HEAD = preload("res://Upgrades/Spells/Particles/fireballHead.tscn")
@export var leech_particles_scene: PackedScene
@export var heal_particles_scene: PackedScene
signal player_healed()
@export var defaultCursor: Texture

func apply_effects(_caster: Node, _target: Node = null) -> void:
	var cursor_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = cursor_pos
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 4  #SET ALLY MINION COLLISION LAYER HERE
	var result = space_state.intersect_point(query, 10)
	print("leech cast")
	for hit in result:
		if hit.collider is Area2D:
			var minion = hit.collider.get_parent()
			if minion is Unit:
				if minion.has_method("damage"):
					if !minion.ally:
						return
					var attack := Attack.new()
					var healthTransfer = minion.stats.max_health + minion.stats.defence
					var _h = minion.stats.health
					attack.damage = healthTransfer
					#attack.crit_chance = 0
					minion.damage(attack)
					
					#FIX
					PlayerManager.player.stats.health += _h
					print("player healed", _h)
					if FIREBALL_HEAD:
						var fx1 = FIREBALL_HEAD.instantiate()
						fx1.global_position = minion.global_position
						get_tree().current_scene.add_child(fx1)
						Input.set_custom_mouse_cursor(defaultCursor)
						if fx1.has_method("restart"):
							fx1.restart()
						await get_tree().create_timer(0.5).timeout
						var ui = get_tree().current_scene.get_node_or_null("CameraHandler/Camera2D/CanvasLayer/UI")
						if ui:
							player_healed.connect(ui.on_health_changed_player)
						emit_signal("player_healed", PlayerManager.player.stats.health)
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
