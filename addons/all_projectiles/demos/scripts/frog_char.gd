class_name FrogCharacter
extends CharacterTest


@export_group("Mega Laser Curves")
@export var laser_size_curve: Curve
@export var curtain: ColorRect
@export var curtain_node: Node2D
@export var curtain_color: Color
@export var spark: CPUParticles2D

@export_group("Celestial Missile Sine Wave")
@export var frecuency: float
@export var amplitude: float

@export_group("Eruption Down Raycast Layer")
@export_flags_2d_physics var walls_layer: int

@export_group("Dragon's Breath Curves")
@export var flame_speed_curve: Curve
@export var flame_size_curve: Curve

@export_group("Even Glare Curves")
@export var glare_speed_curve: Curve
@export var glare_size_curve: Curve
@export var glare_rotation_curve: Curve


var laser_tween: Tween


func spawn_projectile() -> void:
	var _position: Vector2 = position + Vector2(selected_attack.attack_offset.x * facing_direction, selected_attack.attack_offset.y)
	var destination: Vector2
	if (selected_attack.direction_override != Vector2.ZERO):
		destination = _position + Vector2(selected_attack.direction_override.x * facing_direction, selected_attack.direction_override.y)
	else:
		destination = get_global_mouse_position()


	match selected_projectile_id:
		13:
			projectile_caller.request_projectile(selected_projectile_id, _position, destination, null,
			update_custom_laser, start_custom_laser, no_collision, expired_custom_particle_trail)
		12:
			projectile_caller.request_projectile(selected_projectile_id, _position, destination, null,
			update_custom_sine, start_custom_sine, Callable(), expired_custom_particle_trail)
		11:
			spawn_falling_star(destination)
		10: 
			querry_raycast_down.call_deferred(destination)
		9:
			projectile_caller.request_projectile(selected_projectile_id, _position, destination, null,
			update_custom_flame, start_custom_flame, Callable(), expired_custom_particle_trail)
		8:
			projectile_caller.request_projectile(selected_projectile_id, _position, destination, null, update_custom_particle_trail, 
			func(proj: Projectile2D) -> void: start_custom_particle_trail(proj); proj.arg1["ID"] = 15; proj.arg1["SCALE"] = 3.0, 
			Callable(), expired_custom_fireball)
		7: 
			projectile_caller.request_projectile(selected_projectile_id, _position, destination, null, update_custom_particle_trail, 
			func(proj: Projectile2D) -> void: start_custom_particle_trail(proj); proj.arg1["ID"] = 14; proj.arg1["SCALE"] = 1.25, 
			Callable(), expired_custom_fireball)
		6:
			projectile_caller.request_projectile(selected_projectile_id, _position, destination, null,
			update_custom_glare, start_custom_glare, Callable(), expired_custom_particle_trail)
		4:
			projectile_caller.request_projectile(selected_projectile_id, _position, destination, null,
			custom_pursuer, start_custom_particle_trail, Callable(), expired_custom_particle_trail)
		2, 3:
			projectile_caller.request_projectile(selected_projectile_id, _position, destination, null,
			custom_seekeing, start_custom_particle_trail, Callable(), expired_custom_particle_trail)
		_:
			projectile_caller.request_projectile(selected_projectile_id, _position, destination, null,
			update_custom_particle_trail, start_custom_particle_trail, Callable(), expired_custom_particle_trail)



## --------------------------------Custom laser projectile methods-----------------------------------

func special_charge() -> void:
	if (selected_projectile_id != 13):
		return

	spark.position = position + Vector2(selected_attack.attack_offset.x * facing_direction, selected_attack.attack_offset.y)
	spark.emitting = true

	if (laser_tween):
		laser_tween.kill()
	laser_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	laser_tween.tween_property(curtain, "color", curtain_color, 1.2)
	laser_tween.tween_property(curtain, "color", Color(0, 0, 0, 0), 0.3).set_delay(1.63)
	laser_tween.parallel().tween_property(spark, "emitting", false, 0).set_delay(1.1)


