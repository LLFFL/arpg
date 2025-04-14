extends Spell
class_name FireballSpell

func apply_effects(projectile: Node, hit_target: Node) -> void:
	var origin := (projectile as Node2D).global_position
	var tree := (projectile as Node).get_tree()

	# Hit the main target
	if hit_target.has_method("projectile_damage"):
		var attack := Attack.new()
		attack.damage = damage
		hit_target.projectile_damage(attack)

	var aoe := Area2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 64

	var collision := CollisionShape2D.new()
	collision.shape = shape
	aoe.add_child(collision)

	aoe.collision_layer = 1
	aoe.collision_mask = 1 
	aoe.global_position = origin

	tree.current_scene.add_child(aoe)

	await tree.create_timer(0.1).timeout #need for overlap detect

	var hits := aoe.get_overlapping_areas()
	print("aoe hit count:", hits.size())

	for node in hits:
		if node != hit_target and node.has_method("projectile_damage"):
			var aoe_attack := Attack.new()
			aoe_attack.damage = damage * 0.5
			node.projectile_damage(aoe_attack)
	
	var sprite := Sprite2D.new()
	sprite.texture = preload("res://assets/Ninja Adventure - Asset Pack/FX/Elemental/Flam/SpriteSheet.png") 
	sprite.position = origin
	sprite.centered = true
	sprite.scale = Vector2(1.5, 1.5)
	tree.current_scene.add_child(sprite)
	
	# Wait for visual to show, then REMOVE
	await tree.create_timer(0.3).timeout
	
	if is_instance_valid(sprite):
		sprite.queue_free()
	
	if is_instance_valid(aoe):
		aoe.queue_free()
