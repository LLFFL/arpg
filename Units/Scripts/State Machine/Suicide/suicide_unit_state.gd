class_name SuicideUnitState extends UnitState
@onready var attack_zone: Area2D = $"../../AttackZone"


func _ready() -> void:
	pass

func enter() -> void:
	unit.hurt_box.monitorable = false
	unit.collision_layer = 0
	unit.update_anim("wind_up")
	unit.animation_player.animation_finished.connect(attack_target)
	unit.set_collision_mask_value(1, false)
	pass


func exit() -> void:
	if unit.animation_player.animation_finished.is_connected(attack_target):
		unit.animation_player.animation_finished.disconnect(attack_target)
	if unit.animation_player.animation_finished.is_connected(_on_animation_finished):
		unit.animation_player.animation_finished.disconnect(_on_animation_finished)
	pass

func process( _delta: float ) -> UnitState:
	unit.velocity = Vector2.ZERO
	return null

func physics( _delta: float ) -> UnitState:
	if !unit.struct_target:
		unit.kill_unit()
	return null

func handle_input( _event: InputEvent ) -> UnitState:
	return null

func _on_target_exit_zone(_area: Area2D):
	pass
	#return chase

func attack_target(name: String):
	unit.animation_player.animation_finished.disconnect(attack_target)
	unit.update_anim("suicide")
	unit.animation_player.animation_finished.connect(_on_animation_finished)
	pass

func _on_animation_finished(name: String):
	pass

func jump_to_target():
	if !unit.struct_target:
		return
	var end_pos = unit.struct_target.global_position
	var tween = create_tween()
	if !unit.ally:
		var jump_pos_x = 0
		var jump_pos_y = 0
		var jump_dir = unit.global_position.direction_to(unit.struct_target.global_position).normalized()
		if jump_dir.x > 0:
			jump_pos_x = unit.struct_target.global_position.x - 120
		else:
			jump_pos_x = unit.struct_target.global_position.x + 110
		jump_pos_y = randf_range(unit.struct_target.global_position.y - 80, unit.struct_target.global_position.y + 90)
		end_pos = Vector2(jump_pos_x, jump_pos_y)
	
	tween.tween_property(unit, "global_position", end_pos, 0.7).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(func():
		if unit.struct_target:
			if unit.struct_target.has_method("damage"):
				var hit_attack = Attack.new()
				hit_attack.damage = unit.stats.damage
				unit.struct_target.damage(hit_attack)
			unit.kill_unit()
			)