func update_custom_laser(proj: InstancedProjectile2D, _delta: float) -> Vector2:
	var dic: Dictionary = proj.arg1
	if (dic == null):
		return proj.direction

	var delta: float = (proj.resource.lifetime - proj.lifetime) / proj.resource.lifetime
	

	var laser_front: Line2D = dic.get("FRONT_LINE")
	var laser_back: Line2D = dic.get("BACK_LINE")
	var buffer: Curve = dic.get("SIZE_CURVE")
	if (laser_front != null):
		laser_front.width = buffer.sample(delta) * 190
	if (laser_back != null):
		laser_back.width = buffer.sample(delta) * 220

	if (delta < 0.2):
		return proj.direction
	
	if (proj.arg2 == false):
		var trail: TimedParticle = dic.get("START_TIMED_PARTICLE_TRAIL")
		if (trail != null):
			trail.global_position = proj.position + (proj.direction * _delta * proj.speed * 0.15)
			trail.rotation = proj.direction.angle()
			trail.emitting = true
			for child: CPUParticles2D in trail.get_children():
				child.emitting = true
		
		# var spark2: CPUParticles2D = proj.instance.get_node("Spark2")
		# spark2.emitting = true
		proj.arg2 = true
		
	if (!proj.resource.allow_rehit):
		return proj.direction

	if (proj.rehit_cooldown < proj.resource.rehit_cooldown):
		return proj.direction

	proj.rehit_cooldown = 0.0

	var area_bodies: Array[Node2D] = proj.area.get_overlapping_bodies()
	area_bodies.sort_custom(func(a: Node2D, b: Node2D) -> bool: return a.position.distance_to(proj.position) < b.position.distance_to(proj.position))
	
	for body: Node2D in area_bodies:
		if body.has_method(proj.resource.on_hit_call):
			body.call(proj.resource.on_hit_call, proj)
		proj.pierce -= 1

		if (proj.pierce < 1):
			if (laser_front != null):
				laser_front.set_point_position(1, (body.global_position - position) * Vector2.RIGHT)
			if (laser_back != null):
				laser_back.set_point_position(1, (body.global_position - position) * Vector2.RIGHT)
			var trail: TimedParticle = dic.get("START_TIMED_PARTICLE_TRAIL")
			if (trail != null):
				var spark2: CPUParticles2D = trail.get_node("Spark2")
				spark2.position = (body.global_position - position) * Vector2.RIGHT
			break

	proj.pierce = proj.resource.pierce
	return proj.direction


func start_custom_laser(proj: InstancedProjectile2D) -> void:
	start_custom_particle_trail(proj)
	proj.rehit_cooldown = proj.resource.rehit_cooldown - 0.05

	proj.arg1["FRONT_LINE"] = proj.instance.get_node("Front")
	proj.arg1["BACK_LINE"] = proj.instance.get_node("Back")
	proj.arg1["SIZE_CURVE"] = laser_size_curve
	proj.arg2 = false

	var buffer: Line2D = proj.instance.get_node("Front")
	buffer.width = laser_size_curve.sample(0)
	buffer = proj.instance.get_node("Back")
	buffer.width = laser_size_curve.sample(0)


## ------------------------------Custom sine wave projectile methods-----------------------------------

func update_custom_sine(proj: InstancedProjectile2D, _delta: float) -> Vector2:
	update_custom_falling_star(proj, _delta, -3)
	
	proj.arg2 += _delta
	var time: float = proj.arg2
	return (proj.direction + (proj.direction.orthogonal() * cos(time * frecuency)) * amplitude).normalized()

func start_custom_sine(proj: Projectile2D) -> void:
	start_custom_particle_trail(proj)
	proj.arg2 = 0

	var dic: Dictionary = proj.arg1
	var buffer: TimedParticle = dic.get("START_TIMED_PARTICLE_TRAIL")
	if (buffer != null):
		buffer.transform = Transform2D(proj.direction.angle() - (PI / 2), Vector2.ONE, 0, proj.position)


## ----------------------------Custom falling star projectile methods-----------------------------------

func spawn_falling_star(dest: Vector2) -> void:
	var pos: Vector2 = Vector2(randf_range(dest.x - 50, dest.x - 350), -600 + randf_range(0, -300))

	projectile_caller.request_projectile(selected_projectile_id, pos, dest + Vector2(randf_range(-50, 50), randf_range(-50,50)), null,
	update_custom_falling_star, start_custom_particle_trail, Callable(), expired_custom_particle_trail)


func update_custom_falling_star(proj: InstancedProjectile2D, _delta: float, spin: float = 3.0) -> Vector2:
	proj.transform = proj.transform.rotated(TAU * spin * _delta)

	var dic: Dictionary = proj.arg1
	if (dic == null):
		return proj.direction

	var buffer: TimedParticle = dic.get("START_TIMED_PARTICLE_TRAIL")
	if (buffer != null):
		buffer.global_position = proj.position + (proj.direction * _delta * proj.speed * 0.15)
		buffer.rotation = proj.direction.angle() - (PI / 2)
	
	return proj.direction


## ------------------------------Custom eruption projectile methods-----------------------------------

func querry_raycast_down(pos: Vector2) -> void:
	var querry: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
		pos, Vector2(pos.x, -10), walls_layer)
	var result: Dictionary = get_world_2d().direct_space_state.intersect_ray(querry)

	var proj_pos: Vector2 = Vector2(pos.x, 0)
	if (result):
		proj_pos = result["position"]
	
	projectile_caller.request_projectile(selected_projectile_id, proj_pos, proj_pos + Vector2.UP, null,
	update_custom_eruption, func(proj: Projectile2D) -> void: start_custom_particle_trail(proj); proj.rehit_cooldown = 0, 
	no_collision, expired_custom_particle_trail)


func update_custom_eruption(proj: InstancedProjectile2D, _delta: float) -> Vector2:
	if (proj.resource.allow_rehit):
		if (proj.rehit_cooldown > proj.resource.rehit_cooldown):
			proj.excluded_targets.clear()
			proj.rehit_cooldown = 0.0
			proj.query.exclude = proj.excluded_targets
			proj.target = null

			update_custom_closest_collision(proj, _delta)

	return update_custom_particle_trail(proj, _delta, true)



## -------------------------------Custom flame projectile methods-----------------------------------

func update_custom_flame(proj: InstancedProjectile2D, _delta: float) -> Vector2:
	var dic: Dictionary = proj.arg1
	if (dic == null):
		return proj.direction

	var delta: float = (proj.resource.lifetime - proj.lifetime) / proj.resource.lifetime

	var buffer: Curve = dic.get("SPEED_CURVE")
	proj.speed = proj.resource.linear_speed * buffer.sample(delta)

	buffer = dic.get("SIZE_CURVE")
	proj.transform = Transform2D(0.0, Vector2.ONE * buffer.sample(delta), 0, Vector2.ZERO)

	update_custom_constant_collision(proj)

	return update_custom_particle_trail(proj, _delta, true)


func start_custom_flame(proj: Projectile2D) -> void:
	start_custom_particle_trail(proj)
	proj.arg1["SPEED_CURVE"] = flame_speed_curve
	proj.arg1["SIZE_CURVE"] = flame_size_curve
	proj.transform = Transform2D(proj.direction.angle(), Vector2.ONE * flame_size_curve.sample(0), 0, proj.position)
	
	var dic: Dictionary = proj.arg1
	var buffer: TimedParticle = dic.get("START_TIMED_PARTICLE_TRAIL")
	if (buffer != null):
		buffer.transform = Transform2D(proj.direction.angle(), Vector2.ONE * flame_size_curve.sample(0), 0, proj.position)


## -----------------------------Custom fireball projectile methods-----------------------------------

func update_custom_closest_collision(proj: InstancedProjectile2D, _delta: float) -> Vector2:
	var area_bodies: Array[Node2D] = proj.area.get_overlapping_bodies()
	area_bodies.sort_custom(func(a: Node2D, b: Node2D) -> bool: return a.position.distance_to(proj.position) < b.position.distance_to(proj.position))
	
	# for i: int in area_bodies.size():
	# 	print(area_bodies[i].position.distance_to(proj.position))

	for body: Node2D in area_bodies:
		if !(body is CollisionObject2D):
			continue

		var buffer: CollisionObject2D = body as CollisionObject2D
		if (!proj.validate_collision(buffer.get_rid(), body)):
			continue

		if body.has_method(proj.resource.on_hit_call):
			body.call(proj.resource.on_hit_call, proj)
		proj.on_pierced(buffer.get_rid())
		
		if (proj.is_expired):
			return proj.direction
		
	return proj.direction


func expired_custom_fireball(proj: Projectile2D) -> void:
	var dic: Dictionary = proj.arg1
	if (dic == null):
		return

	var buffer: TimedParticle = dic.get("START_TIMED_PARTICLE_TRAIL")
	if (buffer != null):
		buffer.timed_free()

	var _scale: float = dic.get("SCALE")
	var buffer2: PackedScene = dic.get("ON_EXPIRED_PACKED_SCENE")
	if (buffer2 != null):
		buffer = buffer2.instantiate()
		buffer.transform = proj.transform
		get_tree().current_scene.add_child(buffer)
		buffer.timed_free(true, true, _scale)
	
	var id: int = dic.get("ID")
	projectile_caller.request_projectile(id, proj.position, proj.position + proj.transform.x, null,
	update_custom_closest_collision, Callable(), no_collision)


func no_collision(_proj: Projectile2D, _area_rid: RID, _body: PhysicsBody2D, _area_shape_index: int, _local_shape_index: int) -> void:
	return



## -------------------------------Custom glare projectile methods-----------------------------------

func update_custom_glare(proj: InstancedProjectile2D, _delta: float) -> Vector2:
	var dic: Dictionary = proj.arg1
	if (dic == null):
		return proj.direction

	var delta: float = (proj.resource.lifetime - proj.lifetime) / proj.resource.lifetime

	var buffer: Curve = dic.get("SPEED_CURVE")
	proj.speed = proj.resource.linear_speed * buffer.sample(delta)

	buffer = dic.get("SIZE_CURVE")
	var buffer2: Curve = dic.get("ROTATION_CURVE")
	proj.transform = Transform2D(buffer2.sample(delta), Vector2.ONE * buffer.sample(delta), 0, Vector2.ZERO)

	update_custom_constant_collision(proj)

	return update_custom_particle_trail(proj, _delta)


func start_custom_glare(proj: Projectile2D) -> void:
	start_custom_particle_trail(proj)
	proj.arg1["SPEED_CURVE"] = glare_speed_curve
	proj.arg1["SIZE_CURVE"] = glare_size_curve
	proj.arg1["ROTATION_CURVE"] = glare_rotation_curve



## -------------------------Custom pursuer projectile update method----------------------------------

func custom_pursuer(proj: InstancedProjectile2D, _delta: float) -> Vector2:
	update_custom_constant_collision(proj)

	return custom_seekeing(proj, _delta)



## -----------------------------Constant collision check method--------------------------------------

func update_custom_constant_collision(proj: InstancedProjectile2D) -> void:
	if (proj.first_hit || !proj.resource.allow_rehit):
		return

	if (proj.rehit_cooldown > proj.resource.rehit_cooldown):
		proj.excluded_targets.clear()
		proj.rehit_cooldown = 0.0
		proj.query.exclude = proj.excluded_targets
		proj.target = null

		var area_bodies: Array[Node2D] = proj.area.get_overlapping_bodies()
		for body: Node2D in area_bodies:
			if (proj.is_expired):
				return
			if body.has_method(proj.resource.on_hit_call):
				body.call(proj.resource.on_hit_call, proj)
			proj.pierce -= 1;
			if (proj.pierce < 1):
				proj.is_expired = true



## ---------------------------Variable/progressive seeking method------------------------------------

func custom_seekeing(proj: Projectile2D, _delta: float) -> Vector2:
	proj.angular_speed += _delta * proj.resource.after_hit_angular_speed

	return update_custom_particle_trail(proj, _delta)



## -----------------------------Simple projectile trail methods-------------------------------------- 

func start_custom_particle_trail(proj: Projectile2D) -> void:
	proj.arg1 = {}
	if (selected_attack.blast != null):
		proj.arg1["ON_EXPIRED_PACKED_SCENE"] = selected_attack.blast
	if (selected_attack.trail != null):
		var buffer: Node2D = selected_attack.trail.instantiate()
		buffer.global_position = proj.position
		get_tree().current_scene.add_child(buffer)
		proj.arg1["START_TIMED_PARTICLE_TRAIL"] = buffer


func update_custom_particle_trail(proj: Projectile2D, _delta: float, exeption: bool = false) -> Vector2:
	var dic: Dictionary = proj.arg1
	if (dic == null):
		return proj.direction

	var buffer: TimedParticle = dic.get("START_TIMED_PARTICLE_TRAIL")
	if (buffer != null):
		buffer.transform = proj.transform
		buffer.global_position = proj.position + (proj.direction * _delta * proj.speed)
		if (exeption):
			buffer.rotate(proj.direction.angle())

	return proj.direction


# func collision_custom_trail(proj: Projectile2D, _area_rid: RID, body: PhysicsBody2D, _area_shape_index: int, _local_shape_index: int) -> void:
# 	if !(proj.validate_collsion(_area_rid, body)):
# 		return
# 	proj.on_pierced(_area_rid)

# 	var buffer: TimedParticle = proj.arg1
# 	buffer.timed_free()


func expired_custom_particle_trail(proj: Projectile2D) -> void:
	var dic: Dictionary = proj.arg1
	if (dic == null):
		return

	var buffer: TimedParticle = dic.get("START_TIMED_PARTICLE_TRAIL")
	if (buffer != null):
		buffer.timed_free()

	var buffer2: PackedScene = dic.get("ON_EXPIRED_PACKED_SCENE")
	if (buffer2 != null):
		buffer = buffer2.instantiate()
		buffer.transform = proj.transform
		get_tree().current_scene.add_child(buffer)
		buffer.timed_free(true)
